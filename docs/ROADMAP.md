# GATEBUDDY – ROADMAP BIS ZUR VERÖFFENTLICHUNG

> Stand: 20.10.2026 · Status: **[EMPFEHLUNG]**
> **Zeitannahme [SCHÄTZUNG]:** Gründer nebenberuflich (ca. 8–12 h/Woche für Entscheidungen, Tests, Community), Entwicklung durch Claude Code. Woche 1 = Woche nach Freigabe dieses Plans.
> **Zielbild:** Öffentlicher Launch in Zürich in ca. **5–7 Monaten**, möglichst vor der Sommerreisezeit 2027 (die Sommermonate waren 2025 die passagierstärksten in ZRH).

## Stand (20.10.2026)

| Phase | Status |
|---|---|
| 1 Strategische Grundlagen | Abgeschlossen; ADR-001/002/003/005/006/007 entschieden |
| 3 Infrastruktur | Repository-Inhalt fertig (lokal). **Offen: Konten (GitHub, Supabase, Expo) durch Gründer** |
| 4 Datenbank & Backend | Kern fertig, 128 Tests bestanden (lokal) |
| 5 App-Gerüst | Fertig, 63 Tests bestanden, iOS-/Android-Bundles gebaut |
| 6–10 | Teilweise vorbereitet (Bildschirme ohne Serverbetrieb getestet) |

## Übersicht

```
Woche:           1   3   5   7   9   11  13  15  17  19  21  23  25
1 Grundlagen     ██
2 Validierung    ████████████                                ← läuft parallel, Go/No-Go W6
3 Infrastruktur  ██████
4 DB/Backend         ██████████
5 App-Gerüst         ████████
6 Registrierung          ██████
7 Profile                  ██████
8 Flughafen                    ██████
9 Matching                       ████████
10 Chat                              ██████
11 QA            ░░░░░░░░░░░░░░░░░░░░░░░░██████   (laufend + Sicherheitsprüfung)
12 Beta                                      ████████████
13 Store                                                ██████
14 Nutzergewinnung   ░░░░░ (Warteliste) ░░░░░░░░░░░░░░░░░░░░░███████→
15 Skalierung                                                     →
```

---

## Phase 1 – Strategische Grundlagen (Woche 0–1)
- **Ziel:** Gemeinsame, dokumentierte Ausgangslage.
- **Aufgaben:** Master-Kontext, Machbarkeit, Architektur, MVP, Roadmap, Entscheidungsvorlagen (erledigt mit diesem Paket); Marken-Vorprüfung „GateBuddy“.
- **Werkzeuge:** Claude (Chat/Projekt), Websuche, amtliche Markenregister.
- **Abhängigkeiten:** keine.
- **Ergebnis (prüfbar):** Dokumente im Projekt; ADR-001 bis ADR-008 entschieden.
- **Entscheidungen Gründer:** ADRs freigeben/ändern (Stack, Region, Startflughafen, Mindestalter, Foto-Sichtbarkeit, Budgetrahmen).

## Phase 2 – Marktvalidierung (Woche 1–6, parallel)
- **Ziel:** Vor grösserem Aufwand prüfen, ob Reisende das wirklich wollen.
- **Aufgaben:**
  - Landingpage gatebuddy.app mit Warteliste (Flughafen, Reisehäufigkeit, Kontaktinteresse) – Claude baut, Gründer gibt frei.
  - 15–20 Interviews mit Allein- und Umsteigereisenden (Leitfaden von Claude).
  - Kurzumfrage in Vielflieger-, Sprachtandem-, Expat- und Studierenden-Communities.
  - 2–3 Beobachtungstage airside ZRH: Wo würden Treffen stattfinden? Wie lange warten Menschen? Funktioniert die Standortbestimmung?
  - Optional Kleinst-Werbetest (Budget nur nach Freigabe).
- **Werkzeuge:** Cloudflare Pages, Formular mit Bot-Schutz, Umfragetool, Auswertung durch Claude.
- **Abhängigkeiten:** Datenschutzhinweis für Warteliste; Impressum.
- **Ergebnis:** Validierungsbericht mit Go/No-Go.
- **Vorgeschlagene Go-Schwellen (eigene Startwerte, keine Branchenstandards):**
  - ≥ 300 Wartelisten-Einträge mit ZRH-Bezug in 6 Wochen ohne bezahlte Werbung **oder** nachvollziehbare Kosten pro Eintrag bei Kleinsttest.
  - ≥ 40 % der Interviewten schildern eine konkrete vergangene Situation, in der sie am Flughafen Gesellschaft gesucht hätten.
  - ≥ 30 % würden ein Zeitfenster **im Voraus** eintragen.
- **Entscheidungen Gründer:** Schwellen festlegen; bei Verfehlung: Konzept anpassen (z. B. stärker Sprachpraxis/Networking) oder stoppen.

