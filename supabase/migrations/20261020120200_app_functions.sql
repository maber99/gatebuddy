-- GateBuddy – Funktionen, die die App aufruft (RPC)
-- Alle Funktionen prüfen selbst, wer aufruft (auth.uid()), und geben nur erlaubte Daten zurück.
-- Fehlermeldungen sind stabile Codes, die die App übersetzt (z. B. 'not_available').

-- ---------------------------------------------------------------------------
-- Eigenes Profil vollständig lesen (inkl. Bildpfad und Status)
-- ---------------------------------------------------------------------------
create or replace function public.my_profile()
returns table (
  id uuid, display_name text, bio text, avatar_path text,
  photo_visibility public.photo_visibility, status public.account_status,
  terms_version text, created_at timestamptz
)
language sql stable security definer set search_path = '' as $$
  select p.id, p.display_name, p.bio, p.avatar_path, p.photo_visibility, p.status, p.terms_version, p.created_at
  from public.profiles p
  where p.id = auth.uid()
$$;

-- ---------------------------------------------------------------------------
-- Passende Personen für ein eigenes Zeitfenster
-- Regeln:
--   * gleicher Flughafen, mind. 15 Minuten gemeinsame Restzeit
--   * keine Blockierung (in beide Richtungen), aktive Konten
--   * noch nicht bewertet; bereits gematcht -> nicht erneut
--   * Personen, die "Weiter" gewählt haben, werden ausgeblendet
--     (ohne dass dies erkennbar ist – man sieht sie schlicht nicht)
-- Punktwert (transparent, siehe docs/ARCHITECTURE.md §4.4):
--   30 je gemeinsames Kontaktinteresse
--   20 wenn ich eine Sprache lerne, die die andere Person spricht
--   20 wenn die andere Person eine Sprache lernt, die ich spreche
--   10 wenn wir mind. eine gemeinsame Sprache sprechen
--    5 je gemeinsames Interesse (max. 25)
--    1 je 30 Minuten gemeinsame Zeit (max. 10)
-- ---------------------------------------------------------------------------
create or replace function public.discover_candidates(p_presence_id uuid, p_limit integer default 50)
returns table (
  profile_id uuid, display_name text, bio text, avatar_path text,
  speaks text[], learns text[], interests text[], shared_intents text[],
  overlap_starts_at timestamptz, overlap_ends_at timestamptz,
  location_verified boolean, score integer
)
language plpgsql stable security definer set search_path = '' as $$
#variable_conflict use_column
declare
  v_me uuid := auth.uid();
  v_p  public.presences;
