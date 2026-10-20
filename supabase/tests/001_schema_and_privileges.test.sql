-- Grundsicherung: RLS überall, keine unerwarteten Rechte
begin;
\ir helpers/test_helpers.psql
select plan(17);
select tests.open_tap_tables();

select is_empty(
  $$ select c.relname::text from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relkind = 'r' and not c.relrowsecurity $$,
  'Row Level Security ist auf allen Tabellen in public aktiv');

select is_empty(
  $$ select table_name::text || ':' || privilege_type from information_schema.role_table_grants
      where grantee = 'anon' and table_schema = 'public' and privilege_type <> 'SELECT' $$,
  'Nicht eingeloggte Besucher haben keinerlei Schreibrechte');

select is(
  (select array_agg(distinct table_name::text) from information_schema.role_table_grants
    where grantee = 'anon' and table_schema = 'public'),
  array['airports', 'intents', 'interests'],
  'Besucher dürfen nur die Kataloge lesen');

select ok(not has_table_privilege('authenticated', 'public.reactions', 'INSERT'), 'Reaktionen nur über react(), nicht direkt');
select ok(not has_table_privilege('authenticated', 'public.matches', 'INSERT'), 'Matches können nicht direkt angelegt werden');
select ok(not has_table_privilege('authenticated', 'public.reports', 'INSERT'), 'Meldungen nur über submit_report()');
select ok(not has_table_privilege('authenticated', 'public.admins', 'SELECT'), 'Admin-Liste ist für Nutzer unsichtbar');
select ok(not has_function_privilege('anon', 'private.can_view_profile(uuid, uuid)', 'EXECUTE'), 'Interne Funktionen für Besucher gesperrt');
select ok(not has_function_privilege('authenticated', 'private.cleanup_expired_data(interval, interval)', 'EXECUTE'), 'Aufräumfunktion nicht für Nutzer');
select ok(not has_function_privilege('anon', 'public.discover_candidates(uuid, integer)', 'EXECUTE'), 'Besucher können keine Personen suchen');
select ok(not has_column_privilege('authenticated', 'public.profiles', 'status', 'SELECT'), 'Kontostatus anderer nicht lesbar');
select ok(not has_column_privilege('authenticated', 'public.profiles', 'avatar_path', 'SELECT'), 'Bildpfad nicht direkt lesbar');
select ok(not has_column_privilege('authenticated', 'public.profiles', 'status', 'UPDATE'), 'Eigenen Status nicht änderbar');

select is((select array_agg(iata::text) from public.airports where is_active), array['ZRH'], 'Nur Zürich ist aktiv (ADR-005)');
select is((select count(*)::integer from public.intents), 6, 'Sechs Kontaktinteressen hinterlegt');
select ok((select not public from storage.buckets where id = 'avatars'), 'Profilbild-Speicher ist privat');

select tests.login_anon();
select throws_ok($$ select * from public.profiles $$, '42501', null, 'Besucher können keine Profile lesen');

select * from finish();
rollback;
