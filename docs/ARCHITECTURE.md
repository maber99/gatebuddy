# GATEBUDDY – TECHNISCHE ARCHITEKTUR (Vorschlag)

> Stand: 20.10.2026 · Status: **Stack und Region freigegeben (ADR-001–003); ADR-004 und Details weiterhin [EMPFEHLUNG]**

---

## 1. Kurzfassung für den Gründer

Der vorgeschlagene Stack (React Native + Expo + TypeScript + Supabase/PostgreSQL + GitHub + Cloudflare + Claude Code) ist für GateBuddy **gut geeignet**. Ich empfehle ihn mit vier Präzisierungen:

1. **Supabase in der EU-Region Frankfurt** betreiben, nicht Zürich (Begründung §6).
2. **Cloudflare nur für Domain, DNS, Landingpage und E-Mail-Weiterleitung** – nicht als zweites Backend. Ein Backend ist genug.
3. **Fluginformationen erst ab Version 1.1**, und nur über eine eigene Server-Funktion mit Zwischenspeicher (Kosten- und Lizenzkontrolle).
4. **Keine laufende Standortverfolgung.** Nur „bin am Flughafen X“ – geprüft einmalig bei geöffneter App.

Warum diese Kombination: eine Programmiersprache (TypeScript) für App und Server-Logik, Standard-Datenbank (PostgreSQL) ohne Anbieterzwang, sehr niedrige Startkosten, und eine Struktur, mit der Claude Code zuverlässig arbeiten kann.

## 2. Bewertung der einzelnen Bausteine

| Baustein | Rolle | Bewertung | Abhängigkeitsrisiko / Ausweg |
|---|---|---|---|
| **React Native** | Eine Codebasis für iOS + Android | Ausgereift, grosse Community; im Projekt eingesetzt: 0.88 | Open Source (MIT) |
| **Expo** (im Projekt: SDK 58, Stand 20.10.2026) | Werkzeugkasten um React Native: Builds, Updates, Push, Gerätezugriff | Senkt Aufwand massiv; Expo-Kernbibliotheken sind Open Source | Cloud-Builds (EAS) optional; lokal bauen bleibt möglich |
| **TypeScript** | Typsichere Sprache für App und Server-Funktionen | Weniger Fehler, gut für KI-gestützte Entwicklung | – |
| **Supabase** | Datenbank, Login, Echtzeit, Dateien, Server-Funktionen | Deckt MVP komplett ab; Zugriffsschutz direkt in der DB (RLS) | Open Source; kann selbst betrieben oder zu jedem PostgreSQL-Anbieter migriert werden |
| **PostgreSQL** | Datenbank | Industriestandard | Kein Lock-in |
| **GitHub** | Code, Versionen, Aufgaben, automatische Tests (Actions) | Standard; Claude Code integriert gut | Git ist portabel |
| **Cloudflare** | Domain, DNS, Landingpage, E-Mail-Weiterleitung, Bot-Schutz für Formulare | Bereits vorhanden, günstig | Domain ist übertragbar |
| **Claude Code** | Entwicklungsagent | Arbeitet im Repository, schreibt und testet Code | Code gehört vollständig dem Gründer |

### Geprüfte Alternativen (bewusst verworfen)

| Alternative | Warum nicht |
|---|---|
| Flutter (Dart) | Technisch gleichwertig; aber zweite Sprache neben dem Server-Code, und TypeScript-Ökosystem ist für KI-Entwicklung breiter. Kein zwingender Vorteil. |
| Native (Swift + Kotlin) | Doppelter Aufwand, doppelte Fehlerquellen – für ein MVP unwirtschaftlich. |
| Firebase | Dokumenten-Datenbank passt schlechter zu Matching-Abfragen; stärkere Bindung an Google. |
| Eigenes Backend (Node.js + PostgreSQL auf eigenem Server) | Mehr Kontrolle, aber Login, Echtzeit, Sicherheit selbst bauen und betreiben → mehr Aufwand und Angriffsfläche. Bleibt als Ausweg, falls Supabase später nicht passt. |
| No-Code (FlutterFlow, Bubble) | Widerspricht dem Ziel „vollständig kontrollierbarer Code“. |
| Chat-Dienste (Stream, Sendbird) | Für 1:1-Text-Chat unnötig; Kosten und Datenabfluss an Dritte. Supabase Realtime reicht im MVP. |