begin
  if v_me is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if not private.is_active_profile(v_me) then
    raise exception 'account_inactive' using errcode = 'P0001';
  end if;

  select * into v_p from public.presences pr
   where pr.id = p_presence_id and pr.profile_id = v_me
     and pr.cancelled_at is null and pr.ends_at > now();
  if not found then
    raise exception 'presence_not_found' using errcode = 'P0001';
  end if;

  return query
  with cand as (
    select distinct on (o.profile_id)
           o.profile_id as cid,
           o.intents    as c_intents,
           o.location_verified as c_verified,
           greatest(o.starts_at, v_p.starts_at, now()) as ov_start,
           least(o.ends_at, v_p.ends_at)               as ov_end
      from public.presences o
     where o.airport_iata = v_p.airport_iata
       and o.profile_id <> v_me
       and o.cancelled_at is null
       and o.ends_at > now()
       and least(o.ends_at, v_p.ends_at) - greatest(o.starts_at, v_p.starts_at, now()) >= private.min_overlap()
     order by o.profile_id,
              least(o.ends_at, v_p.ends_at) - greatest(o.starts_at, v_p.starts_at, now()) desc
  ),
  filtered as (
    select c.*, pr.display_name as c_name, pr.bio as c_bio, pr.avatar_path as c_avatar, pr.photo_visibility as c_vis
      from cand c
      join public.profiles pr on pr.id = c.cid and pr.status = 'active'
     where not private.is_blocked_between(v_me, c.cid)
       and not exists (select 1 from public.reactions r
                        where (r.from_profile = v_me and r.to_profile = c.cid)
                           or (r.from_profile = c.cid and r.to_profile = v_me and r.kind = 'pass'))
       and not exists (select 1 from public.matches m
                        where m.profile_a = least(v_me, c.cid) and m.profile_b = greatest(v_me, c.cid))
  )
  select f.cid,
         f.c_name,
         f.c_bio,
         case when f.c_vis = 'airport' then f.c_avatar end,
         x.c_speaks,
         x.c_learns,
         x.c_interests,
         x.s_intents,
         f.ov_start,
         f.ov_end,
         f.c_verified,
         ( 30 * cardinality(x.s_intents)
         + case when x.c_speaks && x.my_learns then 20 else 0 end
         + case when x.c_learns && x.my_speaks then 20 else 0 end
         + case when x.c_speaks && x.my_speaks then 10 else 0 end
         + least(5 * x.shared_interest_count, 25)
         + least((extract(epoch from (f.ov_end - f.ov_start)) / 1800)::integer, 10)
         )::integer as score
    from filtered f
    cross join lateral (
      select
        coalesce(array(select l.language_code from public.profile_languages l where l.profile_id = f.cid and l.mode = 'speaks' order by 1), '{}') as c_speaks,
        coalesce(array(select l.language_code from public.profile_languages l where l.profile_id = f.cid and l.mode = 'learns' order by 1), '{}') as c_learns,
        coalesce(array(select l.language_code from public.profile_languages l where l.profile_id = v_me  and l.mode = 'speaks'), '{}') as my_speaks,
        coalesce(array(select l.language_code from public.profile_languages l where l.profile_id = v_me  and l.mode = 'learns'), '{}') as my_learns,
        coalesce(array(select i.interest_code from public.profile_interests i where i.profile_id = f.cid order by 1), '{}') as c_interests,
        (select count(*)::integer from public.profile_interests a
           join public.profile_interests b on b.interest_code = a.interest_code and b.profile_id = v_me
          where a.profile_id = f.cid) as shared_interest_count,
        coalesce(array(select unnest(f.c_intents) intersect select unnest(v_p.intents) order by 1), '{}') as s_intents
    ) x
   order by score desc, f.ov_start asc, f.cid
   limit least(greatest(coalesce(p_limit, 50), 1), 100);
end $$;

-- ---------------------------------------------------------------------------
-- Interesse / Weiter. Gibt nur zurück, ob JETZT ein Match entstanden ist.
-- Ein "Weiter" der anderen Person ist von "noch nicht reagiert" nicht unterscheidbar.
-- ---------------------------------------------------------------------------
create or replace function public.react(p_target uuid, p_kind public.reaction_kind)
returns table (is_match boolean, match_id uuid)
language plpgsql volatile security definer set search_path = '' as $$
#variable_conflict use_column
declare
  v_me      uuid := auth.uid();
  v_airport char(3);
  v_match   uuid;
