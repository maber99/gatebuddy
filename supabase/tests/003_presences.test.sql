-- Zeitfenster am Flughafen: Regeln und Grenzen
begin;
\ir helpers/test_helpers.psql
select plan(16);

select tests.new_user('Uma') as u \gset
select tests.new_user('Viktor') as v \gset
select tests.open_tap_tables();
select tests.login_as(:'u');

select lives_ok($$ insert into public.presences (airport_iata, starts_at, ends_at, intents)
                   values ('ZRH', now(), now() + interval '2 hours', array['coffee']) $$, 'Zeitfenster "jetzt" in ZRH');
select throws_ok($$ insert into public.presences (airport_iata, starts_at, ends_at, intents)
                    values ('MUC', now() + interval '1 day', now() + interval '1 day 1 hour', array['coffee']) $$,
  'P0001', 'airport_inactive', 'Inaktiver Flughafen abgelehnt');
select throws_ok($$ insert into public.presences (airport_iata, starts_at, ends_at, intents)
                    values ('ZRH', now() + interval '1 day', now() + interval '1 day 7 hours', array['coffee']) $$,
  '23514', null, 'Mehr als 6 Stunden abgelehnt');
select throws_ok($$ insert into public.presences (airport_iata, starts_at, ends_at, intents)
                    values ('ZRH', now() + interval '15 days', now() + interval '15 days 1 hour', array['coffee']) $$,
  'P0001', 'presence_too_far_ahead', 'Mehr als 14 Tage im Voraus abgelehnt');
select throws_ok($$ insert into public.presences (airport_iata, starts_at, ends_at, intents)
                    values ('ZRH', now() - interval '3 hours', now() - interval '1 hour', array['coffee']) $$,
  'P0001', 'presence_in_past', 'Vergangenheit abgelehnt');
select throws_ok($$ insert into public.presences (airport_iata, starts_at, ends_at, intents)
                    values ('ZRH', now() + interval '1 hour', now() + interval '3 hours', array['coffee']) $$,
  '23P01', null, 'Eigene Zeitfenster dürfen sich nicht überlappen');
select throws_ok($$ insert into public.presences (airport_iata, starts_at, ends_at, intents)
                    values ('ZRH', now() + interval '2 days', now() + interval '2 days 1 hour', array['dating']) $$,
  'P0001', 'invalid_intent', 'Unbekanntes Kontaktinteresse abgelehnt');

insert into public.presences (airport_iata, starts_at, ends_at, intents, flight_number)
values ('ZRH', now() + interval '3 days', now() + interval '3 days 2 hours', array['coffee', 'coffee', 'casual_chat'], ' lx 318 ');
select is((select flight_number from public.presences where starts_at = now() + interval '3 days'), 'LX318', 'Flugnummer wird vereinheitlicht');
select is((select intents from public.presences where starts_at = now() + interval '3 days'), array['casual_chat', 'coffee'], 'Doppelte Interessen entfernt');
select throws_ok($$ insert into public.presences (airport_iata, starts_at, ends_at, intents, flight_number)
                    values ('ZRH', now() + interval '4 days', now() + interval '4 days 1 hour', array['coffee'], 'LX-318!') $$,
  '23514', null, 'Ungültige Flugnummer abgelehnt');

select lives_ok($$ update public.presences set cancelled_at = now() where starts_at = now() $$, 'Eigenes Zeitfenster abbrechen');
select lives_ok($$ insert into public.presences (airport_iata, starts_at, ends_at, intents)
                   values ('ZRH', now() + interval '30 minutes', now() + interval '2 hours', array['coffee']) $$,
  'Nach Abbruch neues Zeitfenster im selben Zeitraum möglich');
select throws_ok($$ update public.presences set starts_at = now() + interval '1 hour' $$, '42501', null, 'Startzeit nachträglich nicht änderbar');
select throws_ok(format($q$ insert into public.presences (profile_id, airport_iata, starts_at, ends_at, intents)
                           values (%L, 'ZRH', now() + interval '5 days', now() + interval '5 days 1 hour', array['coffee']) $q$, :'v'),
  '42501', null, 'Kein Zeitfenster für andere Person anlegen');

reset role;
update public.profiles set status = 'suspended' where id = :'u';
select tests.login_as(:'u');
select throws_ok($$ insert into public.presences (airport_iata, starts_at, ends_at, intents)
                    values ('ZRH', now() + interval '6 days', now() + interval '6 days 1 hour', array['coffee']) $$,
  'P0001', 'account_inactive', 'Gesperrtes Konto: keine neuen Zeitfenster');
select lives_ok($$ update public.presences set cancelled_at = now() where cancelled_at is null $$, 'Gesperrtes Konto kann Zeitfenster beenden');

select * from finish();
rollback;
