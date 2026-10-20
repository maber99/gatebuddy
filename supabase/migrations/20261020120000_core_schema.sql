-- GateBuddy – Kernschema
-- Grundsätze: Datensparsamkeit, keine Koordinaten, Zeit in UTC (timestamptz).

create extension if not exists btree_gist with schema extensions;

create schema if not exists private;
comment on schema private is 'Interne Hilfsfunktionen. Nicht über die API erreichbar.';

-- ---------------------------------------------------------------------------
-- Aufzählungstypen
-- ---------------------------------------------------------------------------
create type public.language_mode     as enum ('speaks', 'learns');
create type public.photo_visibility  as enum ('airport', 'matches');
create type public.reaction_kind     as enum ('interested', 'pass');
create type public.account_status    as enum ('active', 'suspended', 'banned');
create type public.report_reason     as enum ('harassment', 'spam', 'inappropriate', 'underage', 'fake_profile', 'safety_concern', 'other');
create type public.report_status     as enum ('open', 'actioned', 'dismissed');
create type public.moderation_action as enum ('dismiss', 'warn', 'suspend', 'ban', 'reinstate', 'delete_message');
create type public.device_platform   as enum ('ios', 'android');

-- ---------------------------------------------------------------------------
-- Kataloge
-- ---------------------------------------------------------------------------
create table public.airports (
  iata          char(3) primary key check (iata ~ '^[A-Z]{3}$'),
  name          text not null,
  city          text not null,
  country_code  char(2) not null check (country_code ~ '^[A-Z]{2}$'),
  timezone      text not null,
  -- Mittelpunkt + Radius für die einmalige Standortprüfung auf dem Gerät.
  -- Es werden NIE Nutzerkoordinaten gespeichert.
  center_lat    double precision not null check (center_lat between -90 and 90),
  center_lon    double precision not null check (center_lon between -180 and 180),
  radius_m      integer not null check (radius_m between 200 and 10000),
  is_active     boolean not null default false
);
comment on column public.airports.is_active is 'Nur aktive Flughäfen erlauben Zeitfenster. Start: ausschliesslich ZRH (ADR-005).';

create table public.intents (
  code        text primary key check (code ~ '^[a-z_]{2,40}$'),
  sort_order  smallint not null default 0
);
comment on table public.intents is 'Kontaktinteressen (z. B. Kaffee, Networking). Übersetzungen liegen in der App.';

create table public.interests (
  code        text primary key check (code ~ '^[a-z_]{2,40}$'),
  category    text not null check (category ~ '^[a-z_]{2,40}$'),
  sort_order  smallint not null default 0
);

-- ---------------------------------------------------------------------------
-- Profile
-- ---------------------------------------------------------------------------
create table public.profiles (
  id                  uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  display_name        text not null check (char_length(btrim(display_name)) between 1 and 30),
  bio                 text check (bio is null or char_length(bio) <= 300),
  avatar_path         text,
  photo_visibility    public.photo_visibility not null default 'matches',
  is_adult_confirmed  boolean not null check (is_adult_confirmed),
  terms_version       text not null check (char_length(terms_version) between 1 and 20),
  terms_accepted_at   timestamptz not null default now(),
  status              public.account_status not null default 'active',
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  constraint profiles_avatar_in_own_folder check (
    avatar_path is null
    or (split_part(avatar_path, '/', 1) = id::text and avatar_path ~ '^[0-9a-f-]{36}/[A-Za-z0-9._-]{1,100}$')
  )
);
comment on column public.profiles.photo_visibility is 'ADR-007: Nutzer wählt. airport = für passende Personen am Flughafen sichtbar, matches = erst nach Match (Standard).';
comment on column public.profiles.is_adult_confirmed is 'ADR-006: Selbstbestätigung 18+. Kein Geburtsdatum gespeichert (Datensparsamkeit).';

create table public.profile_languages (
  profile_id     uuid not null references public.profiles (id) on delete cascade,
  language_code  text not null check (language_code ~ '^[a-z]{2,3}$'),
  mode           public.language_mode not null,
  primary key (profile_id, language_code, mode)
);
comment on column public.profile_languages.language_code is 'ISO-639-Sprachcode, z. B. de, en, fr.';

create table public.profile_interests (
  profile_id     uuid not null references public.profiles (id) on delete cascade,
  interest_code  text not null references public.interests (code),
  primary key (profile_id, interest_code)
);

-- ---------------------------------------------------------------------------
-- Zeitfenster am Flughafen ("Präsenz")
-- ---------------------------------------------------------------------------
create table public.presences (
  id                 uuid primary key default gen_random_uuid(),
  profile_id         uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  airport_iata       char(3) not null references public.airports (iata),
  starts_at          timestamptz not null,
  ends_at            timestamptz not null,
  intents            text[] not null check (cardinality(intents) between 1 and 6),
  location_verified  boolean not null default false,
  flight_number      text check (flight_number is null or flight_number ~ '^([A-Z0-9]{2}|[A-Z]{3})[0-9]{1,4}[A-Z]?$'),
  cancelled_at       timestamptz,
  created_at         timestamptz not null default now(),
  constraint presences_time_order   check (ends_at > starts_at),
  constraint presences_max_duration check (ends_at - starts_at <= interval '6 hours'),
  constraint presences_no_overlap exclude using gist (
    profile_id with =,
    tstzrange(starts_at, ends_at, '[)') with &&
  ) where (cancelled_at is null)
);
comment on table public.presences is 'Zeitfenster, in dem jemand am Flughafen ansprechbar ist. Läuft automatisch ab (ends_at). ADR-010.';
comment on column public.presences.flight_number is 'Freiwillig, jederzeit änderbar, KEIN Buchungsnachweis. Für andere Nutzer nicht sichtbar.';
comment on column public.presences.location_verified is 'Ergebnis einer einmaligen Geräteprüfung. Keine Koordinaten gespeichert (ADR-009).';