begin
  if v_me is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if p_target is null or p_target = v_me then
    raise exception 'not_available' using errcode = 'P0001';
  end if;
  if not private.is_active_profile(v_me) then
    raise exception 'account_inactive' using errcode = 'P0001';
  end if;

  -- Gleichzeitige Reaktionen beider Personen sauber nacheinander abarbeiten
  perform pg_advisory_xact_lock(hashtextextended(least(v_me, p_target)::text || greatest(v_me, p_target)::text, 0));

  v_airport := private.shared_airport(v_me, p_target);
  if v_airport is null
     or not private.is_active_profile(p_target)
     or private.is_blocked_between(v_me, p_target) then
    raise exception 'not_available' using errcode = 'P0001';
  end if;

  insert into public.reactions (from_profile, to_profile, kind)
  values (v_me, p_target, p_kind)
  on conflict (from_profile, to_profile) do nothing;
  if not found then
    raise exception 'already_reacted' using errcode = 'P0001';
  end if;

  if p_kind = 'interested' and exists (
       select 1 from public.reactions r
        where r.from_profile = p_target and r.to_profile = v_me and r.kind = 'interested') then
    insert into public.matches (profile_a, profile_b, airport_iata)
    values (least(v_me, p_target), greatest(v_me, p_target), v_airport)
    on conflict (profile_a, profile_b) do nothing
    returning id into v_match;
    if v_match is null then
      select m.id into v_match from public.matches m
       where m.profile_a = least(v_me, p_target) and m.profile_b = greatest(v_me, p_target);
    end if;
    return query select true, v_match;
  else
    return query select false, null::uuid;
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- Eigene Matches mit Gesprächspartner
-- ---------------------------------------------------------------------------
create or replace function public.my_matches()
returns table (
  match_id uuid, partner_id uuid, partner_name text, partner_avatar_path text,
  airport_iata char(3), created_at timestamptz, closed_at timestamptz,
  last_message_at timestamptz, last_message_preview text
)
language sql stable security definer set search_path = '' as $$
  select m.id,
         p.id,
         p.display_name,
         case when private.can_view_avatar(auth.uid(), p.id) then p.avatar_path end,
         m.airport_iata,
         m.created_at,
         m.closed_at,
         lm.created_at,
         left(lm.body, 80)
    from public.matches m
    join public.profiles p
      on p.id = case when m.profile_a = auth.uid() then m.profile_b else m.profile_a end
    left join lateral (
      select msg.created_at, msg.body from public.messages msg
       where msg.match_id = m.id order by msg.created_at desc limit 1
    ) lm on true
   where auth.uid() in (m.profile_a, m.profile_b)
   order by coalesce(lm.created_at, m.created_at) desc
$$;

-- Match beenden (ohne zu blockieren)
create or replace function public.close_match(p_match_id uuid)
returns boolean
language plpgsql volatile security definer set search_path = '' as $$
begin
  update public.matches set closed_at = now()
   where id = p_match_id and auth.uid() in (profile_a, profile_b) and closed_at is null;
  return found;
end $$;

-- ---------------------------------------------------------------------------
-- Melden (Profil oder einzelne Nachricht)
-- ---------------------------------------------------------------------------
create or replace function public.submit_report(
  p_profile_id uuid,
  p_reason public.report_reason,
  p_details text default null,
  p_message_id uuid default null
) returns uuid
language plpgsql volatile security definer set search_path = '' as $$
declare
  v_me       uuid := auth.uid();
  v_excerpt  text;
  v_existing uuid;
  v_id       uuid;
begin
  if v_me is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if p_profile_id is null or p_profile_id = v_me then
    raise exception 'not_available' using errcode = 'P0001';
  end if;

  -- Melden darf, wer die Person sieht oder je ein Match mit ihr hatte (auch nach Blockieren)
  if not (private.can_view_profile(v_me, p_profile_id)
          or exists (select 1 from public.matches m
                      where m.profile_a = least(v_me, p_profile_id) and m.profile_b = greatest(v_me, p_profile_id))) then
    raise exception 'not_available' using errcode = 'P0001';
  end if;

  if p_message_id is not null then
    select msg.body into v_excerpt
      from public.messages msg
      join public.matches m on m.id = msg.match_id
     where msg.id = p_message_id
       and msg.sender_id = p_profile_id
       and v_me in (m.profile_a, m.profile_b);
    if not found then
      raise exception 'message_not_found' using errcode = 'P0001';
    end if;
  end if;

  -- Doppelte Meldungen innerhalb 24 h zusammenfassen
  select r.id into v_existing from public.reports r
   where r.reporter_id = v_me and r.reported_profile_id = p_profile_id
     and r.status = 'open' and r.created_at > now() - interval '24 hours'
     and r.message_id is not distinct from p_message_id
   limit 1;
  if v_existing is not null then
    return v_existing;
  end if;

  insert into public.reports (reporter_id, reported_profile_id, message_id, message_excerpt, reason, details)
  values (v_me, p_profile_id, p_message_id, v_excerpt, p_reason, nullif(btrim(p_details), ''))
  returning id into v_id;
  return v_id;
