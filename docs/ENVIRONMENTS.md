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
| `20261020120250_app_functions_with_deletes.sql` | ✅ eingespielt 23.10.2026 durch Gründer (SQL-Editor) | Inhalt identisch mit getesteter Version; nur Windows-Zeilenumbrüche (ohne Wirkung). Nicht in der Supabase-Migrationshistorie erfasst → bei `migration repair` berücksichtigen |
| `20261020120300_reference_data_storage_realtime.sql` | ✅ eingespielt 23.10.2026 | |
| `20261023120000_advisor_hardening.sql` | ✅ eingespielt 23.10.2026 (Freigabe Gründer) | Zugriffsregeln technisch optimiert, inhaltlich unverändert |

Hinweis: Supabase vergibt beim Einspielen über den Connector eigene Versionsnummern (Datum des Einspielens). Vor dem ersten Einsatz der Supabase CLI gegen dieses Projekt muss die Historie mit `supabase migration repair` abgeglichen werden.

### Überprüfung nach dem Einspielen (23.10.2026)
- Teil 3b: Code der 3 Funktionen identisch (ohne Zeilenumbruch-Zeichen), Rechte identisch. Funktionsprobe ohne Speicherung: Nicht-Admins können nicht moderieren; Admin entfernt gemeldete Nachricht; „Konto löschen“ entfernt Login, Zeitfenster und Match der Person, andere bleiben unberührt, Meldung bleibt anonymisiert; Aufräumen für Nutzer gesperrt – alles wie erwartet.
- Nach Härtung erneut: Funktionen, Zugriffsregeln und alle 39 Indizes identisch mit lokal getesteter Version.
- Erweiterte Funktionsprobe (3 fiktive Personen, ohne Speicherung): zusätzlich direktes Anlegen von Matches gesperrt, Blockieren macht unsichtbar und sperrt den Chat, Unbeteiligte lesen keine Nachrichten – alles wie erwartet.
- Supabase-Sicherheitsprüfung: verbleibend nur 2 bewusst akzeptierte Hinweise (Admin-Tabelle ohne Lesezugriff; App-Funktionen mit eigener Berechtigungsprüfung).
- Struktur-Vergleich mit der lokal getesteten Datenbank: Funktionscode, Zugriffsregeln, Rechte, Spalten, Bedingungen, Trigger, Stammdaten, Speicher und Echtzeit **identisch**.
- Funktionsprobe direkt in Supabase (zwei fiktive Personen, Ablauf ohne Speicherung): Sichtbarkeit, Kandidaten, Punktwert, Match, Nachricht, unsichtbare Reaktionen, Besucher-Sperre **wie erwartet**.

## GitHub
- Repository: `maber99/gatebuddy` (privat), verbunden 23.10.2026. Claude-GitHub-App mit Zugriff nur auf dieses Repository.
- Automatische Prüfungen (CI) bei jedem Pull Request und auf `main`: App (Typen, Lint, 63 Tests) und Datenbank (`supabase test db`, 128 Tests, PostgreSQL 17) – **grün**.
- Dependabot-Regeln: ADR-015.
- Bekannte Einschränkung: CI-Protokolle sind aus Claudes Arbeitsumgebung nicht herunterladbar; Fehler werden deshalb als Hinweise am Lauf ausgegeben.

## Expo
- Konto vorhanden (über GitHub). Noch nicht mit dem Projekt verknüpft. Zugangsschlüssel später nur als GitHub-Secret.