## 3. Systemüberblick

```
┌─────────────────────────────┐        ┌──────────────────────────────────────┐
│  GateBuddy App (iOS/Android) │ HTTPS │ Supabase (EU – Frankfurt)              │
│  React Native + Expo + TS    │──────▶│  • Auth (Apple, Google, E-Mail-Code)   │
│  • Profil, Discover, Chat    │◀──────│  • PostgreSQL + Row Level Security     │
│  • Standort einmalig, lokal  │  WS   │  • Realtime (Chat, Matches)            │
└──────────────┬──────────────┘        │  • Storage (Profilbilder, privat)      │
               │ Push                   │  • Edge Functions (Matching, Moderation│
               ▼                        │    Push-Versand, später Flug-API)      │
     Expo Push → APNs / FCM             └──────────────┬───────────────────────┘
                                                       │ (ab v1.1, mit Cache)
                                                       ▼
                                             Flugdaten-API (z. B. AeroDataBox)

Cloudflare: gatebuddy.app (DNS) · Landingpage + Warteliste · E-Mail-Weiterleitung
GitHub: Code · Issues · Actions (Tests, Builds) · Claude Code arbeitet hier
```

## 4. Kernfunktionen technisch

### 4.1 Login
- **Sign in with Apple + Google + E-Mail-Einmalcode.** Apple verlangt bei Google-Login eine gleichwertige datenschutzfreundliche Option (Richtlinie 4.8).
- Kein Passwort-Login (weniger Supportaufwand, weniger Angriffsfläche).
- Altersbestätigung 18+ bei Registrierung; später Apple Declared Age Range API, wo verfügbar/erforderlich.

### 4.2 Flughafen & Standort
- Nutzer wählt Flughafen aus Liste (MVP: ZRH aktiv, weitere als „bald verfügbar“ zur Nachfragemessung).
- Optional: einmalige Standortprüfung bei geöffneter App gegen ein Geofence-Polygon des Flughafens. **Gespeichert wird nur:** Flughafen-Code, Zeitpunkt, „Standort bestätigt ja/nein“. Keine Koordinaten.
- Keine Hintergrund-Ortung (Akku, Datenschutz, App-Store-Prüfung).
- Airside/Landside: Selbstauskunft.

### 4.3 Präsenz („Check-in“) und Zeitfenster
- Tabelle `presences`: wer, welcher Flughafen, von–bis, Kontaktinteressen für dieses Zeitfenster, Status (geplant/aktiv/beendet).
- Sichtbarkeit endet automatisch (`ends_at`); Höchstdauer z. B. 6 h.
- Vorab-Zeitfenster bis 14 Tage im Voraus.

### 4.4 Matching (regelbasiert, transparent)
- Kandidaten = Präsenzen am selben Flughafen mit **zeitlicher Überschneidung**, beide sichtbar, keine Blockierung in beide Richtungen, noch nicht bewertet.
- Sortierung nach einfachem Punktwert: gemeinsame Kontaktinteressen > Sprach-Passung (spricht, was der andere üben will) > gemeinsame Sprachen > gemeinsame Interessen > verbleibende gemeinsame Zeit.
- Umgesetzt als PostgreSQL-Funktion – schnell, testbar, ohne KI. KI-Matching erst, wenn Daten zeigen, dass es nötig ist.
- „Interesse“ und „Weiter“ werden gespeichert; „Weiter“ ist für die andere Person nie sichtbar. Bei beidseitigem Interesse entsteht ein `match`.

### 4.5 Chat
- 1:1-Textnachrichten, nur innerhalb eines Matches (in der Datenbank erzwungen).
- Echtzeit über Supabase Realtime; Push bei neuer Nachricht, wenn App im Hintergrund.
- Melden einzelner Nachrichten; Blockieren beendet den Chat sofort für beide.
- Aufbewahrung: [OFFEN] – Vorschlag 30 Tage nach letztem Kontakt, gemeldete Inhalte länger zur Beweissicherung.

### 4.6 Profilbilder
- Privater Speicher; Abruf nur über zeitlich begrenzte Links.
- Sichtbarkeit wählt der Nutzer: „alle am Flughafen“ oder „erst nach Match“ (Standard). Umsetzung über eine Zugriffsfunktion, die vor Ausgabe eines Bild-Links prüft (ADR-007).
- Bildmoderation: MVP über Meldungen; automatische Prüfung (Nacktheit/Gewalt) ab 1.1 [Anbieter offen].

