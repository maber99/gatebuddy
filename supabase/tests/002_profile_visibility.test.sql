-- Wer darf welches Profil sehen und ändern?
begin;
\ir helpers/test_helpers.psql
select plan(21);

select tests.new_user('Anna') as a \gset
select tests.new_user('Ben', array['es']) as b \gset
select tests.new_user('Cleo') as c \gset
select tests.add_presence(:'a');
select tests.add_presence(:'b');
select tests.add_presence(:'c', interval '3 days');
select tests.open_tap_tables();

select tests.login_as(:'a');
select is((select count(*)::integer from public.profiles where id = :'a'), 1, 'Eigenes Profil sichtbar');
select is((select count(*)::integer from public.profiles where id = :'b'), 1, 'Profil bei Zeitüberschneidung sichtbar');
select is((select count(*)::integer from public.profiles where id = :'c'), 0, 'Profil ohne Zeitüberschneidung unsichtbar');
select is((select count(*)::integer from public.profile_languages where profile_id = :'b'), 1, 'Sprachen der passenden Person lesbar');
select is((select count(*)::integer from public.profile_languages where profile_id = :'c'), 0, 'Sprachen anderer nicht lesbar');
select is((select count(*)::integer from public.presences where profile_id = :'b'), 0, 'Zeitfenster anderer sind nie direkt lesbar');
select is((select count(*)::integer from public.presences where profile_id = :'a'), 1, 'Eigene Zeitfenster lesbar');

select lives_ok(format('update public.profiles set display_name = %L where id = %L', 'Anna B.', :'a'), 'Eigenen Namen ändern');
select lives_ok(format('update public.profiles set display_name = %L where id = %L', 'Gehackt', :'b'), 'Fremdes Profil ändern ...');
reset role;
select is((select display_name from public.profiles where id = :'b'), 'Ben', '... bleibt wirkungslos');

select tests.login_as(:'a');
select throws_ok($$ update public.profiles set status = 'banned' $$, '42501', null, 'Status kann nicht selbst gesetzt werden');
select throws_ok($$ select status from public.profiles $$, '42501', null, 'Statusspalte nicht lesbar');

select lives_ok(format('insert into public.blocks (blocked_id) values (%L)', :'b'), 'Blockieren');
select is((select count(*)::integer from public.profiles where id = :'b'), 0, 'Blockierte Person unsichtbar');
select tests.login_as(:'b');
select is((select count(*)::integer from public.profiles where id = :'a'), 0, 'Blockierende Person für Blockierten unsichtbar');
select tests.login_as(:'a');
delete from public.blocks where blocked_id = :'b';
select is((select count(*)::integer from public.profiles where id = :'b'), 1, 'Nach Aufheben wieder sichtbar');

reset role;
update public.profiles set status = 'suspended' where id = :'b';
select tests.login_as(:'a');
select is((select count(*)::integer from public.profiles where id = :'b'), 0, 'Gesperrte Konten unsichtbar');

select throws_ok($$ update public.profiles set bio = 'Mehr auf www.example.com' where id = auth.uid() $$,
  'P0001', 'links_not_allowed', 'Keine Links im Profil');
reset role;
insert into private.blocked_terms (term) values ('verbotenwort');
select tests.login_as(:'a');
select throws_ok($$ update public.profiles set display_name = 'xVerbotenWortx' where id = auth.uid() $$,
  'P0001', 'content_blocked', 'Wortfilter greift (unabhängig von Gross-/Kleinschreibung)');

reset role;
insert into auth.users (id, email) values ('00000000-0000-4000-8000-0000000000e1', 'neu@test.invalid');
select tests.login_as('00000000-0000-4000-8000-0000000000e1');
select throws_ok(format($q$ insert into public.profiles (id, display_name, is_adult_confirmed, terms_version)
                            values (%L, 'Fremd', true, 't') $q$, :'c'),
  '42501', null, 'Profil für fremde ID anlegen verboten');
select lives_ok($$ insert into public.profiles (display_name, is_adult_confirmed, terms_version) values ('Neu', true, 't') $$,
  'Eigenes Profil mit 18+-Bestätigung anlegen');

select * from finish();
rollback;
