-- Melden, automatische Sperre, Moderation
begin;
\ir helpers/test_helpers.psql
select plan(18);

select tests.new_user('Anna') as a \gset
select tests.new_user('Bodo') as b \gset
select tests.new_user('Rita') as r1 \gset
select tests.new_user('Rolf') as r2 \gset
select tests.new_user('Rosa') as r3 \gset
select tests.new_user('Emil') as e \gset
select tests.new_user('Zora (Moderation)') as z \gset
select tests.add_presence(:'a');
select tests.add_presence(:'b');
select tests.add_presence(:'r1');
select tests.add_presence(:'r2');
select tests.add_presence(:'r3');
select tests.add_presence(:'e', interval '5 days');
insert into public.admins (profile_id) values (:'z');
insert into public.matches (profile_a, profile_b, airport_iata)
  values (least(:'a'::uuid, :'b'::uuid), greatest(:'a'::uuid, :'b'::uuid), 'ZRH') returning id as m \gset
insert into public.messages (match_id, sender_id, body) values (:'m', :'b', 'Beleidigende Nachricht') returning id as msg \gset
select tests.open_tap_tables();

select tests.login_as(:'a');
select public.submit_report(:'b', 'harassment', 'Hat mich bedrängt') as rep1 \gset
select isnt(:'rep1'::uuid, null, 'Profil melden');
select is(public.submit_report(:'b', 'harassment', 'Nochmal'), :'rep1'::uuid, 'Doppelte Meldung innerhalb 24 h wird zusammengefasst');
select is((select count(*)::integer from public.reports), 0, 'Nutzer können Meldungen nicht lesen');
select throws_ok(format('select public.submit_report(%L, %L)', :'e', 'spam'), 'P0001', 'not_available', 'Nur Personen melden, mit denen Kontakt möglich war');
select throws_ok(format('select public.submit_report(%L, %L)', :'a', 'spam'), 'P0001', 'not_available', 'Sich selbst melden nicht möglich');
select public.submit_report(:'b', 'inappropriate', null, :'msg') as rep_msg \gset
reset role;
select is((select message_excerpt from public.reports where id = :'rep_msg'), 'Beleidigende Nachricht', 'Gemeldete Nachricht wird als Beweis gesichert');
select tests.login_as(:'r1');
select throws_ok(format('select public.submit_report(%L, %L, null, %L)', :'b', 'spam', :'msg'), 'P0001', 'message_not_found',
  'Nachrichten aus fremden Chats nicht meldbar');

select public.submit_report(:'b', 'spam');
reset role;
select is((select status::text from public.profiles where id = :'b'), 'active', 'Zwei meldende Personen: noch keine automatische Sperre');
select tests.login_as(:'r2');
select public.submit_report(:'b', 'spam');
reset role;
select is((select status::text from public.profiles where id = :'b'), 'suspended', 'Drei verschiedene meldende Personen in 7 Tagen: vorläufige Sperre');
select is((select count(*)::integer from public.moderation_actions where target_profile_id = :'b' and is_automatic), 1, 'Automatische Sperre wird protokolliert');

select tests.login_as(:'r3');
select is((select count(*)::integer from public.profiles where id = :'b'), 0, 'Gesperrtes Konto für andere unsichtbar');
select tests.login_as(:'b');
select throws_ok(format('insert into public.messages (match_id, body) values (%L, %L)', :'m', 'Hallo?'), '42501', null, 'Gesperrtes Konto kann nicht schreiben');

select tests.login_as(:'a');
select throws_ok($$ select * from public.admin_open_reports() $$, '42501', 'forbidden', 'Moderationsansicht nur für Admins');
select tests.login_as(:'z');
select is((select count(*)::integer from public.admin_open_reports()), 4, 'Admin sieht alle offenen Meldungen');
select is(public.admin_resolve_report(:'rep1', 'reinstate', 'Geprüft, kein Verstoss'), true, 'Admin hebt Sperre auf');
reset role;
select is((select status::text from public.profiles where id = :'b'), 'active', 'Konto wieder aktiv');
select tests.login_as(:'z');
select public.admin_resolve_report(:'rep_msg', 'delete_message', 'Beleidigung entfernt');
reset role;
select is((select count(*)::integer from public.messages where id = :'msg'), 0, 'Admin entfernt gemeldete Nachricht');
select tests.login_as(:'z');
select is((select presences from public.admin_metrics('ZRH', now() - interval '1 day', now() + interval '30 days')), 6, 'Kennzahlen für Go/No-Go abrufbar');

select * from finish();
rollback;