end $$;

-- ---------------------------------------------------------------------------
-- Ehrlicher Leerzustand: wie viele Personen sind jetzt / in den nächsten 7 Tagen da?
-- Nur Anzahlen, keine Zeiten oder Personen.
-- ---------------------------------------------------------------------------
create or replace function public.airport_activity(p_iata char(3))
returns table (active_now integer, planned_next_7_days integer)
language sql stable security definer set search_path = '' as $$
  select
    (select count(distinct pr.profile_id)::integer
       from public.presences pr join public.profiles p on p.id = pr.profile_id and p.status = 'active'
      where pr.airport_iata = p_iata and pr.cancelled_at is null
        and pr.starts_at <= now() and pr.ends_at > now()),
    (select count(distinct pr.profile_id)::integer
       from public.presences pr join public.profiles p on p.id = pr.profile_id and p.status = 'active'
      where pr.airport_iata = p_iata and pr.cancelled_at is null
        and pr.starts_at > now() and pr.starts_at < now() + interval '7 days')
  where auth.uid() is not null
$$;

-- ---------------------------------------------------------------------------
-- Konto löschen (App-Store- und Datenschutzpflicht)
-- Hinweis: Das Profilbild muss die App vorher über die Storage-API löschen.
-- ---------------------------------------------------------------------------
create or replace function public.delete_my_account()
returns boolean
language plpgsql volatile security definer set search_path = '' as $$
declare
  v_me uuid := auth.uid();
begin
  if v_me is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  delete from auth.users where id = v_me;
  return found;
end $$;

