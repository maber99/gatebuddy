# GATEBUDDY – TESTSTRATEGIE UND TESTSTATUS

> Stand: 20.10.2026 · Letzter vollständiger Lauf: 20.10.2026, lokal (PostgreSQL 16 + pgTAP 1.3.5, Node 22)

## Ergebnis des letzten Laufs

| Bereich | Werkzeug | Tests | Ergebnis |
|---|---|---|---|
| Datenbank: Rechte, Zugriffsregeln, Geschäftslogik | pgTAP (`npm run test:db`) | 128 in 8 Dateien | **Alle bestanden** |
| App: Fachlogik, Übersetzungen, Abgleich mit Datenbank, Bildschirme | Jest + Testing Library (`npm run check`) | 63 in 3 Dateien | **Alle bestanden** |
| App: Typprüfung | TypeScript | – | **Fehlerfrei** |
| App: Codeprüfung | ESLint (eslint-config-expo) | – | **Fehlerfrei** |
| App: Bündeln für iOS und Android | `expo export` | – | **Erfolgreich** (iOS 3,5 MB, Android 3,8 MB) |
| Wirksamkeit der Tests (Mutationstest) | 2 absichtlich eingebaute Lücken | – | **Beide erkannt** (6 Tests schlugen an) |

## Was die Datenbank-Tests belegen

| Datei | Belegt u. a. |
|---|---|
| 001 Schema & Rechte | RLS auf allen Tabellen; Besucher ohne Login können nur Kataloge lesen; Reaktionen/Matches/Meldungen nicht direkt schreibbar; Status- und Bildpfad-Spalten geschützt; nur ZRH aktiv |
| 002 Profil-Sichtbarkeit | Profile nur bei Zeitüberschneidung oder Match sichtbar; Blockieren wirkt in beide Richtungen; gesperrte Konten unsichtbar; keine Links; Wortfilter; kein Profil für fremde ID |
| 003 Zeitfenster | Nur aktive Flughäfen; max. 6 h; max. 14 Tage voraus; keine Vergangenheit; keine eigenen Überschneidungen; Flugnummer wird vereinheitlicht/geprüft; Abbrechen möglich; gesperrte Konten können keine neuen anlegen |
| 004 Matching | Richtige Kandidaten (Überschneidung ≥ 15 Min., aktiv, nicht blockiert); nachvollziehbarer Punktwert (Beispiel = 119); **„Weiter“ ist für die andere Person nicht erkennbar**; Match nur bei gegenseitigem Interesse; keine doppelte Reaktion |
| 005 Chat | Nur Beteiligte lesen/schreiben; nicht im Namen anderer; beendetes Match = kein Schreiben; Blockieren schliesst sofort; Spam-Grenze 20 Nachrichten/Minute |
| 006 Meldungen & Moderation | Melden von Profilen und Nachrichten (mit Beweiskopie); Nutzer sehen keine Meldungen; automatische vorläufige Sperre bei 3 verschiedenen Meldenden in 7 Tagen; Admin-Funktionen nur für Admins |
| 007 Profilbilder | „Erst nach Match“ vs. „für alle am Flughafen“ (ADR-007); kein Upload in fremde Ordner; kein Bild ohne Zeitüberschneidung |
| 008 Konto & Aktivität | Konto löschen entfernt alle persönlichen Daten; Meldungen bleiben anonymisiert; Aktivitätsanzeige nur als Anzahl; Aufräumen nach 90 Tagen |

## Status je Funktion

| Funktion | Status |
|---|---|
| Datenbankschema, Zugriffsregeln, Matching, Moderation | **Implementiert · Erfolgreich getestet** (lokal) |
| Gleiche Tests mit Supabase CLI (`supabase test db`) in GitHub Actions | **Noch nicht getestet** – hier kein Docker verfügbar; erster Lauf nach Repository-Einrichtung |
| Lokale Tests auf PostgreSQL 16; Supabase nutzt PostgreSQL 17 | **Bekanntes Risiko (gering)** – CI mit Supabase CLI deckt das ab |
| App-Gerüst, Navigation, Deutsch/Englisch, Designbausteine | **Implementiert · Erfolgreich getestet** |
| Profil anlegen (Formular, Prüfungen) | **Implementiert · Erfolgreich getestet** (ohne Server) |
| Zeitfenster anlegen, Kandidaten, Interesse/Weiter, Match-Liste, Konto löschen | **Implementiert · Noch nicht getestet gegen echten Server** |
| Anmeldung per E-Mail-Code | **Implementiert · Noch nicht getestet** (braucht Supabase-Projekt) |
| Anmeldung mit Apple / Google | **Geplant** (braucht Entwicklerkonten) |
| Einmalige Standortprüfung | **Logik implementiert und getestet** · Bildschirm-Anbindung **Geplant** |
| Chat-Bildschirm, Melden-Bildschirm, Push-Benachrichtigungen, Profilbild-Upload | **Geplant** (Phasen 7–10) |
| Moderations-Weboberfläche | **Geplant** (Datenbankfunktionen fertig und getestet) |

## Bekannte Probleme / Einschränkungen

1. **Web-Vorschau** (nur für Bildschirmfotos, kein Zielprodukt): Tab-Leiste überdeckt die Überschrift; Hinweis „React #418“ (Sprache beim Vorrendern ≠ Gerätesprache). Betrifft iOS/Android nicht.
2. **Wortfilter-Liste ist leer.** Der Mechanismus ist getestet; die Begriffe müssen von der Moderation gepflegt werden.
3. **Standortbestätigung vertraut dem Gerät.** Manipulation ist möglich; daher nur als Hinweis („vor Ort bestätigt“), nie als Sicherheitsmerkmal verwenden.
4. **Koordinaten der Flughäfen** sind Näherungswerte; vor Aktivierung im Feldtest prüfen.

## So werden Tests ausgeführt

```bash
npm run check      # App (Typen, Lint, Jest)
npm run test:db    # Datenbank lokal ohne Docker (PostgreSQL + pgTAP nötig)
# oder mit Docker:
npx supabase db start && npx supabase test db
```

## Regeln
- Jede neue Tabelle: RLS aktiv + mindestens ein „darf“- und ein „darf nicht“-Test.
- Jeder neue Fehlercode der Datenbank muss in `apps/mobile/src/domain/errors.ts` und in beiden Sprachen stehen – ein Test erzwingt das.
- Vor sicherheitskritischen Änderungen: Mutationstest wiederholen (Regel kurz entfernen → Tests müssen fehlschlagen).