create index presences_airport_active_idx on public.presences (airport_iata, ends_at) where cancelled_at is null;

-- ---------------------------------------------------------------------------
-- Interesse, Matches, Chat
-- ---------------------------------------------------------------------------
create table public.reactions (
  from_profile  uuid not null references public.profiles (id) on delete cascade,
  to_profile    uuid not null references public.profiles (id) on delete cascade,
  kind          public.reaction_kind not null,
  created_at    timestamptz not null default now(),
  primary key (from_profile, to_profile),
  check (from_profile <> to_profile)
);
comment on table public.reactions is '"Interesse" oder "Weiter". Für die andere Person NIE lesbar (stille Ablehnung).';
create index reactions_to_profile_idx on public.reactions (to_profile);

create table public.matches (
  id            uuid primary key default gen_random_uuid(),
  profile_a     uuid not null references public.profiles (id) on delete cascade,
  profile_b     uuid not null references public.profiles (id) on delete cascade,
  airport_iata  char(3) not null references public.airports (iata),
  created_at    timestamptz not null default now(),
  closed_at     timestamptz,
  check (profile_a < profile_b),
  unique (profile_a, profile_b)
);
create index matches_profile_b_idx on public.matches (profile_b);

create table public.messages (
  id          uuid primary key default gen_random_uuid(),
  match_id    uuid not null references public.matches (id) on delete cascade,
  sender_id   uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  body        text not null check (char_length(btrim(body)) between 1 and 2000),
  created_at  timestamptz not null default now()
);
create index messages_match_created_idx on public.messages (match_id, created_at);
create index messages_sender_created_idx on public.messages (sender_id, created_at);

create table public.meet_feedback (
  match_id    uuid not null references public.matches (id) on delete cascade,
  profile_id  uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  met         boolean not null,
  created_at  timestamptz not null default now(),
  primary key (match_id, profile_id)
);
comment on table public.meet_feedback is 'Antwort auf "Habt ihr euch getroffen?" – zentrale Erfolgskennzahl.';

-- ---------------------------------------------------------------------------
-- Sicherheit & Moderation
-- ---------------------------------------------------------------------------
create table public.blocks (
  blocker_id  uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  blocked_id  uuid not null references public.profiles (id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);
create index blocks_blocked_idx on public.blocks (blocked_id);

create table public.reports (
  id                   uuid primary key default gen_random_uuid(),
  reporter_id          uuid references public.profiles (id) on delete set null,
  reported_profile_id  uuid references public.profiles (id) on delete set null,
  message_id           uuid references public.messages (id) on delete set null,
  message_excerpt      text,
  reason               public.report_reason not null,
  details              text check (details is null or char_length(details) <= 1000),
  status               public.report_status not null default 'open',
  created_at           timestamptz not null default now(),
  resolved_at          timestamptz,
  resolved_by          uuid references public.profiles (id) on delete set null
);
comment on column public.reports.message_excerpt is 'Kopie der gemeldeten Nachricht zur Beweissicherung.';
create index reports_open_idx on public.reports (status, created_at) where status = 'open';
create index reports_target_idx on public.reports (reported_profile_id, created_at);

create table public.moderation_actions (
  id                 uuid primary key default gen_random_uuid(),
  report_id          uuid references public.reports (id) on delete set null,
  target_profile_id  uuid references public.profiles (id) on delete set null,
  action             public.moderation_action not null,
  note               text,
  admin_id           uuid references public.profiles (id) on delete set null,
  is_automatic       boolean not null default false,
  created_at         timestamptz not null default now()
);

create table public.admins (
  profile_id  uuid primary key references public.profiles (id) on delete cascade,
  created_at  timestamptz not null default now()
);
comment on table public.admins is 'Moderationsberechtigte. Pflege nur durch den Gründer direkt in der Datenbank.';

create table private.blocked_terms (
  term        text primary key check (char_length(term) between 2 and 100),
  created_at  timestamptz not null default now()
);
comment on table private.blocked_terms is 'Wortfilter (Kleinschreibung). Pflege durch Moderation; bewusst leer ausgeliefert.';

-- ---------------------------------------------------------------------------
-- Technik & Nachfrage
-- ---------------------------------------------------------------------------
create table public.devices (
  id               uuid primary key default gen_random_uuid(),
  profile_id       uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  expo_push_token  text not null unique check (expo_push_token ~ '^Expo(nent)?PushToken\[[^\]]+\]$'),
  platform         public.device_platform not null,
  created_at       timestamptz not null default now(),
  last_seen_at     timestamptz not null default now()
);

create table public.airport_interest (
  profile_id    uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  airport_iata  char(3) not null references public.airports (iata),
  created_at    timestamptz not null default now(),
  primary key (profile_id, airport_iata)
);
comment on table public.airport_interest is '"Bitte auch an Flughafen X" – misst Nachfrage für den zweiten Standort.';
