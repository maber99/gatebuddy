-- Testdaten NUR für die lokale Entwicklung (supabase db reset). Niemals in Produktion.
-- Fiktive Personen mit Zeitfenstern in ZRH, damit die App lokal nicht leer ist.

insert into auth.users (id, email) values
  ('11111111-1111-4111-8111-111111111111', 'test.lena@example.invalid'),
  ('22222222-2222-4222-8222-222222222222', 'test.tomas@example.invalid'),
  ('33333333-3333-4333-8333-333333333333', 'test.amira@example.invalid'),
  ('44444444-4444-4444-8444-444444444444', 'test.kenji@example.invalid')
on conflict (id) do nothing;

insert into public.profiles (id, display_name, bio, is_adult_confirmed, terms_version, photo_visibility) values
  ('11111111-1111-4111-8111-111111111111', 'Lena (Test)',  'Umsteigen nach Lissabon, 3 Stunden Zeit.', true, 'dev', 'airport'),
  ('22222222-2222-4222-8222-222222222222', 'Tomás (Test)', 'Unterwegs zu einer Messe, gerne Networking.', true, 'dev', 'matches'),
  ('33333333-3333-4333-8333-333333333333', 'Amira (Test)', 'Ich übe Deutsch und spreche Arabisch.', true, 'dev', 'matches'),
  ('44444444-4444-4444-8444-444444444444', 'Kenji (Test)', null, true, 'dev', 'airport')
on conflict (id) do nothing;

insert into public.profile_languages (profile_id, language_code, mode) values
  ('11111111-1111-4111-8111-111111111111', 'de', 'speaks'), ('11111111-1111-4111-8111-111111111111', 'pt', 'learns'),
  ('22222222-2222-4222-8222-222222222222', 'es', 'speaks'), ('22222222-2222-4222-8222-222222222222', 'en', 'speaks'),
  ('33333333-3333-4333-8333-333333333333', 'ar', 'speaks'), ('33333333-3333-4333-8333-333333333333', 'de', 'learns'),
  ('44444444-4444-4444-8444-444444444444', 'ja', 'speaks'), ('44444444-4444-4444-8444-444444444444', 'en', 'speaks')
on conflict do nothing;

insert into public.profile_interests (profile_id, interest_code) values
  ('11111111-1111-4111-8111-111111111111', 'books'), ('11111111-1111-4111-8111-111111111111', 'hiking'),
  ('22222222-2222-4222-8222-222222222222', 'startups'), ('22222222-2222-4222-8222-222222222222', 'technology'),
  ('33333333-3333-4333-8333-333333333333', 'languages'),
  ('44444444-4444-4444-8444-444444444444', 'aviation'), ('44444444-4444-4444-8444-444444444444', 'photography')
on conflict do nothing;

insert into public.presences (profile_id, airport_iata, starts_at, ends_at, intents) values
  ('11111111-1111-4111-8111-111111111111', 'ZRH', now(), now() + interval '3 hours', array['coffee', 'language_practice']),
  ('22222222-2222-4222-8222-222222222222', 'ZRH', now(), now() + interval '2 hours', array['business_networking', 'coffee']),
  ('33333333-3333-4333-8333-333333333333', 'ZRH', now() + interval '1 day', now() + interval '1 day 3 hours', array['language_practice']),
  ('44444444-4444-4444-8444-444444444444', 'ZRH', now(), now() + interval '90 minutes', array['travel_stories', 'casual_chat']);
