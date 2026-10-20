# CLAUDE.md – Arbeitsregeln für Claude Code im GateBuddy-Repository

Lies diese Datei und `docs/GATEBUDDY_MASTER_CONTEXT.md` zu Beginn jeder Sitzung.

## Rollen
- **Gründer (Marco):** entscheidet, programmiert nicht. Kommunikation auf Deutsch, verständlich, ohne unnötigen Fachjargon.
- **Claude:** entwickelt, testet, dokumentiert eigenständig.

## Freigabepflichtig (vorher fragen, nie eigenmächtig)
- Kostenpflichtige Dienste oder Buchungen
- Veröffentlichung (App Stores, Produktion, öffentliche Webseiten)
- Änderungen an Produktionsdaten oder Produktionsdatenbank
- Sicherheitskritische Änderungen: Zugriffsregeln (RLS), Login, Datenlöschung, Moderation
- Neue grundlegende Architekturentscheidungen oder Abhängigkeiten
- Rechtstexte (AGB, Datenschutz) – Entwürfe ja, Veröffentlichung nein

## Entschiedener Rahmen (siehe `docs/DECISIONS.md`)
- React Native + Expo + TypeScript (`apps/mobile`)
- Supabase (PostgreSQL, Auth, Realtime, Storage, Edge Functions), Region Frankfurt (`supabase/`)
- Startflughafen ausschliesslich ZRH; Mindestalter 18
- Profilbild: Nutzer wählt „alle am Flughafen“ oder „erst nach Match“ (Standard)
- Ablehnungen sind für die andere Person nie sichtbar; Chat nur nach Match
- Keine exakten Standorte speichern oder anzeigen; keine Gate-Erkennung

## Arbeitsablauf
1. Aufgabe als GitHub-Issue mit Akzeptanzkriterien.
2. Eigener Branch `feat/…`, `fix/…`, `docs/…`.
3. Code **und Tests** im selben Pull Request. Keine Funktion ohne Test.
4. Lokal prüfen: `npm run check` (Typen, Lint, Unit-Tests) und `npm run test:db` (Datenbank + Zugriffsregeln).
5. `CHANGELOG.md` und bei Bedarf `docs/TESTING.md` aktualisieren.
6. PR-Beschreibung in einfacher Sprache: Was, Warum, Wie getestet, Status.

## Statuskennzeichnung (immer verwenden)
`Implementiert` · `Erfolgreich getestet` · `Noch nicht getestet` · `Bekanntes Problem` · `Geplant`
Niemals behaupten, dass etwas funktioniert, ohne dass ein Test oder eine Prüfung es belegt.

## Code-Konventionen
- TypeScript strikt, keine `any` ohne Begründung.
- Alle sichtbaren Texte über i18n (`apps/mobile/src/i18n`), Deutsch + Englisch.
- Datenbankänderungen nur als neue Datei in `supabase/migrations/` – bestehende Migrationen nie verändern, sobald sie in Produktion sind.
- Jede Tabelle hat Row Level Security aktiviert und Tests für „darf“ und „darf nicht“.
- Keine Schlüssel, Passwörter oder Tokens im Code; nur `.env` (nicht eingecheckt) und `.env.example`.
- Keine echten Personendaten in Tests oder Seeds.
- Zeiten in der Datenbank als `timestamptz` (UTC); Anzeige in Ortszeit des Flughafens.

## Datenschutz-Grundsätze
- Standort: nur Flughafen-Code + Zeitfenster + „bestätigt ja/nein“, nie Koordinaten.
- Daten minimal halten; jede neue personenbezogene Spalte in `docs/PRIVACY.md` begründen.
- Keine Weitergabe personenbezogener Daten an Partner.