### 4.7 Push-Benachrichtigungen
- Expo Push Service (leitet an Apple/Google weiter). Auslöser: neues Match, neue Nachricht, passendes Zeitfenster gefunden.

### 4.8 Fluginformationen (ab v1.1)
- Manuelle Flugnummer im MVP (nur Anzeige für den Nutzer selbst, optional für andere).
- Ab v1.1: Edge Function fragt Flugdaten-API ab, speichert Ergebnis für einige Minuten zwischen, Hinweis „Keine offizielle Information – bitte Anzeigen am Flughafen beachten“.
- Anbieter-Vorauswahl: AeroDataBox (günstig, Abo-Modell) vs. FlightAware AeroAPI (Personal-Stufe laut Anbieter nur für persönliche/akademische Nutzung; kommerziell ab Standard-Stufe mit 100 USD Monatsminimum). Entscheidung nach Test der Datenqualität für ZRH.

### 4.9 Moderation & Administration
- Tabellen `reports`, `moderation_actions`, `blocks`.
- MVP: Moderation über eine einfache interne Web-Ansicht (nur Gründer-Zugang) – kein Fremdtool.
- Automatisch: Wortfilter für Profiltexte und Chat, Rate-Limits, Sperre nach Schwellenwert an Meldungen bis zur Prüfung.
- E-Mail-Alarm an Gründer bei neuer Meldung (24-h-Frist).

### 4.10 Internationalisierung
- Alle Texte in Sprachdateien (i18n) ab Tag 1. MVP: Deutsch + Englisch. Datums-/Zeitangaben in Ortszeit des Flughafens.

## 5. Datenmodell (Entwurf)

| Tabelle | Zweck | Wichtigste Felder |
|---|---|---|
| `profiles` | Öffentliches Profil | id, display_name, bio, avatar_path, birth_year_confirmed_18, created_at, status |
| `profile_languages` | Sprachen | profile_id, language_code, mode (`speaks`/`learns`) |
| `profile_interests` | Interessen | profile_id, interest_id |
| `interests`, `intents` | Kataloge | id, Übersetzungsschlüssel |
| `airports` | Flughäfen | iata, name, timezone, geofence, is_active |
| `presences` | Zeitfenster am Flughafen | id, profile_id, airport_iata, starts_at, ends_at, intents[], location_verified, flight_number (optional) |
| `reactions` | Interesse/Weiter | from_profile, to_profile, presence_id, kind |
| `matches` | Beidseitiges Interesse | id, profile_a, profile_b, created_at, closed_at |
| `messages` | Chat | id, match_id, sender_id, body, created_at |
| `blocks` | Blockierungen | blocker_id, blocked_id |
| `reports` | Meldungen | reporter_id, target_profile, target_message, reason, status |
| `moderation_actions` | Protokoll | report_id, action, admin_id, created_at |
| `devices` | Push-Tokens | profile_id, expo_push_token, platform |

**Zugriffsregeln (RLS), Beispiele:**
- Profil lesen nur, wenn beide aktuell am selben Flughafen eine überlappende Präsenz haben *oder* ein Match besteht – und keine Blockierung.
- Nachrichten lesen/schreiben nur Teilnehmer des Matches.
- `reactions` des Gegenübers sind nie lesbar.
- Meldungen sind für Nutzer nur schreibbar, nicht lesbar.

## 6. Datenregion

**Empfehlung: Frankfurt (eu-central-1).** Supabase bietet auch Zürich (eu-central-2). Supabase weist selbst darauf hin, dass Zürich und London zwar anerkannte Datenschutzniveaus haben, aber nicht in der EU liegen; wer Daten strikt in der EU halten will, soll eine EU-Region wählen. Da Nutzer überwiegend aus der EU kommen werden und der Gründer ab 2027 in Deutschland wohnt, ist Frankfurt die einfachste Wahl. Die Schweiz anerkennt die EU als Staatenraum mit angemessenem Datenschutz [nach meinem Kenntnisstand – rechtlich bestätigen lassen].
Hinweis: Edge Functions und CDN-Cache können ausserhalb der Region laufen; das ist in der Datenschutzerklärung zu berücksichtigen.

## 7. Qualitätssicherung & Betrieb

