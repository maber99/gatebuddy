-- GateBuddy – Geschäftsregeln (Trigger), Hilfsfunktionen und Zugriffsregeln (RLS)
-- Grundsatz: Standardmässig ist alles verboten. Jede Freigabe ist hier explizit.

-- ===========================================================================
-- 1. Hilfsfunktionen (Schema private, nicht über die API aufrufbar)
-- ===========================================================================

create or replace function private.min_overlap() returns interval
language sql immutable as $$ select interval '15 minutes' $$;
comment on function private.min_overlap() is 'Mindestens gemeinsame Zeit, damit zwei Zeitfenster als "passend" gelten.';

create or replace function private.is_active_profile(p uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.profiles where id = p and status = 'active')
$$;

create or replace function private.is_admin(p uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select p is not null and exists (select 1 from public.admins where profile_id = p)
$$;

create or replace function private.is_blocked_between(a uuid, b uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.blocks
    where (blocker_id = a and blocked_id = b) or (blocker_id = b and blocked_id = a)
  )
$$;

create or replace function private.has_open_match(a uuid, b uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.matches
    where profile_a = least(a, b) and profile_b = greatest(a, b) and closed_at is null
  )
$$;

-- Haben a und b JETZT oder künftig ein überlappendes Zeitfenster am selben Flughafen
-- (mindestens private.min_overlap() gemeinsame Restzeit)?
create or replace function private.shared_airport(a uuid, b uuid) returns char(3)
language sql stable security definer set search_path = '' as $$
  select pa.airport_iata
  from public.presences pa
  join public.presences pb on pb.airport_iata = pa.airport_iata
  where pa.profile_id = a and pb.profile_id = b
    and pa.cancelled_at is null and pb.cancelled_at is null
    and pa.ends_at > now() and pb.ends_at > now()
    and least(pa.ends_at, pb.ends_at) - greatest(pa.starts_at, pb.starts_at, now()) >= private.min_overlap()
  limit 1
$$;

create or replace function private.shares_overlap(a uuid, b uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select private.shared_airport(a, b) is not null
$$;

-- Darf viewer das Profil von target sehen?
create or replace function private.can_view_profile(viewer uuid, target uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select viewer is not null and (
    viewer = target
    or (
      private.is_active_profile(viewer)
      and private.is_active_profile(target)
      and not private.is_blocked_between(viewer, target)
      and (private.has_open_match(viewer, target) or private.shares_overlap(viewer, target))
    )
  )
$$;

-- Darf viewer das Profilbild von owner sehen? (ADR-007)
create or replace function private.can_view_avatar(viewer uuid, owner uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select viewer is not null and (
    viewer = owner
    or (
      private.can_view_profile(viewer, owner)
      and (
        private.has_open_match(viewer, owner)
        or exists (select 1 from public.profiles where id = owner and photo_visibility = 'airport')
      )
    )
  )
$$;

create or replace function private.is_match_participant(p_match uuid, p uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.matches where id = p_match and p in (profile_a, profile_b))
$$;

create or replace function private.can_message(p_match uuid, p uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.matches m
    where m.id = p_match
      and p in (m.profile_a, m.profile_b)
      and m.closed_at is null
      and private.is_active_profile(m.profile_a)
      and private.is_active_profile(m.profile_b)
      and not private.is_blocked_between(m.profile_a, m.profile_b)
  )
$$;

create or replace function private.try_uuid(t text) returns uuid
language plpgsql immutable as $$
begin
  return t::uuid;
exception when others then
  return null;
end $$;

create or replace function private.contains_blocked_term(t text) returns boolean
language sql stable security definer set search_path = '' as $$
  select t is not null and exists (
    select 1 from private.blocked_terms bt where position(bt.term in lower(t)) > 0
  )
$$;

-- ===========================================================================
-- 2. Geschäftsregeln (Trigger)
-- ===========================================================================

create or replace function private.touch_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

create trigger profiles_touch_updated_at
  before update on public.profiles
  for each row execute function private.touch_updated_at();

-- Profiltexte: Wortfilter, keine Links (Spam-Schutz)
create or replace function private.validate_profile() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  new.display_name := btrim(new.display_name);
  if new.bio is not null then
    new.bio := nullif(btrim(new.bio), '');
  end if;
  if private.contains_blocked_term(new.display_name) or private.contains_blocked_term(new.bio) then
    raise exception 'content_blocked' using errcode = 'P0001';
  end if;
  if new.display_name ~* '(https?://|www\.)' or coalesce(new.bio, '') ~* '(https?://|www\.)' then
    raise exception 'links_not_allowed' using errcode = 'P0001';
  end if;
  return new;
end $$;

create trigger profiles_validate
  before insert or update of display_name, bio on public.profiles
  for each row execute function private.validate_profile();

-- Obergrenzen für Listen im Profil
create or replace function private.limit_profile_rows() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_count integer;
begin
  if tg_table_name = 'profile_languages' then
    select count(*) into v_count from public.profile_languages
      where profile_id = new.profile_id and mode = new.mode;
    if v_count >= 8 then raise exception 'too_many_languages' using errcode = 'P0001'; end if;
  elsif tg_table_name = 'profile_interests' then
    select count(*) into v_count from public.profile_interests where profile_id = new.profile_id;
    if v_count >= 10 then raise exception 'too_many_interests' using errcode = 'P0001'; end if;
  end if;
  return new;
end $$;

create trigger profile_languages_limit before insert on public.profile_languages
  for each row execute function private.limit_profile_rows();
create trigger profile_interests_limit before insert on public.profile_interests
  for each row execute function private.limit_profile_rows();

-- Zeitfenster: aktive Flughäfen, gültige Interessen, Zeitgrenzen, Kontostatus
create or replace function private.validate_presence() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_future_count integer;
begin
  if tg_op = 'UPDATE' then
    if new.profile_id <> old.profile_id or new.airport_iata <> old.airport_iata or new.starts_at <> old.starts_at then
      raise exception 'presence_immutable_fields' using errcode = 'P0001';
    end if;
  end if;

  -- Interessen: Duplikate entfernen, nur bekannte Codes zulassen
  new.intents := array(select distinct unnest(new.intents) order by 1);
  if exists (select 1 from unnest(new.intents) i where i not in (select code from public.intents)) then
    raise exception 'invalid_intent' using errcode = 'P0001';
  end if;

  if new.flight_number is not null then
    new.flight_number := nullif(upper(regexp_replace(new.flight_number, '\s', '', 'g')), '');
  end if;

  if tg_op = 'INSERT' then
    -- Gesperrte Konten dürfen keine neuen Zeitfenster anlegen (Beenden/Abbrechen bleibt möglich)
    if not private.is_active_profile(new.profile_id) then
      raise exception 'account_inactive' using errcode = 'P0001';
    end if;
    if not exists (select 1 from public.airports where iata = new.airport_iata and is_active) then
      raise exception 'airport_inactive' using errcode = 'P0001';
    end if;
    if new.starts_at < now() - interval '10 minutes' then
      raise exception 'presence_in_past' using errcode = 'P0001';
    end if;
    if new.starts_at > now() + interval '14 days' then
      raise exception 'presence_too_far_ahead' using errcode = 'P0001';
    end if;
    if new.ends_at <= now() then
      raise exception 'presence_in_past' using errcode = 'P0001';
    end if;
    select count(*) into v_future_count from public.presences
      where profile_id = new.profile_id and cancelled_at is null and ends_at > now();
    if v_future_count >= 20 then
      raise exception 'too_many_presences' using errcode = 'P0001';
    end if;
  end if;

  return new;
end $$;

create trigger presences_validate
  before insert or update on public.presences
  for each row execute function private.validate_presence();

-- Chat: Rate-Limit und Wortfilter
create or replace function private.validate_message() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_recent integer;
begin
  new.body := btrim(new.body);
  select count(*) into v_recent from public.messages
    where sender_id = new.sender_id and created_at > now() - interval '1 minute';
  if v_recent >= 20 then
    raise exception 'rate_limited' using errcode = 'P0001';
  end if;
  if private.contains_blocked_term(new.body) then
    raise exception 'content_blocked' using errcode = 'P0001';
  end if;
  return new;
end $$;

create trigger messages_validate
  before insert on public.messages
  for each row execute function private.validate_message();

-- Blockieren schliesst ein offenes Match sofort
create or replace function private.close_match_on_block() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  update public.matches
     set closed_at = now()
   where profile_a = least(new.blocker_id, new.blocked_id)
     and profile_b = greatest(new.blocker_id, new.blocked_id)
     and closed_at is null;
  return new;
end $$;

create trigger blocks_close_match
  after insert on public.blocks
  for each row execute function private.close_match_on_block();

-- Automatische vorläufige Sperre: 3 verschiedene Meldende in 7 Tagen
create or replace function private.auto_suspend_on_reports() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_reporters integer;
begin
  if new.reported_profile_id is null then
    return new;
  end if;
  select count(distinct reporter_id) into v_reporters
    from public.reports
   where reported_profile_id = new.reported_profile_id
     and status = 'open'
     and created_at > now() - interval '7 days';
  if v_reporters >= 3 then
    update public.profiles set status = 'suspended'
     where id = new.reported_profile_id and status = 'active';
    if found then
      insert into public.moderation_actions (report_id, target_profile_id, action, note, is_automatic)
      values (new.id, new.reported_profile_id, 'suspend', 'Automatisch: 3 Meldungen von verschiedenen Personen in 7 Tagen. Prüfung erforderlich.', true);
    end if;
  end if;
  return new;
end $$;

create trigger reports_auto_suspend
  after insert on public.reports
  for each row execute function private.auto_suspend_on_reports();

-- ===========================================================================
-- 3. Rechte: erst alles entziehen, dann gezielt freigeben
-- ===========================================================================

revoke all on all tables in schema public from anon, authenticated;
revoke all on all tables in schema private from anon, authenticated, public;
revoke all on all functions in schema private from public, anon, authenticated;

grant usage on schema private to authenticated;
grant execute on all functions in schema private to authenticated;
-- Trigger-Funktionen braucht niemand direkt
revoke execute on function private.touch_updated_at(), private.validate_profile(), private.limit_profile_rows(),
  private.validate_presence(), private.validate_message(), private.close_match_on_block(),
  private.auto_suspend_on_reports() from authenticated;

-- RLS für ALLE Tabellen in public aktivieren
alter table public.airports           enable row level security;
alter table public.intents            enable row level security;
alter table public.interests          enable row level security;
alter table public.profiles           enable row level security;
alter table public.profile_languages  enable row level security;
alter table public.profile_interests  enable row level security;
alter table public.presences          enable row level security;
alter table public.reactions          enable row level security;
alter table public.matches            enable row level security;
alter table public.messages           enable row level security;
alter table public.meet_feedback      enable row level security;
alter table public.blocks             enable row level security;
alter table public.reports            enable row level security;
alter table public.moderation_actions enable row level security;
alter table public.admins             enable row level security;
alter table public.devices            enable row level security;
alter table public.airport_interest   enable row level security;

-- Kataloge: öffentlich lesbar
grant select on public.airports, public.intents, public.interests to anon, authenticated;
create policy airports_read  on public.airports  for select to anon, authenticated using (true);
create policy intents_read   on public.intents   for select to anon, authenticated using (true);
create policy interests_read on public.interests for select to anon, authenticated using (true);

-- Profile: sichtbar nur bei Zeitüberschneidung am selben Flughafen oder offenem Match.
-- Spaltenrechte verbergen interne Felder (Status, Bildpfad, Zustimmungsdaten).
grant select (id, display_name, bio, photo_visibility, created_at) on public.profiles to authenticated;
grant insert (id, display_name, bio, photo_visibility, is_adult_confirmed, terms_version) on public.profiles to authenticated;
grant update (display_name, bio, avatar_path, photo_visibility) on public.profiles to authenticated;

create policy profiles_read on public.profiles for select to authenticated
  using (private.can_view_profile(auth.uid(), id));
create policy profiles_insert_own on public.profiles for insert to authenticated
  with check (id = auth.uid());
create policy profiles_update_own on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- Sprachen & Interessen: lesbar wie das Profil, schreibbar nur selbst
grant select, insert, delete on public.profile_languages, public.profile_interests to authenticated;
create policy languages_read on public.profile_languages for select to authenticated
  using (private.can_view_profile(auth.uid(), profile_id));
create policy languages_insert_own on public.profile_languages for insert to authenticated
  with check (profile_id = auth.uid());
create policy languages_delete_own on public.profile_languages for delete to authenticated
  using (profile_id = auth.uid());
create policy interests_p_read on public.profile_interests for select to authenticated
  using (private.can_view_profile(auth.uid(), profile_id));
create policy interests_p_insert_own on public.profile_interests for insert to authenticated
  with check (profile_id = auth.uid());
create policy interests_p_delete_own on public.profile_interests for delete to authenticated
  using (profile_id = auth.uid());

-- Zeitfenster: nur die eigenen sind direkt lesbar. Andere nur über discover_candidates().
grant select, delete on public.presences to authenticated;
grant insert (profile_id, airport_iata, starts_at, ends_at, intents, location_verified, flight_number) on public.presences to authenticated;
grant update (ends_at, intents, location_verified, flight_number, cancelled_at) on public.presences to authenticated;
create policy presences_own_read   on public.presences for select to authenticated using (profile_id = auth.uid());
create policy presences_own_insert on public.presences for insert to authenticated with check (profile_id = auth.uid());
create policy presences_own_update on public.presences for update to authenticated
  using (profile_id = auth.uid()) with check (profile_id = auth.uid());
create policy presences_own_delete on public.presences for delete to authenticated using (profile_id = auth.uid());

-- Reaktionen: nur eigene ausgehende lesbar; Schreiben ausschliesslich über react()
grant select on public.reactions to authenticated;
create policy reactions_own_read on public.reactions for select to authenticated using (from_profile = auth.uid());

-- Matches: nur Beteiligte; Anlegen ausschliesslich über react()
grant select on public.matches to authenticated;
create policy matches_participant_read on public.matches for select to authenticated
  using (auth.uid() in (profile_a, profile_b));

-- Nachrichten: nur Beteiligte; Schreiben nur in offenem Match ohne Blockierung
grant select on public.messages to authenticated;
grant insert (match_id, sender_id, body) on public.messages to authenticated;
create policy messages_participant_read on public.messages for select to authenticated
  using (private.is_match_participant(match_id, auth.uid()));
create policy messages_participant_insert on public.messages for insert to authenticated
  with check (sender_id = auth.uid() and private.can_message(match_id, auth.uid()));

-- Treffen-Feedback
grant select on public.meet_feedback to authenticated;
grant insert (match_id, profile_id, met) on public.meet_feedback to authenticated;
create policy feedback_own_read on public.meet_feedback for select to authenticated using (profile_id = auth.uid());
create policy feedback_own_insert on public.meet_feedback for insert to authenticated
  with check (profile_id = auth.uid() and private.is_match_participant(match_id, auth.uid()));

-- Blockieren
grant select, delete on public.blocks to authenticated;
grant insert (blocker_id, blocked_id) on public.blocks to authenticated;
create policy blocks_own_read   on public.blocks for select to authenticated using (blocker_id = auth.uid());
create policy blocks_own_insert on public.blocks for insert to authenticated with check (blocker_id = auth.uid());
create policy blocks_own_delete on public.blocks for delete to authenticated using (blocker_id = auth.uid());

-- Meldungen & Moderation: Nutzer melden über submit_report(); lesen dürfen nur Admins
grant select on public.reports, public.moderation_actions to authenticated;
create policy reports_admin_read on public.reports for select to authenticated using (private.is_admin(auth.uid()));
create policy moderation_admin_read on public.moderation_actions for select to authenticated using (private.is_admin(auth.uid()));
-- admins: keine Freigabe für Nutzer

-- Geräte (Push-Tokens)
grant select, delete on public.devices to authenticated;
grant insert (profile_id, expo_push_token, platform) on public.devices to authenticated;
grant update (last_seen_at) on public.devices to authenticated;
create policy devices_own_read   on public.devices for select to authenticated using (profile_id = auth.uid());
create policy devices_own_insert on public.devices for insert to authenticated with check (profile_id = auth.uid());
create policy devices_own_update on public.devices for update to authenticated
  using (profile_id = auth.uid()) with check (profile_id = auth.uid());
create policy devices_own_delete on public.devices for delete to authenticated using (profile_id = auth.uid());

-- Nachfrage nach weiteren Flughäfen
grant select, delete on public.airport_interest to authenticated;
grant insert (profile_id, airport_iata) on public.airport_interest to authenticated;
create policy airport_interest_own_read   on public.airport_interest for select to authenticated using (profile_id = auth.uid());
create policy airport_interest_own_insert on public.airport_interest for insert to authenticated with check (profile_id = auth.uid());
create policy airport_interest_own_delete on public.airport_interest for delete to authenticated using (profile_id = auth.uid());
