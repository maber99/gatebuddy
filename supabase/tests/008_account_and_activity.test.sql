-- Konto löschen, Aktivitätsanzeige, Nachfrage, Aufräumen
begin;
\ir helpers/test_helpers.psql
select plan(11);

select tests.new_user('Anna') as a \gset
select tests.new_user('Ben')  as b \gset
select tests.new_user('Carla') as c \gset
select tests.add_presence(:'a');
select tests.add_presence(:'b');
select tests.add_presence(:'c', interval '2 days');
insert into public.matches (profile_a, profile_b, airport_iata)
  values (least(:'a'::uuid, :'b'::uuid), greatest(:'a'::uuid, :'b'::uuid), 'ZRH');
select tests.open_tap_tables();

select tests.login_as(:'b');
select is((select row(active_now, planned_next_7_days)::text from public.airport_activity('ZRH')), '(2,1)',
  'Leerzustand: 2 Personen jetzt, 1 geplant (nur Anzahlen)');
select public.submit_report(:'a', 'spam') as rep \gset
select lives_ok($$ insert into public.airport_interest (airport_iata) values ('MUC') $$, 'Nachfrage für weiteren Flughafen erfassen');

select tests.login_anon();
select throws_ok($$ select * from public.airport_activity('ZRH') $$, '42501', null, 'Besucher sehen keine Aktivität');

select tests.login_as(:'a');
select is(public.delete_my_account(), true, 'Konto löschen');
reset role;
select is((select count(*)::integer from auth.users where id = :'a'), 0, 'Anmeldekonto entfernt');
select is((select count(*)::integer from public.profiles where id = :'a'), 0, 'Profil entfernt');
select is((select count(*)::integer from public.presences where profile_id = :'a'), 0, 'Zeitfenster entfernt');
select is((select count(*)::integer from public.matches where :'a' in (profile_a, profile_b)), 0, 'Matches entfernt');
select is((select row(reporter_id = :'b', reported_profile_id is null)::text from public.reports where id = :'rep'), '(t,t)',
  'Meldungen über gelöschte Konten bleiben anonymisiert erhalten');

-- Alte Daten aufräumen (Trigger für das Testdatum kurz umgehen)
set local session_replication_role = replica;
insert into public.presences (profile_id, airport_iata, starts_at, ends_at, intents)
values (:'b', 'ZRH', now() - interval '120 days', now() - interval '119 days 22 hours', array['coffee']);
set local session_replication_role = origin;
select is((select deleted_presences from private.cleanup_expired_data()), 1, 'Abgelaufene Zeitfenster werden nach 90 Tagen gelöscht');
select is((select count(*)::integer from public.presences where profile_id = :'b'), 1, 'Aktuelle Zeitfenster bleiben');

select * from finish();
rollback;
