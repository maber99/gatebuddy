-- GateBuddy – Verbesserungen nach Supabase-Prüfung (Security/Performance Advisor, 23.10.2026)
-- Ändert KEINE Berechtigungslogik: Zugriffsregeln bleiben inhaltlich identisch,
-- auth.uid() wird nur einmal pro Abfrage statt pro Zeile ausgewertet.
-- https://supabase.com/docs/guides/database/postgres/row-level-security#call-functions-with-select

-- 1. Fester Suchpfad auch für einfache Hilfsfunktionen
alter function private.min_overlap() set search_path = '';
alter function private.try_uuid(text) set search_path = '';
alter function private.touch_updated_at() set search_path = '';

-- 2. Zugriffsregeln: auth.uid() einmal pro Abfrage auswerten
alter policy airport_interest_own_delete on public.airport_interest
  using ((profile_id = (select auth.uid())));
alter policy airport_interest_own_insert on public.airport_interest
  with check ((profile_id = (select auth.uid())));
alter policy airport_interest_own_read on public.airport_interest
  using ((profile_id = (select auth.uid())));
alter policy blocks_own_delete on public.blocks
  using ((blocker_id = (select auth.uid())));
alter policy blocks_own_insert on public.blocks
  with check ((blocker_id = (select auth.uid())));
alter policy blocks_own_read on public.blocks
  using ((blocker_id = (select auth.uid())));
alter policy devices_own_delete on public.devices
  using ((profile_id = (select auth.uid())));
alter policy devices_own_insert on public.devices
  with check ((profile_id = (select auth.uid())));
alter policy devices_own_read on public.devices
  using ((profile_id = (select auth.uid())));
alter policy devices_own_update on public.devices
  using ((profile_id = (select auth.uid()))) with check ((profile_id = (select auth.uid())));
alter policy matches_participant_read on public.matches
  using ((((select auth.uid()) = profile_a) OR ((select auth.uid()) = profile_b)));
alter policy feedback_own_insert on public.meet_feedback
  with check (((profile_id = (select auth.uid())) AND private.is_match_participant(match_id, (select auth.uid()))));
alter policy feedback_own_read on public.meet_feedback
  using ((profile_id = (select auth.uid())));
alter policy messages_participant_insert on public.messages
  with check (((sender_id = (select auth.uid())) AND private.can_message(match_id, (select auth.uid()))));
alter policy messages_participant_read on public.messages
  using (private.is_match_participant(match_id, (select auth.uid())));
alter policy moderation_admin_read on public.moderation_actions
  using (private.is_admin((select auth.uid())));
alter policy presences_own_delete on public.presences
  using ((profile_id = (select auth.uid())));
alter policy presences_own_insert on public.presences
  with check ((profile_id = (select auth.uid())));
alter policy presences_own_read on public.presences
  using ((profile_id = (select auth.uid())));
alter policy presences_own_update on public.presences
  using ((profile_id = (select auth.uid()))) with check ((profile_id = (select auth.uid())));
alter policy interests_p_delete_own on public.profile_interests
  using ((profile_id = (select auth.uid())));
alter policy interests_p_insert_own on public.profile_interests
  with check ((profile_id = (select auth.uid())));
alter policy interests_p_read on public.profile_interests
  using (private.can_view_profile((select auth.uid()), profile_id));
alter policy languages_delete_own on public.profile_languages
  using ((profile_id = (select auth.uid())));
alter policy languages_insert_own on public.profile_languages
  with check ((profile_id = (select auth.uid())));
alter policy languages_read on public.profile_languages
  using (private.can_view_profile((select auth.uid()), profile_id));
alter policy profiles_insert_own on public.profiles
  with check ((id = (select auth.uid())));
alter policy profiles_read on public.profiles
  using (private.can_view_profile((select auth.uid()), id));
alter policy profiles_update_own on public.profiles
  using ((id = (select auth.uid()))) with check ((id = (select auth.uid())));
alter policy reactions_own_read on public.reactions
  using ((from_profile = (select auth.uid())));
alter policy reports_admin_read on public.reports
  using (private.is_admin((select auth.uid())));

-- 3. Indizes für Verknüpfungen (Löschen/Abfragen bleiben bei Wachstum schnell)
create index if not exists airport_interest_airport_iata_idx on public.airport_interest (airport_iata);
create index if not exists devices_profile_id_idx on public.devices (profile_id);
create index if not exists matches_airport_iata_idx on public.matches (airport_iata);
create index if not exists meet_feedback_profile_id_idx on public.meet_feedback (profile_id);
create index if not exists moderation_actions_admin_id_idx on public.moderation_actions (admin_id);
create index if not exists moderation_actions_report_id_idx on public.moderation_actions (report_id);
create index if not exists moderation_actions_target_profile_id_idx on public.moderation_actions (target_profile_id);
create index if not exists profile_interests_interest_code_idx on public.profile_interests (interest_code);
create index if not exists reports_message_id_idx on public.reports (message_id);
create index if not exists reports_reporter_id_idx on public.reports (reporter_id);
create index if not exists reports_resolved_by_idx on public.reports (resolved_by);
