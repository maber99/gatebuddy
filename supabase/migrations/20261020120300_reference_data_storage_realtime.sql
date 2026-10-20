-- GateBuddy – Stammdaten, Profilbild-Speicher, Echtzeit

-- ---------------------------------------------------------------------------
-- Flughäfen
-- Koordinaten = ungefährer Flughafen-Bezugspunkt, Radius grosszügig.
-- [ANNAHME] Vor Aktivierung eines Flughafens im Feldtest prüfen (docs/ROADMAP.md, Phase 8).
-- Nur ZRH ist aktiv (ADR-005). Die übrigen dienen der Nachfragemessung ("bald verfügbar").
-- ---------------------------------------------------------------------------
insert into public.airports (iata, name, city, country_code, timezone, center_lat, center_lon, radius_m, is_active) values
  ('ZRH', 'Flughafen Zürich',            'Zürich',    'CH', 'Europe/Zurich', 47.4647, 8.5492, 3000, true),
  ('MUC', 'Flughafen München',           'München',   'DE', 'Europe/Berlin', 48.3538, 11.7861, 3500, false),
  ('FRA', 'Flughafen Frankfurt',         'Frankfurt', 'DE', 'Europe/Berlin', 50.0333, 8.5706, 3500, false),
  ('GVA', 'Aéroport de Genève',          'Genève',    'CH', 'Europe/Zurich', 46.2381, 6.1090, 2500, false),
  ('BSL', 'EuroAirport Basel-Mulhouse',  'Basel',     'FR', 'Europe/Zurich', 47.5896, 7.5299, 2500, false),
  ('VIE', 'Flughafen Wien',              'Wien',      'AT', 'Europe/Vienna', 48.1103, 16.5697, 3000, false)
on conflict (iata) do nothing;

-- ---------------------------------------------------------------------------
-- Kontaktinteressen (vom Gründer festgelegte Beispiele)
-- ---------------------------------------------------------------------------
insert into public.intents (code, sort_order) values
  ('coffee', 10),
  ('casual_chat', 20),
  ('business_networking', 30),
  ('language_practice', 40),
  ('meet_people', 50),
  ('travel_stories', 60)
on conflict (code) do nothing;

-- ---------------------------------------------------------------------------
-- Interessen (Vorschlag, durch Gründer anpassbar)
-- ---------------------------------------------------------------------------
insert into public.interests (code, category, sort_order) values
  ('aviation', 'travel', 10), ('backpacking', 'travel', 20), ('city_trips', 'travel', 30), ('nature_travel', 'travel', 40),
  ('technology', 'work', 110), ('startups', 'work', 120), ('business', 'work', 130), ('design', 'work', 140),
  ('science', 'work', 150), ('education', 'work', 160), ('healthcare', 'work', 170), ('sustainability', 'work', 180),
  ('books', 'culture', 210), ('film', 'culture', 220), ('music', 'culture', 230), ('art', 'culture', 240),
  ('history', 'culture', 250), ('photography', 'culture', 260),
  ('food', 'lifestyle', 310), ('sports', 'lifestyle', 320), ('running', 'lifestyle', 330), ('hiking', 'lifestyle', 340),
  ('gaming', 'lifestyle', 350), ('languages', 'lifestyle', 360)
on conflict (code) do nothing;

-- ---------------------------------------------------------------------------
-- Profilbilder: privater Speicher, Pfad "<profil-id>/<datei>"
-- Lesen nur, wenn private.can_view_avatar() es erlaubt (ADR-007).
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('avatars', 'avatars', false, 2097152, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

create policy avatars_read on storage.objects for select to authenticated
  using (
    bucket_id = 'avatars'
    and private.can_view_avatar(auth.uid(), private.try_uuid((storage.foldername(name))[1]))
  );
create policy avatars_insert_own on storage.objects for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);
create policy avatars_update_own on storage.objects for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);
create policy avatars_delete_own on storage.objects for delete to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

-- ---------------------------------------------------------------------------
-- Echtzeit für Chat und neue Matches (respektiert die Zugriffsregeln)
-- ---------------------------------------------------------------------------
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.messages, public.matches;
  end if;
end $$;
