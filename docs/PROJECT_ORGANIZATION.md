# GATEBUDDY – PROJEKTORGANISATION

> Stand: 20.10.2026 · Status: **[EMPFEHLUNG]**

## 1. Grundsatz

Alle Arbeitsergebnisse leben **an einem Ort: im GitHub-Repository des Gründers.** Das claude.ai-Projekt enthält Kopien der Kerndokumente für strategische Gespräche. Bei Widerspruch gilt das Repository.

## 2. Repository-Struktur (ein Repository, „Monorepo“)

```
gatebuddy/
├── CLAUDE.md                  # Arbeitsregeln für Claude Code (Pflichtlektüre jeder Sitzung)
├── README.md                  # Einstieg, Projektstatus, wie starten
├── CHANGELOG.md               # Was hat sich wann geändert (für Gründer lesbar)
├── apps/
│   ├── mobile/                # Expo-App (iOS + Android)
│   │   ├── app/               # Bildschirme (Expo Router)
│   │   ├── src/components/    # Wiederverwendbare Bausteine
│   │   ├── src/features/      # auth, profile, presence, matching, chat, safety
│   │   ├── src/lib/           # Supabase-Client, Push, Standort
│   │   ├── src/i18n/          # de.json, en.json
│   │   └── e2e/               # Maestro-Abläufe
│   ├── landing/               # gatebuddy.app (Cloudflare Pages) + Warteliste
│   └── admin/                 # Interne Moderationsansicht (ab Phase 10)
├── supabase/
│   ├── migrations/            # Jede DB-Änderung als nachvollziehbare Datei
│   ├── functions/             # Edge Functions (Push, Moderation, später Flugdaten)
│   ├── tests/                 # pgTAP-Tests für Tabellen und Zugriffsregeln
│   └── seed.sql               # Testdaten (nie echte Personen)
├── packages/
│   └── shared/                # Gemeinsame Typen, Validierung, Konstanten
├── docs/
│   ├── GATEBUDDY_MASTER_CONTEXT.md
│   ├── PRODUCT_REQUIREMENTS.md   # = MVP_DEFINITION.md, fortgeschrieben
│   ├── ARCHITECTURE.md
│   ├── ROADMAP.md
│   ├── BACKLOG.md
│   ├── DECISIONS.md              # Index aller Entscheidungen
│   ├── adr/                      # Eine Datei pro Entscheidung (ADR-001-*.md)
│   ├── TESTING.md                # Teststrategie + aktueller Teststatus
│   ├── BUSINESS_MODEL.md
│   ├── FEASIBILITY_ANALYSIS.md
│   ├── SECURITY.md               # Bedrohungsmodell, Meldewege
│   ├── PRIVACY.md                # Datenarten, Fristen, Dienstleister (Grundlage Datenschutzerklärung)
│   ├── MODERATION.md             # Ablauf bei Meldungen, 24-h-Prozess
│   └── research/                 # Interviews, Umfragen, Wettbewerb (datiert)
└── .github/
    ├── workflows/             # ci.yml, db-tests.yml, e2e.yml
    ├── ISSUE_TEMPLATE/        # Funktion, Fehler, Entscheidung
    ├── PULL_REQUEST_TEMPLATE.md
    └── dependabot.yml
```

## 3. Wie Entscheidungen festgehalten werden

- **ADR (Decision Record)**: eine kurze Datei pro Entscheidung in `docs/adr/` mit: Kontext · Optionen · Entscheidung · Begründung · Folgen · Status · Datum · entschieden von.
- **Status-Werte:** `Vorgeschlagen` → `Angenommen` / `Abgelehnt` → ggf. `Ersetzt durch ADR-xxx`.
- Nur der Gründer setzt `Angenommen`. Claude darf vorschlagen, nicht beschliessen.
- `DECISIONS.md` ist der Index. `GATEBUDDY_MASTER_CONTEXT.md` übernimmt angenommene Entscheidungen als [ENTSCHIEDEN].
- Alte Entscheidungen werden nie gelöscht, sondern ersetzt – so bleiben Begründungen nachvollziehbar.

## 4. Arbeitsweise mit Claude Code

1. **Jede Aufgabe = ein GitHub-Issue** mit Ziel, Akzeptanzkriterien und Testanforderung.
2. Claude Code arbeitet auf einem eigenen Zweig, schreibt Code **und Tests**, öffnet einen Pull Request.
3. Automatische Prüfungen (CI) müssen grün sein.
4. Claude fasst im Pull Request in einfacher Sprache zusammen: was, warum, wie getestet, Status-Kennzeichnung.
5. Merge in `main`: bei normalen Änderungen durch Claude nach grüner CI; bei sicherheitskritischen Änderungen (Zugriffsregeln, Login, Zahlungen, Datenlöschung) **nur nach Freigabe durch den Gründer**.
6. `CHANGELOG.md` und `TESTING.md` werden im selben Pull Request aktualisiert.
7. Produktion wird nie direkt verändert – nur über Migrationen und freigegebene Releases.

**Inhalt von `CLAUDE.md` (Kern):** Projektanweisungen in Kurzform · Stack und Konventionen · Freigabepflichtige Aktionen · Statuskennzeichnung · „Erst Tests, dann Behauptungen“ · Keine Geheimnisse im Code · Keine echten Personendaten in Tests.

## 5. Zugänge & Eigentum (Gründer behält Kontrolle)

| Konto | Inhaber | Hinweis |
|---|---|---|
| GitHub-Organisation „gatebuddy“ | Gründer | 2-Faktor Pflicht |
| Supabase-Organisation | Gründer | Getrennte Projekte dev/prod |
| Expo-Konto | Gründer | |
| Apple Developer / Google Play | Gründer bzw. künftige Firma | |
| Cloudflare | Gründer (besteht) | |
| E-Mail-Adressen (support@, privacy@, admin@gatebuddy.app) | Gründer | Über Cloudflare-Weiterleitung |
| Passwort-Manager | Gründer | Alle Zugänge + Wiederherstellungscodes |

Claude Code erhält nur die Rechte, die es braucht (Repository-Zugriff; Supabase-Zugang zunächst nur für die Entwicklungsumgebung).

## 6. Automatisierbare wiederkehrende Aufgaben

| Aufgabe | Wie | Ab |
|---|---|---|
| Tests, Typprüfung, Formatierung bei jedem Pull Request | GitHub Actions | Phase 3 |
| Sicherheitsupdates von Bibliotheken | Dependabot | Phase 3 |
| Erkennen versehentlich eingecheckter Schlüssel | GitHub Secret Scanning | Phase 3 |
| Datenbank-Migrationen gegen Testdatenbank prüfen | GitHub Actions + Supabase CLI | Phase 4 |
| Test-Builds für das eigene Telefon | EAS Build (Gratisstufe) | Phase 5 |
| Automatisches Beenden abgelaufener Zeitfenster | Geplanter DB-Job | Phase 8 |
| Aufräumen alter Chats nach Frist | Geplanter DB-Job | Phase 10 |
| E-Mail-Alarm bei neuer Meldung | Edge Function | Phase 10 |
| Wöchentlicher Statusbericht an den Gründer (Fortschritt, offene Entscheidungen, Kennzahlen) | Geplante Claude-Aufgabe | Phase 3 |
| Wettbewerbs- und Regulierungs-Monitoring (monatlich) | Geplante Claude-Aufgabe mit Websuche | Phase 2 |
| Kennzahlen-Dashboard (Zeitfenster, Matches, Treffen) | SQL-Auswertung + Dashboard | Phase 12 |
| Wartelisten-Auswertung | Skript + Bericht | Phase 2 |