-- ---------------------------------------------------------------------------
-- Moderation (nur Admins)
-- ---------------------------------------------------------------------------
create or replace function public.admin_open_reports()
returns table (
  report_id uuid, created_at timestamptz, reason public.report_reason, details text,
  message_excerpt text, reported_profile_id uuid, reported_name text,
  reported_status public.account_status, reporter_id uuid, open_reports_against_profile integer
)
language plpgsql stable security definer set search_path = '' as $$
begin
  if not private.is_admin(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return query
  select r.id, r.created_at, r.reason, r.details, r.message_excerpt,
         r.reported_profile_id, p.display_name, p.status, r.reporter_id,
         (select count(*)::integer from public.reports r2
           where r2.reported_profile_id = r.reported_profile_id and r2.status = 'open')
    from public.reports r
    left join public.profiles p on p.id = r.reported_profile_id
   where r.status = 'open'
   order by r.created_at asc;
end $$;

create or replace function public.admin_resolve_report(
  p_report_id uuid, p_action public.moderation_action, p_note text default null
) returns boolean
language plpgsql volatile security definer set search_path = '' as $$
declare
  v_admin uuid := auth.uid();
  v_r     public.reports;
begin
  if not private.is_admin(v_admin) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select * into v_r from public.reports where id = p_report_id;
  if not found then
    raise exception 'report_not_found' using errcode = 'P0001';
  end if;

  if p_action = 'suspend' then
    update public.profiles set status = 'suspended' where id = v_r.reported_profile_id;
  elsif p_action = 'ban' then
    update public.profiles set status = 'banned' where id = v_r.reported_profile_id;
  elsif p_action = 'reinstate' then
    update public.profiles set status = 'active' where id = v_r.reported_profile_id;
  elsif p_action = 'delete_message' then
    if v_r.message_id is null then
      raise exception 'no_message_in_report' using errcode = 'P0001';
    end if;
    delete from public.messages where id = v_r.message_id;
  end if;

  update public.reports
     set status = case when p_action in ('dismiss', 'reinstate') then 'dismissed'::public.report_status
                       else 'actioned'::public.report_status end,
         resolved_at = now(),
         resolved_by = v_admin
   where id = p_report_id;

  insert into public.moderation_actions (report_id, target_profile_id, action, note, admin_id)
  values (p_report_id, v_r.reported_profile_id, p_action, p_note, v_admin);
  return true;
end $$;

-- Kennzahlen für die Go/No-Go-Entscheidung (docs/ROADMAP.md, Phase 14)
create or replace function public.admin_metrics(p_iata char(3), p_from timestamptz, p_to timestamptz)
returns table (
  presences integer, unique_users integer, presences_with_candidate integer,
  matches integer, matches_with_meeting integer, reports integer
)
language plpgsql stable security definer set search_path = '' as $$
begin
  if not private.is_admin(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return query
  with ps as (
    select * from public.presences
     where airport_iata = p_iata and cancelled_at is null
       and starts_at >= p_from and starts_at < p_to
  )
  select
    (select count(*)::integer from ps),
    (select count(distinct profile_id)::integer from ps),
    (select count(*)::integer from ps a
      where exists (select 1 from public.presences b
                     where b.airport_iata = a.airport_iata and b.profile_id <> a.profile_id
                       and b.cancelled_at is null
                       and least(a.ends_at, b.ends_at) - greatest(a.starts_at, b.starts_at) >= private.min_overlap())),
    (select count(*)::integer from public.matches m
      where m.airport_iata = p_iata and m.created_at >= p_from and m.created_at < p_to),
    (select count(distinct m.id)::integer from public.matches m
       join public.meet_feedback f on f.match_id = m.id and f.met
      where m.airport_iata = p_iata and m.created_at >= p_from and m.created_at < p_to),
    (select count(*)::integer from public.reports r where r.created_at >= p_from and r.created_at < p_to);
end $$;

-- ---------------------------------------------------------------------------
-- Aufräumen (wird später zeitgesteuert ausgeführt, z. B. täglich)
-- Fristen sind Vorschläge und müssen in docs/PRIVACY.md bestätigt werden.
-- ---------------------------------------------------------------------------
create or replace function private.cleanup_expired_data(
  p_presence_retention interval default interval '90 days',
  p_closed_chat_retention interval default interval '30 days'
) returns table (deleted_presences integer, deleted_messages integer)
language plpgsql volatile security definer set search_path = '' as $$
declare
  v_p integer;
  v_m integer;
begin
  delete from public.presences where ends_at < now() - p_presence_retention;
  get diagnostics v_p = row_count;

  -- Nachrichten geschlossener Matches nach Frist löschen; gemeldete Nachrichten bleiben bis zur Klärung
  delete from public.messages msg
   using public.matches m
   where msg.match_id = m.id
     and m.closed_at is not null and m.closed_at < now() - p_closed_chat_retention
     and not exists (select 1 from public.reports r where r.message_id = msg.id and r.status = 'open');
  get diagnostics v_m = row_count;

  return query select v_p, v_m;
end $$;
revoke execute on function private.cleanup_expired_data(interval, interval) from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Rechte für die App-Funktionen
-- ---------------------------------------------------------------------------
revoke execute on all functions in schema public from public, anon;
grant execute on function
  public.my_profile(),
  public.discover_candidates(uuid, integer),
  public.react(uuid, public.reaction_kind),
  public.my_matches(),
  public.close_match(uuid),
  public.submit_report(uuid, public.report_reason, text, uuid),
  public.airport_activity(char),
  public.delete_my_account(),
  public.admin_open_reports(),
  public.admin_resolve_report(uuid, public.moderation_action, text),
  public.admin_metrics(char, timestamptz, timestamptz)
to authenticated;
