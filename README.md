# GateBuddy

Mobile App (iOS + Android), die Reisende am selben Flughafen bei beidseitigem Interesse miteinander verbindet – für Kaffee, Gespräche, Networking und Sprachpraxis. Keine Dating-App.

**Status:** Phase 3/4 – Grundgerüst und Datenbank im Aufbau. Noch nicht veröffentlicht. Startflughafen: Zürich (ZRH).

## Aufbau

| Ordner | Inhalt |
|---|---|
| `apps/mobile` | App (React Native, Expo, TypeScript) |
| `supabase` | Datenbank-Migrationen, Zugriffsregeln, Tests, Testdaten |
| `docs` | Strategie, Architektur, Roadmap, Entscheidungen, Testbericht |
| `scripts` | Hilfsskripte (z. B. lokale Testdatenbank) |
| `.github` | Automatische Prüfungen, Vorlagen |

## Wichtigste Dokumente
- [Master-Kontext](docs/GATEBUDDY_MASTER_CONTEXT.md) · [Entscheidungen](docs/DECISIONS.md) · [Roadmap](docs/ROADMAP.md) · [Testbericht](docs/TESTING.md) · [Arbeitsregeln für Claude Code](CLAUDE.md)

## Für Entwickler
```bash
npm install                 # Abhängigkeiten
npm run check               # Typen, Lint, Unit-Tests der App
npm run test:db             # Datenbank-Tests (benötigt lokales PostgreSQL 15+ mit pgTAP, siehe scripts/)
npm run mobile              # App im Entwicklungsmodus starten (Expo)
```
Mit Supabase CLI und Docker: `npx supabase start` und `npx supabase test db`.

Eigentum: Sämtlicher Code gehört dem Gründer. Alle Rechte vorbehalten.
