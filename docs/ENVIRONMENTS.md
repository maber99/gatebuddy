# GATEBUDDY – UMGEBUNGEN UND ZUGÄNGE

> Stand: 23.10.2026 · Enthält **keine** Geheimnisse. Passwörter, Datenbankpasswörter und Zugangsschlüssel gehören nur in den Passwort-Manager des Gründers bzw. in GitHub-Secrets.

## Supabase

| Umgebung | Projekt | Projekt-Ref | Region | Plan | Status |
|---|---|---|---|---|---|
| Entwicklung | `gatebuddy-dev` | `hdggnxwvvgeoxxkqstux` | eu-central-1 (Frankfurt) | Free | Aktiv, angelegt 23.10.2026 |
| Produktion | – | – | Frankfurt | Pro (ab 25 USD/Monat) | **Noch nicht angelegt** – Entscheidung vor Beta |

- Organisation: `gatebuddy` (Free-Plan), Inhaber: Gründer
- Öffentliche API-URL (Entwicklung): `https://hdggnxwvvgeoxxkqstux.supabase.co`
- Die App nutzt nur den öffentlichen „publishable key“ (in `apps/mobile/.env`, nicht im Repository).
- Claude hat Zugriff über den offiziellen Supabase-Connector, beschränkt auf die Organisation `gatebuddy`. Widerruf jederzeit in claude.ai → Connectors oder in Supabase.

### Migrationsstand `gatebuddy-dev`

| Repository-Datei | In Supabase | Hinweis |
|---|---|---|
| `20261020120000_core_schema.sql` | ✅ eingespielt 23.10.2026 | |
| `20261020120100_rules_and_access.sql` | ✅ eingespielt 23.10.2026 | |
| `20261020120200_app_functions.sql` | ✅ eingespielt 23.10.2026 | |
| `20261020120250_app_functions_with_deletes.sql` | ⏳ **offen** | Enthält Löschbefehle in Funktionen → Supabase verlangt Bestätigung; durch Gründer im SQL-Editor einzuspielen |
| `20261020120300_reference_data_storage_realtime.sql` | ✅ eingespielt 23.10.2026 | |
| `20261023120000_advisor_hardening.sql` | ⏳ **wartet auf Freigabe** | Ändert Zugriffsregeln technisch (nicht inhaltlich) |

Hinweis: Supabase vergibt beim Einspielen über den Connector eigene Versionsnummern (Datum des Einspielens). Vor dem ersten Einsatz der Supabase CLI gegen dieses Projekt muss die Historie mit `supabase migration repair` abgeglichen werden.

### Überprüfung nach dem Einspielen (23.10.2026)
- Struktur-Vergleich mit der lokal getesteten Datenbank: Funktionscode, Zugriffsregeln, Rechte, Spalten, Bedingungen, Trigger, Stammdaten, Speicher und Echtzeit **identisch**.
- Funktionsprobe direkt in Supabase (zwei fiktive Personen, Ablauf ohne Speicherung): Sichtbarkeit, Kandidaten, Punktwert, Match, Nachricht, unsichtbare Reaktionen, Besucher-Sperre **wie erwartet**.

## GitHub
- Repository: `maber99/gatebuddy` (privat) – **noch nicht angelegt/verbunden**

## Expo
- Konto vorhanden (über GitHub). Noch nicht mit dem Projekt verknüpft. Zugangsschlüssel später nur als GitHub-Secret.
