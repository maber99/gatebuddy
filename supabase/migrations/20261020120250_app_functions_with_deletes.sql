-- GateBuddy – Funktionen mit Löschbefehlen (getrennt, damit sie bewusst bestätigt eingespielt werden)
-- Beim Einspielen wird NICHTS gelöscht. Die Löschbefehle laufen erst, wenn die Funktion aufgerufen wird:
--   delete_my_account()      – nur das eigene Konto der aufrufenden Person
--   admin_resolve_report()   – nur Admins (z. B. gemeldete Nachricht entfernen)
--   cleanup_expired_data()   – nicht für Nutzer aufrufbar; alte Zeitfenster/Chats nach Frist

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
-- Rechte
-- ---------------------------------------------------------------------------
revoke execute on function public.delete_my_account() from public, anon;
revoke execute on function public.admin_resolve_report(uuid, public.moderation_action, text) from public, anon;
grant execute on function
  public.delete_my_account(),
  public.admin_resolve_report(uuid, public.moderation_action, text)
to authenticated;