## Phase 3 – Technische Infrastruktur (Woche 1–3)
- **Ziel:** Arbeitsfähige, sichere Entwicklungsumgebung im Eigentum des Gründers.
- **Aufgaben:** GitHub-Organisation + Repository, Branch-Schutz, CI-Grundgerüst; Supabase-Entwicklungsprojekt (EU); Expo-Konto; Passwort-Manager und 2-Faktor für alle Konten; `CLAUDE.md` mit Arbeitsregeln.
- **Werkzeuge:** GitHub, Supabase, Expo, Claude Code, Cloudflare.
- **Abhängigkeiten:** ADR-001/002 freigegeben. **Konten muss der Gründer selbst anlegen** (Claude darf keine Konten erstellen und keine Passwörter eingeben).
- **Ergebnis:** Leeres App-Projekt startet im Simulator; CI läuft grün.
- **Entscheidungen Gründer:** Kontoinhaber/E-Mail-Adresse (Empfehlung: eigene Projektadresse auf gatebuddy.app).

## Phase 4 – Datenbank und Backend (Woche 3–7)
- **Ziel:** Datenmodell, Zugriffsregeln, Matching-Funktion – vollständig getestet.
- **Aufgaben:** Tabellen gemäss `ARCHITECTURE.md` §5; Row Level Security; Matching als SQL-Funktion; Moderations-Tabellen; Testdaten-Generator; pgTAP-Tests.
- **Werkzeuge:** Supabase CLI, PostgreSQL, pgTAP, GitHub Actions.
- **Abhängigkeiten:** Phase 3.
- **Ergebnis:** Testbericht: Jede Zugriffsregel hat mindestens einen „darf“- und „darf nicht“-Test.
- **Entscheidungen Gründer:** Chat-Aufbewahrungsfrist; Höchstdauer Zeitfenster.

## Phase 5 – App-Frontend-Grundgerüst (Woche 3–6)
- **Ziel:** Navigationsstruktur, Designsystem, Mehrsprachigkeit.
- **Aufgaben:** Bildschirmfluss, wiederverwendbare Komponenten, i18n DE/EN, Dark Mode, Barrierefreiheit-Grundlagen, Klick-Prototyp zur Freigabe.
- **Werkzeuge:** Expo, Expo Router, TypeScript, Jest.
- **Abhängigkeiten:** Phase 3.
- **Ergebnis:** Durchklickbarer Prototyp auf dem eigenen Telefon (Entwicklungs-Build).
- **Entscheidungen Gründer:** Logo, Farben, Tonalität (Claude liefert 2–3 Vorschläge).

## Phase 6 – Nutzerregistrierung (Woche 5–7)
- **Ziel:** Sicherer Login und Kontolöschung.
- **Aufgaben:** Sign in with Apple, Google, E-Mail-Code; 18+-Bestätigung; AGB/Datenschutz-Zustimmung; Account löschen.
- **Abhängigkeiten:** Apple Developer Program (99 USD/Jahr) für Sign in with Apple auf echten Geräten; Google-Cloud-Projekt für Google-Login.
- **Ergebnis:** E2E-Test „Registrieren → Abmelden → Anmelden → Konto löschen“ grün.
- **Entscheidungen Gründer:** Apple-Konto als Einzelperson (sofort, eigener Name sichtbar) oder Organisation (Firma + D-U-N-S, mehrere Wochen). **Kostenpflichtig – Freigabe nötig.**

## Phase 7 – Profile (Woche 6–8)
- **Ziel:** Vollständiges, datensparsames Profil.
- **Aufgaben:** Name, Sprachen (spricht/übt), Interessen, Kurztext, optionales Foto (privater Speicher), Wortfilter.
- **Ergebnis:** Tests für Pflichtfelder, Filter, Foto-Zugriffsschutz.
- **Entscheidungen Gründer:** Interessen-Katalog (Claude schlägt 20–30 vor); Foto-Sichtbarkeit (O-3).

## Phase 8 – Flughafenerkennung (Woche 7–9)
- **Ziel:** „Ich bin in ZRH“ – einfach, ohne Ortungsdaten zu speichern.
- **Aufgaben:** Flughafenliste, Geofence ZRH, einmalige Standortprüfung, Zeitfenster jetzt/vorab, automatisches Ablaufen.
- **Abhängigkeiten:** Feldtest vor Ort (Phase 2 Beobachtungstage).
- **Ergebnis:** Feldtestprotokoll: Erkennungsquote an mindestens 5 Orten im Terminal.
- **Entscheidungen Gründer:** Ist Standortbestätigung Pflicht oder optional? (Empfehlung: optional, mit Abzeichen „vor Ort bestätigt“.)

## Phase 9 – Matching (Woche 8–11)
- **Ziel:** Passende Personen mit Zeitüberschneidung anzeigen; stilles Ablehnen; Matches.
- **Aufgaben:** Kandidatenliste, Sortierung, Interesse/Weiter, Match-Erzeugung, Push „neues Match“ und „passendes Zeitfenster“.
- **Ergebnis:** Simulationstest mit 500 Testprofilen; nachweislich keine Anzeige von Ablehnungen oder blockierten Personen.
- **Entscheidungen Gründer:** Gewichtung der Kriterien (Vorschlag liegt vor).

