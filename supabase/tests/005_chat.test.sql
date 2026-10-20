-- Chat: nur nach Match, nur Beteiligte, Blockieren beendet sofort
begin;
\ir helpers/test_helpers.psql
select plan(16);

select tests.new_user('Anna') as a \gset
select tests.new_user('Ben')  as b \gset
select tests.new_user('Xaver') as x \gset
select tests.new_user('Clara') as c \gset
select tests.new_user('David') as d \gset
select tests.new_user('Elif') as e \gset
select tests.new_user('Finn') as f \gset
insert into public.matches (profile_a, profile_b, airport_iata)
  values (least(:'a'::uuid, :'b'::uuid), greatest(:'a'::uuid, :'b'::uuid), 'ZRH') returning id as m1 \gset
insert into public.matches (profile_a, profile_b, airport_iata)
  values (least(:'c'::uuid, :'d'::uuid), greatest(:'c'::uuid, :'d'::uuid), 'ZRH') returning id as m2 \gset
insert into public.matches (profile_a, profile_b, airport_iata)
  values (least(:'e'::uuid, :'f'::uuid), greatest(:'e'::uuid, :'f'::uuid), 'ZRH') returning id as m3 \gset
select tests.open_tap_tables();

select tests.login_as(:'a');
select lives_ok(format('insert into public.messages (match_id, body) values (%L, %L)', :'m1', 'Hallo! Kaffee bei Gate E?'), 'Nachricht im Match senden');
select tests.login_as(:'b');
select is((select count(*)::integer from public.messages where match_id = :'m1'), 1, 'Gegenüber liest die Nachricht');
select tests.login_as(:'x');
select is((select count(*)::integer from public.messages), 0, 'Unbeteiligte lesen nichts');
select throws_ok(format('insert into public.messages (match_id, body) values (%L, %L)', :'m1', 'Hi'), '42501', null, 'Unbeteiligte können nicht schreiben');

select tests.login_as(:'a');
select throws_ok(format('insert into public.messages (match_id, sender_id, body) values (%L, %L, %L)', :'m1', :'b', 'Fake'),
  '42501', null, 'Nicht im Namen anderer schreiben');
select is((select partner_id from public.my_matches() where match_id = :'m1'), :'b'::uuid, 'Match-Liste zeigt Gesprächspartner');
select is((select last_message_preview from public.my_matches() where match_id = :'m1'), 'Hallo! Kaffee bei Gate E?', 'Vorschau der letzten Nachricht');
select isnt((select partner_avatar_path from public.my_matches() where match_id = :'m1'), null, 'Nach Match ist das Bild sichtbar');

select tests.login_as(:'b');
select is(public.close_match(:'m1'), true, 'Match beenden');
select tests.login_as(:'a');
select throws_ok(format('insert into public.messages (match_id, body) values (%L, %L)', :'m1', 'Noch da?'), '42501', null, 'In beendetem Match nicht mehr schreiben');
select tests.login_as(:'b');
select is((select count(*)::integer from public.messages where match_id = :'m1'), 1, 'Verlauf bleibt für Beteiligte lesbar');

select tests.login_as(:'c');
insert into public.blocks (blocked_id) values (:'d');
reset role;
select isnt((select closed_at from public.matches where id = :'m2'), null, 'Blockieren schliesst das Match sofort');
select tests.login_as(:'d');
select throws_ok(format('insert into public.messages (match_id, body) values (%L, %L)', :'m2', 'Warum?'), '42501', null, 'Blockierte Person kann nicht mehr schreiben');

select tests.login_as(:'e');
select lives_ok(format($q$ insert into public.messages (match_id, body) select %L, 'Nachricht ' || g from generate_series(1, 20) g $q$, :'m3'),
  '20 Nachrichten pro Minute erlaubt');
select throws_ok(format('insert into public.messages (match_id, body) values (%L, %L)', :'m3', 'Nummer 21'), 'P0001', 'rate_limited', 'Spam-Schutz ab der 21. Nachricht pro Minute');

select ok(exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and tablename = 'messages'), 'Nachrichten werden in Echtzeit verteilt');

select * from finish();
rollback;
