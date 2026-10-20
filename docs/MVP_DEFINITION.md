# GATEBUDDY – MVP-DEFINITION (Vorschlag)

> Stand: 20.10.2026 · Status: **[EMPFEHLUNG]** – Freigabe durch Gründer ausstehend
> Nutzen/Aufwand: H = hoch, M = mittel, N = niedrig

## 1. Ziel des MVP

Eine im App Store und Google Play veröffentlichte App, die **an einem Flughafen (Empfehlung: Zürich)** beweist oder widerlegt:

1. Reisende planen oder aktivieren Zeitfenster freiwillig.
2. Es entstehen beidseitige Matches.
3. Aus Matches werden reale Treffen.
4. Es gibt keine Sicherheitsvorfälle, die das Konzept infrage stellen.

Alles, was zu diesen vier Punkten nichts beiträgt, gehört nicht ins MVP.

## 2. Kern-Ablauf

```
Registrieren (18+) → Profil (Name, Sprachen, Interessen) → Flughafen wählen
→ Zeitfenster: „jetzt bis 15:30“ ODER „Do 14–17 Uhr“ + Kontaktinteressen
→ Liste passender Personen mit Zeitüberschneidung
→ „Interesse“ / „Weiter“ (still) → bei Gegenseitigkeit: Match + Push
→ Chat → Treffen an öffentlichem Ort → optional kurzes Feedback „Habt ihr euch getroffen?“
```

## 3. Priorisierung

### A. Unverzichtbar für das MVP

| Funktion | Nutzen | Aufwand | Begründung |
|---|---|---|---|
| Login: Sign in with Apple, Google, E-Mail-Code | H | M | Kontopflicht entschieden; Apple 4.8 |
| Altersbestätigung 18+ + Store-Einstufung 18+ | H | N | Schutz, Store-Anforderung |
| Nutzungsbedingungen + Datenschutz akzeptieren | H | N | Apple 1.2, Recht |
| Profil: Name/Nickname, Sprachen (spricht/übt), Interessen, Kurzbeschreibung | H | M | Entschieden |
| Profilbild optional (Sichtbarkeit nach Match – Entscheidung O-3) | M | M | Entschieden als optional |
| Flughafenauswahl (ZRH aktiv, andere „bald“ + Interesse sammeln) | H | N | Fokus + Nachfragemessung für Standort 2 |
| Optionale einmalige Standortbestätigung | M | M | Vertrauen („wirklich vor Ort“) |
| Zeitfenster jetzt **und** vorab (bis 14 Tage) | H | M | Zentraler Cold-Start-Hebel |
| Kontaktinteressen je Zeitfenster | H | N | Positionierung, Matching |
| Sichtbarkeit ein/aus + automatisches Ablaufen | H | N | Entschieden |
| Kandidatenliste mit Überschneidung + Sortierung | H | M | Kernfunktion |
| Interesse/Weiter, stille Ablehnung, Match | H | M | Entschieden |
| 1:1-Text-Chat nur nach Match | H | M | Entschieden |
| Blockieren, Melden (Profil + Nachricht) | H | M | Entschieden, Store-Pflicht |
| Wortfilter, Rate-Limits | M | N | Store-Pflicht „Filtermethode“, Spam |
| Interne Moderationsansicht + E-Mail-Alarm | H | M | 24-h-Reaktionspflicht |
| Push: Match, Nachricht, passendes Zeitfenster | H | M | Ohne Push keine Reaktion bei Wartezeiten |
| Account löschen in der App | H | N | Store-Pflicht, Datenschutz |
| Sicherheitshinweise vor erstem Treffen | H | N | Vertrauen, Haftung |
| Ehrlicher Leerzustand mit Zählern geplanter Zeitfenster | H | N | Cold Start |
| Deutsch + Englisch | H | N | ZRH-Publikum |
| Anonyme Nutzungsmessung (Zeitfenster, Matches, Treffen) | H | N | Ohne Daten keine Go/No-Go-Entscheidung |
| Feedback „Getroffen? 👍/👎“ nach Match | H | N | Einzige Messung realer Treffen |