## Phase 10 – Chat (Woche 10–12)
- **Ziel:** Sicherer 1:1-Chat nach Match.
- **Aufgaben:** Echtzeit-Nachrichten, Push, Melden, Blockieren, Sicherheitshinweis vor erstem Treffen, Feedback „Getroffen?“.
- **Ergebnis:** E2E-Test zweier Geräte; Test „Blockieren beendet Chat sofort“.

## Phase 11 – Qualitätssicherung (laufend, Schwerpunkt Woche 12–14)
- **Ziel:** Nachweisbare Qualität und Sicherheit vor Beta.
- **Aufgaben:** Testabdeckung kritischer Pfade, Zugriffsregel-Audit, Abhängigkeits-Scan, Lasttest Matching, externer Sicherheitstest (Angebot einholen), Datenschutzerklärung/AGB-Prüfung durch Fachperson, Moderationsprozess-Probelauf.
- **Ergebnis:** `TESTING.md`-Bericht mit Status je Funktion (Implementiert · Getestet · Nicht getestet · Bekanntes Problem).
- **Entscheidungen Gründer:** Budget für externe Rechts- und Sicherheitsprüfung. **Kostenpflichtig.**

## Phase 12 – Betatests (Woche 14–20)
- **Ziel:** Echte Treffen unter realen Bedingungen, kontrolliert.
- **Aufgaben:** Geschlossene Beta über TestFlight / Google Play Testing mit 50–150 Personen aus Warteliste und Communities; **geplante „Beta-Tage“** in ZRH, an denen Tester gezielt Zeitfenster eintragen (künstliche Dichte); Interviews nach Treffen; Fehlerbehebung.
- **Abhängigkeiten:** Rechtsprüfung abgeschlossen; Moderation einsatzbereit.
- **Ergebnis:** Beta-Bericht mit Kennzahlen aus `MVP_DEFINITION.md` §4.
- **Entscheidungen Gründer:** Freigabe für Store-Einreichung.

## Phase 13 – App-Store-Veröffentlichung (Woche 20–23)
- **Ziel:** Öffentlich verfügbar in ZRH-Fokus.
- **Aufgaben:** Store-Texte DE/EN, Screenshots, Datenschutz-Angaben (App Privacy / Data Safety), Altersfreigabe 18+, Prüfnotizen für Apple (Moderationsprozess, Demo-Zugang), Einreichung, Reaktion auf Ablehnungen.
- **Ergebnis:** Apps live in beiden Stores.
- **Entscheidungen Gründer:** **Veröffentlichung – ausdrückliche Freigabe.** Verfügbarkeitsländer (Empfehlung: zunächst CH, DE, AT, EU).

## Phase 14 – Nutzergewinnung (ab Woche 10 vorbereitend, ab Launch aktiv)
- **Ziel:** Dichte in ZRH erreichen.
- **Aufgaben:** Warteliste aktivieren; Community-Partnerschaften (Sprachtandems, Hochschulen, Expat-Gruppen); Inhalte („Was tun mit 3 h in ZRH?“); Gespräche mit 3–5 Gastronomiebetrieben airside; Event-Kalender ZRH.
- **Ergebnis nach 12 Wochen – vorgeschlagene Go-Kriterien für Standort 2 (eigene Startwerte):**
  - ≥ 50 % der Zeitfenster haben mindestens einen passenden Kandidaten.
  - ≥ 20 % der Zeitfenster führen zu einem Match.
  - ≥ 30 % der Matches melden ein Treffen.
  - ≥ 25 % der aktiven Nutzer tragen innerhalb von 90 Tagen ein zweites Zeitfenster ein.
  - Keine schweren Sicherheitsvorfälle.
- **Entscheidungen Gründer:** Marketingbudget; Fortsetzung/Anpassung/Stopp.

## Phase 15 – Weiterentwicklung und Skalierung
- **Ziel:** Bewiesenes Playbook auf weitere Flughäfen übertragen, Erlöse testen.
- **Aufgaben:** Version 1.1 (Flugstatus, Bildmoderation, Störungsmodus); MUC-Start; Partner-Treffpunkte; Trip-Pass-Test; erste B2B-Gespräche mit Nutzungsdaten.
- **Entscheidungen Gründer:** Expansionsreihenfolge, Finanzierung (Bootstrapping vs. Investoren), Team.

---

## Querschnitt: Rechtliches & Organisation (nicht technisch, aber kritisch)

| Thema | Spätestens bis | Wer |
|---|---|---|
| Nebentätigkeit mit aktuellem Arbeitgeber klären | vor öffentlichem Auftritt | Gründer |
| Rechtsform und Sitz (Wohnsitzwechsel CH→DE 01.01.2027 berücksichtigen) | vor Store-Launch, idealerweise vor Apple-Organisationskonto | Gründer + Fachberatung |
| Markenrecherche/-anmeldung „GateBuddy“ | vor Launch | Gründer (Claude bereitet vor) |
| Impressum, Datenschutzerklärung, AGB | Landingpage (W2) bzw. Beta | Claude Entwurf, Fachperson prüft |