| Ebene | Werkzeug | Zweck |
|---|---|---|
| Datenbank & Zugriffsregeln | pgTAP (SQL-Tests) | Beweist, dass RLS fremde Daten wirklich schützt |
| Logik & Komponenten | Jest + React Native Testing Library | Funktionen und Bildschirme |
| End-to-End auf Gerät/Simulator | Maestro (Open Source) | Registrierung → Check-in → Match → Chat |
| Statische Prüfung | TypeScript, ESLint, Prettier | Einheitlicher, fehlerarmer Code |
| CI | GitHub Actions | Tests bei jedem Pull Request; Merge nur bei Grün |
| Fehlerüberwachung | Sentry (oder vergleichbar) | Abstürze in Beta/Produktion |
| Sicherheit | Abhängigkeits-Scans (Dependabot), Secret-Scanning, Pentest vor Launch | – |

**Umgebungen:** `development` (Supabase Free, lokal + Testdaten) · `production` (Supabase Pro). Staging als zweites Projekt erst bei Beta. Produktionsdaten nie in Entwicklung.

## 8. Kosten (Stand Recherche Oktober 2026 – vor Buchung erneut prüfen)

| Posten | Art | Kosten | Wann |
|---|---|---|---|
| Domain gatebuddy.app | jährlich | bereits bezahlt | – |
| Supabase Free | – | 0 USD (Projekte pausieren bei Inaktivität, nicht für Produktion) | Entwicklung |
| Supabase Pro | monatlich | ab 25 USD inkl. 10 USD Rechenguthaben (deckt kleinste Instanz); Ausgabenlimit standardmässig aktiv; Praxisberichte nennen 35–75 USD für kleine Apps | ab Beta |
| Expo / EAS Free | – | 0 USD, 30 Builds/Monat (davon bis zu 15 iOS) | Entwicklung |
| Expo Starter/Production | monatlich | nur bei Bedarf | später |
| Apple Developer Program | jährlich | 99 USD | vor TestFlight-Beta |
| Google Play Console | einmalig | 25 USD [nach meinem Kenntnisstand – prüfen] | vor Android-Beta |
| Flugdaten-API | monatlich | 0 USD im MVP; ab v1.1 ca. 0–150 USD je nach Anbieter/Volumen | v1.1 |
| Sentry | monatlich | Gratisstufe ausreichend [prüfen] | Beta |
| Rechtliche Prüfung (Datenschutz, AGB), Gründung | einmalig | [OFFEN] – Angebote einholen | vor Beta/Launch |

**Grössenordnung laufender Infrastrukturkosten bis zum Launch:** ca. 30–60 USD/Monat + 99 USD/Jahr Apple [SCHÄTZUNG]. Der wesentliche Kostentreiber liegt nicht in der Technik, sondern in Recht, Marketing und Zeit.

## 9. Skalierung

- Bis in den sechsstelligen Nutzerbereich reicht eine einzelne PostgreSQL-Instanz mit passenden Indizes (Flughafen + Zeitfenster) [SCHÄTZUNG].
- Realtime-Verbindungen sind im Supabase-Pro-Plan kontingentiert (Sekundärquelle nennt 200 gleichzeitige Verbindungen inklusive) – bei Wachstum überwachen und vor Engpass Plan anpassen.
- Mehr Flughäfen = nur neue Datensätze in `airports`; keine Architekturänderung.

## 10. Quellen

- [Expo SDK 56](https://expo.dev/sdk/56) · [Expo Pricing](https://expo.dev/pricing) · [Expo – Free-Plan-Limits](https://expo.dev/changelog/2023-08-01-eas-free-plan-limits.md)
- [Supabase Regions](https://supabase.com/docs/guides/platform/regions) · [Supabase GDPR](https://supabase.com/docs/guides/security/gdpr-compliance)
- [MakerKit – Supabase Pricing 2026](https://makerkit.dev/blog/saas/supabase-pricing) · [FocusReactive – Supabase Pricing](https://focusreactive.com/blog/supabase-price/)
- [FlightAware AeroAPI](https://flightaware.com/commercial/aeroapi/) · [Geekflare – Flight Data APIs 2026](https://geekflare.com/guides/flight-data-api/) · [AlternativeTo – AeroDataBox](https://alternativeto.net/software/aerodatabox-api/about/)
- [Apple Forum – Guideline 4.8](https://developer.apple.com/forums/thread/765145) · [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