### B. Sinnvoll für Version 1.1

| Funktion | Nutzen | Aufwand | Begründung für Verschiebung |
|---|---|---|---|
| Live-Flugstatus (Verspätung, Boarding) | M | M | Laufende Kosten, Lizenzfragen; Kernnutzen auch ohne |
| Automatische Bildmoderation | M | M | Erst bei Volumen nötig |
| Störungsmodus (Streik/Wetter-Hinweis) | M | M | Seltene, aber starke Dichte-Momente |
| Treffpunkt-Vorschläge (öffentliche Orte im Terminal) | M | N | Erfordert Ortskenntnis/Daten |
| Weitere Sprachen (FR, IT, ES) | M | N | Nach Nutzerherkunft priorisieren |
| Verifiziertes Profil (z. B. Selfie-Abgleich) | M | H | Vertrauen; Anbieterwahl + Kosten |
| Einladungslink („Freund mitbringen“) | M | N | Wachstum |

### C. Später relevant

| Funktion | Bedingung |
|---|---|
| Zweiter Flughafen (MUC) | Go-Kriterien in ZRH erfüllt |
| Partner-Treffpunkte („GateBuddy Spots“), Angebote | Nachweis realer Treffen |
| Trip Pass / Premium | Nachweis wiederholter Nutzung |
| Kleine Gruppen-Treffen (3–4 Personen) | Nachfrage aus Feedback |
| Event-Modus (Messen, Kongresse) | Erste Tests erfolgreich |
| B2B-Dashboard für Partner (nur aggregierte Zahlen) | Partnerinteresse belegt |
| Weitere Sprachen, internationale Expansion | Playbook in 2 Flughäfen bewiesen |

### D. Vorerst nicht erforderlich

| Funktion | Grund |
|---|---|
| Gate-Erkennung / Indoor-Ortung | Technisch unzuverlässig, Datenschutzrisiko |
| Kartenansicht mit Positionen anderer | Sicherheitsrisiko, widerspricht Leitprinzip 2 |
| KI-Matching | Kein Mehrwert ohne Daten |
| Bordkarten-Scan / Flugverifizierung | Aufwand + sensible Daten; Flugnummer ist bewusst kein Nachweis |
| Swipe-Oberfläche | Dating-Assoziation |
| Foto-/Sprachnachrichten, Videoanruf | Moderationsaufwand |
| Werbung | Reichweite zu klein, schadet Vertrauen |
| Web-App | Mobile-Kontext genügt |
| Geschlechterfilter | Dating-Drift – bewusste Gründerentscheidung (O-7) |

## 4. Erfolgsmessung (Vorschlag, Schwellen sind Startwerte – keine Branchenstandards)

| Kennzahl | Definition |
|---|---|
| Aktivierung | Anteil Registrierter mit mindestens einem Zeitfenster |
| Überschneidungsquote | Anteil Zeitfenster mit mindestens einem passenden Kandidaten |
| Match-Quote | Anteil Zeitfenster mit mindestens einem Match |
| Treffen-Quote | Anteil Matches mit bestätigtem Treffen |
| Wiederkehr | Anteil Nutzer mit zweitem Zeitfenster innerhalb 90 Tagen |
| Sicherheit | Meldungen pro 100 Matches, Anteil berechtigter Meldungen |

Konkrete Go/No-Go-Schwellen: `ROADMAP.md`, Phase 14.

## 5. Bewusste Risiken des MVP-Zuschnitts

- Ohne Live-Flugdaten wirkt die App weniger „smart“ – akzeptiert, weil der Kernnutzen Begegnung ist.
- Foto erst nach Match könnte Vertrauen vor dem Match senken – im Beta-Test beobachten.
- Nur ein Flughafen begrenzt die Nutzerbasis – gewollt, um Dichte zu erzeugen.
