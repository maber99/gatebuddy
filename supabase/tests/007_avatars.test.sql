-- Profilbilder: Sichtbarkeit nach Wahl der Person (ADR-007)
begin;
\ir helpers/test_helpers.psql
select plan(9);

select tests.new_user('Anna') as a \gset
select tests.new_user('Bea', array['de'], array[]::text[], array[]::text[], 'airport') as b \gset
select tests.new_user('Carl') as c \gset
select tests.new_user('Dora', array['de'], array[]::text[], array[]::text[], 'airport') as d \gset
select tests.add_presence(:'a');
select tests.add_presence(:'b');
select tests.add_presence(:'c');
select tests.add_presence(:'d', interval '4 days');
insert into storage.objects (bucket_id, name) values
  ('avatars', :'a' || '/avatar.jpg'), ('avatars', :'b' || '/avatar.jpg'), ('avatars', :'c' || '/avatar.jpg'),
  ('avatars', 'kein-uuid/x.jpg');
select tests.open_tap_tables();

select tests.login_as(:'a');
select is((select count(*)::integer from storage.objects where name like :'b' || '/%'), 1, '"Für alle am Flughafen": Bild für passende Person sichtbar');
select is((select count(*)::integer from storage.objects where name like :'c' || '/%'), 0, '"Erst nach Match": Bild vor dem Match verborgen');
reset role;
insert into public.matches (profile_a, profile_b, airport_iata)
  values (least(:'a'::uuid, :'c'::uuid), greatest(:'a'::uuid, :'c'::uuid), 'ZRH');
select tests.login_as(:'a');
select is((select count(*)::integer from storage.objects where name like :'c' || '/%'), 1, '"Erst nach Match": nach dem Match sichtbar');
select is((select count(*)::integer from storage.objects where name like :'a' || '/%'), 1, 'Eigenes Bild sichtbar');
select is((select count(*)::integer from storage.objects where name like 'kein-uuid/%'), 0, 'Ungültige Pfade führen zu keinem Fehler und sind unsichtbar');
select lives_ok(format('insert into storage.objects (bucket_id, name) values (%L, %L)', 'avatars', :'a' || '/neu.jpg'), 'Bild in eigenen Ordner hochladen');
select throws_ok(format('insert into storage.objects (bucket_id, name) values (%L, %L)', 'avatars', :'b' || '/fake.jpg'), '42501', null, 'Kein Upload in fremde Ordner');
select throws_ok(format('update public.profiles set avatar_path = %L where id = auth.uid()', :'b' || '/avatar.jpg'), '23514', null, 'Profil kann nicht auf fremdes Bild zeigen');

select tests.login_as(:'d');
select is((select count(*)::integer from storage.objects where name like :'b' || '/%'), 0, 'Ohne Zeitüberschneidung kein Bild – auch bei "für alle"');

select * from finish();
rollback;
