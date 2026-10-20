-- Matching: Kandidaten, Reihenfolge, stille Ablehnung, gegenseitiges Interesse
begin;
\ir helpers/test_helpers.psql
select plan(20);

select tests.new_user('Anna',  array['de','en'], array['es'], array['books','hiking']) as a \gset
select tests.new_user('Ben',   array['es','en'], array['de'], array['books']) as b \gset
select tests.new_user('Cleo',  array['fr'], array[]::text[], array[]::text[], 'airport') as c \gset
select tests.new_user('Dario') as d \gset
select tests.new_user('Emil')  as e \gset
select tests.new_user('Fiona') as f \gset
select tests.new_user('Greta') as g \gset
select tests.new_user('Hugo')  as h \gset

select tests.add_presence(:'a', interval '0', interval '2 hours', array['coffee','language_practice']) as pa \gset
select tests.add_presence(:'b', interval '0', interval '3 hours', array['language_practice','coffee']) as pb \gset
select tests.add_presence(:'c', interval '0', interval '2 hours', array['business_networking']) as pc \gset
select tests.add_presence(:'d', interval '0', interval '2 hours') as pd \gset
select tests.add_presence(:'e', interval '1 day', interval '2 hours');                 -- keine Überschneidung
select tests.add_presence(:'f', interval '110 minutes', interval '1 hour');            -- nur 10 Minuten gemeinsam
select tests.add_presence(:'g');
select tests.add_presence(:'h');
insert into public.blocks (blocker_id, blocked_id) values (:'a', :'g');
update public.profiles set status = 'suspended' where id = :'h';
select tests.open_tap_tables();

-- Dario wählt bei Anna "Weiter"
select tests.login_as(:'d');
select is((select is_match from public.react(:'a', 'pass')), false, '"Weiter" erzeugt kein Match');

select tests.login_as(:'a');
select set_eq(format('select profile_id from public.discover_candidates(%L)', :'pa'), array[:'b', :'c']::uuid[],
  'Kandidaten: nur passende, aktive, nicht blockierte Personen mit >= 15 Min. gemeinsamer Zeit; wer "Weiter" gewählt hat, wird ausgeblendet');
select is((select profile_id from public.discover_candidates(:'pa') limit 1), :'b'::uuid, 'Beste Übereinstimmung zuerst');
select is((select shared_intents from public.discover_candidates(:'pa') where profile_id = :'b'),
  array['coffee','language_practice'], 'Gemeinsame Kontaktinteressen');
select is((select score from public.discover_candidates(:'pa') where profile_id = :'b'), 119,
  'Punktwert nachvollziehbar: 2x30 Interessen + 20 + 20 Sprachtausch + 10 gemeinsame Sprache + 5 Interesse + 4 Zeit');
select is((select avatar_path from public.discover_candidates(:'pa') where profile_id = :'b'), null,
  'Bild bei "erst nach Match" vor dem Match verborgen');
select isnt((select avatar_path from public.discover_candidates(:'pa') where profile_id = :'c'), null,
  'Bild bei "für alle am Flughafen" sichtbar');
select throws_ok(format('select * from public.discover_candidates(%L)', :'pb'), 'P0001', 'presence_not_found',
  'Fremdes Zeitfenster kann nicht verwendet werden');
select is((select is_match from public.react(:'d', 'interested')), false,
  'Interesse an jemandem, der "Weiter" gewählt hat: Antwort identisch zu "noch offen" (keine Ablehnung erkennbar)');

select is((select is_match from public.react(:'b', 'interested')), false, 'Einseitiges Interesse: noch kein Match');
select throws_ok(format('select * from public.react(%L, %L)', :'b', 'interested'), 'P0001', 'already_reacted', 'Keine doppelte Reaktion');
select throws_ok(format('select * from public.react(%L, %L)', :'e', 'interested'), 'P0001', 'not_available', 'Ohne Zeitüberschneidung keine Reaktion');
select throws_ok(format('select * from public.react(%L, %L)', :'a', 'interested'), 'P0001', 'not_available', 'Keine Reaktion auf sich selbst');
select throws_ok(format('select * from public.react(%L, %L)', :'g', 'interested'), 'P0001', 'not_available', 'Keine Reaktion bei Blockierung');

select tests.login_as(:'b');
select is((select is_match from public.react(:'a', 'interested')), true, 'Gegenseitiges Interesse: Match');
select tests.login_as(:'a');
select is((select count(*)::integer from public.matches), 1, 'Match für beide sichtbar');
select set_eq(format('select profile_id from public.discover_candidates(%L)', :'pa'), array[:'c']::uuid[],
  'Gematchte Person erscheint nicht erneut als Kandidat');

-- Stille Ablehnung: Anna wählt bei Cleo "Weiter"
select is((select is_match from public.react(:'c', 'pass')), false, 'Anna wählt "Weiter" bei Cleo');
select tests.login_as(:'c');
select is((select count(*)::integer from public.reactions where to_profile = :'c'), 0, 'Cleo kann Reaktionen anderer auf sie nicht sehen');
select ok(not exists (select 1 from public.discover_candidates(:'pc') where profile_id = :'a'),
  'Wer "Weiter" gewählt hat, taucht bei der anderen Person einfach nicht auf');

select * from finish();
rollback;
