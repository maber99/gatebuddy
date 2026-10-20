# GATEBUDDY – MASTER CONTEXT

> Zentrale Wissensbasis für GateBuddy. Jede Sitzung (Chat, Claude Code) liest dieses Dokument zuerst.
> Stand: 20.10.2026 · Version 0.2 · Pflege: Claude, Freigabe: Gründer (Marco)

## Legende (verbindlich für dieses Dokument)

| Kennzeichnung | Bedeutung |
|---|---|
| **[ENTSCHIEDEN]** | Vom Gründer getroffene Entscheidung. Änderung nur durch den Gründer. |
| **[ANNAHME]** | Vorläufige Arbeitsannahme. Muss validiert oder bestätigt werden. |
| **[EMPFEHLUNG]** | Vorschlag von Claude. Gilt erst nach Freigabe (dann Eintrag in `DECISIONS.md`). |
| **[OFFEN]** | Offene Frage. Blockiert ggf. spätere Arbeit. |

Verwandte Dokumente: `FEASIBILITY_ANALYSIS.md` (Risiken, Markt, Cold Start) · `ARCHITECTURE.md` · `MVP_DEFINITION.md` · `ROADMAP.md` · `PROJECT_ORGANIZATION.md` · `DECISIONS.md`

---

## 1. Projektstand

| Thema | Stand | Status |
|---|---|---|
| Markenname | GateBuddy | [ENTSCHIEDEN] |
| Domain | gatebuddy.app, registriert bei Cloudflare, aktiv | [ENTSCHIEDEN] |
| Markenrechtliche Prüfung „GateBuddy“ | Nicht durchgeführt. Eine einfache Websuche ergab keine gleichnamige App; das ersetzt keine Markenrecherche (EUIPO, Swissreg, DPMA, USPTO). | [OFFEN] |
| Rechtsträger / Firma | Nicht gegründet | [OFFEN] |
| Code | Noch keiner | – |
| Tech-Stack | React Native + Expo + TypeScript + Supabase, Datenregion Frankfurt (ADR-001–003) | [ENTSCHIEDEN] |
| Startflughafen | Zürich (ZRH), ausschliesslich (ADR-005) | [ENTSCHIEDEN] |
| Mindestalter | 18 Jahre (ADR-006) | [ENTSCHIEDEN] |
| Profilbild-Sichtbarkeit | Nutzer entscheidet; Standard: erst nach Match (ADR-007) | [ENTSCHIEDEN] |
| Entwicklungsansatz | KI-gestützt mit Claude Code, Code vollständig im Eigentum des Gründers | [ENTSCHIEDEN] |
| Zielplattformen | iOS und Android | [ENTSCHIEDEN] |

## 2. Produktvision

**[ENTSCHIEDEN]** GateBuddy ist eine mobile Plattform, die Reisenden an Flughäfen spontane, beidseitig gewollte Begegnungen ermöglicht – für Kaffee, Gespräche, Networking, Sprachpraxis und gemeinsame Zeit. Keine reine Dating-App.

**[EMPFEHLUNG] Präzisierte Vision (Arbeitsfassung):**
> „Aus Wartezeit wird gemeinsame Zeit – sicher, freiwillig und ohne peinliche Momente.“

**[EMPFEHLUNG] Leitprinzipien für jede Produktentscheidung:**
1. **Zustimmung vor Kontakt** – nichts passiert ohne beidseitiges Ja.
2. **Ortsnähe ohne Ortung** – „am selben Flughafen“, nie „an Gate B34“.
3. **Zeitlich begrenzt** – Sichtbarkeit endet automatisch.
4. **Ehrliche Leere** – keine Fake-Profile, keine geschönten Nutzerzahlen.
5. **Absicht statt Aussehen** – Kontaktinteresse und Sprache stehen im Vordergrund, nicht Fotos.

## 3. Zielgruppen

| Segment | Begründung | Status |
|---|---|---|
| Umsteigepassagiere mit 1,5–5 h Aufenthalt | Längste ungenutzte Zeit airside, kein „Heimweg“ | [ANNAHME] Primärsegment |
| Allein reisende Geschäftsreisende | Häufigkeit, Networking-Motiv | [ANNAHME] – Achtung: Vielflieger verbringen tendenziell wenig Zeit am Flughafen (s. Feasibility) |
| Allein reisende Freizeitreisende, Backpacker, Digital Nomads | Offenheit für neue Kontakte | [ANNAHME] |
| Sprachlernende, internationale Studierende | Klares, nicht-romantisches Motiv („Sprachen üben“) | [ANNAHME] |
| Reisende bei Verspätungen/Streiks | Hohe, plötzliche Gleichzeitigkeit | [ANNAHME] |
| Minderjährige | Ausgeschlossen | [ENTSCHIEDEN] Mindestalter 18 (ADR-006) |

## 4. Anwendungsfälle

**[ENTSCHIEDEN] Kontaktinteressen (Beispiele des Gründers):** Gemeinsam Kaffee trinken · Ungezwungene Gespräche · Business-Networking · Sprachkenntnisse trainieren · Neue Menschen kennenlernen · Reiseerfahrungen austauschen.

**[EMPFEHLUNG] Kern-Szenarien für das MVP:**
1. *Spontan:* „Ich bin jetzt in ZRH, bis 15:30 frei, offen für Kaffee.“ → sieht andere aktive Personen → beidseitiges Interesse → Chat → Treffen an einem öffentlichen Ort.
2. *Geplant (Cold-Start-Hebel):* „Ich bin am Donnerstag 14–17 Uhr in ZRH.“ → GateBuddy benachrichtigt, sobald jemand mit überlappendem Zeitfenster passt.
3. *Störungsfall:* Verspätung → Nutzer aktiviert Sichtbarkeit → sieht andere Betroffene.

## 5. Bisherige Produktentscheidungen [ENTSCHIEDEN]

**Account & Registrierung**
- Nutzerkonto erforderlich, kein Gastmodus.
- Registrierung über geeignete Authentifizierungsverfahren (konkrete Verfahren: [OFFEN], Empfehlung in `ARCHITECTURE.md`).
- Persönliches Profil wird angelegt.
- Flugnummer bei Registrierung nicht erforderlich.

**Profil**
- Vorname oder Nickname · optionales Profilbild · Interessen · gesprochene Sprachen · Sprachen zum Üben · optionale Selbstbeschreibung.

**Flughafen & Flug**
- Flughafen wählen oder erkennen lassen.
- Flugnummer freiwillig, jederzeit änderbar, kein Pflichtbestandteil des Profils.
- Flugnummer ist kein Buchungsnachweis.
- Langfristig: aktuelle Fluginformationen inkl. Verspätungen und Boarding-Zeiten.
- Zuverlässige Gate-Erkennung ist nicht validiert.
- Fluginformationen ersetzen nie offizielle Airline-/Flughafeninformationen.

**Matching & Kontakt**
- Entdecken aktiver Nutzer am selben Flughafen.
- Interessen und Sprachen werden berücksichtigt.
- Kontakt nur bei gegenseitigem Interesse; Ablehnungen werden nicht angezeigt.
- Privater Chat erst nach gegenseitigem Interesse.
- Nutzer steuern ihre Sichtbarkeit.
- Blockieren und Melden möglich.

**Positionierung**
- Keine reine Dating-App; Fokus auf spontane Begegnungen, Networking, gemeinsame Aktivitäten.

## 6. Geplante Funktionen (Übersicht)

Priorisierung im Detail: `MVP_DEFINITION.md`.

| Funktion | Einordnung | Status |
|---|---|---|
| Registrierung, Profil, Interessen, Sprachen | MVP | [ENTSCHIEDEN] als Funktion, Umfang [EMPFEHLUNG] |
| Flughafen wählen + optionale Standortprüfung | MVP | [EMPFEHLUNG] |
| „Jetzt verfügbar bis …“ (zeitlich begrenzte Sichtbarkeit) | MVP | [EMPFEHLUNG] |
| Vorab-Zeitfenster („bin am … in …“) | MVP | [EMPFEHLUNG] – zentraler Cold-Start-Hebel |
| Gegenseitiges Interesse, stille Ablehnung | MVP | [ENTSCHIEDEN] |
| 1:1-Text-Chat nach Match | MVP | [ENTSCHIEDEN] |
| Blockieren, Melden, Moderation | MVP | [ENTSCHIEDEN] + App-Store-Pflicht |
| Push-Benachrichtigungen | MVP (Match, Nachricht) | [EMPFEHLUNG] |
| Flugnummer manuell (ohne Live-Daten) | MVP optional | [EMPFEHLUNG] |
| Live-Flugstatus (Verspätung, Boarding) | Version 1.1 | [EMPFEHLUNG] |
| Mehrsprachigkeit | MVP: Deutsch + Englisch | [EMPFEHLUNG] |
| Gate-Erkennung | Vorerst nicht | [EMPFEHLUNG] |
| Monetarisierung, B2B | Nach Validierung | [EMPFEHLUNG] |

## 7. Noch offene Produktentscheidungen [OFFEN]

| # | Frage | Empfehlung von Claude |
|---|---|---|
| ~~O-1~~ | Start-Flughafen | **Entschieden: nur Zürich (ADR-005)** |
| ~~O-2~~ | Mindestalter | **Entschieden: 18 Jahre (ADR-006)** |
| ~~O-3~~ | Wann ist das Profilbild sichtbar? | **Entschieden: Nutzer wählt „für alle am Flughafen“ oder „erst nach Match“; Standard „erst nach Match“ (ADR-007)** |
| O-4 | Login-Verfahren | Sign in with Apple + Google + E-Mail-Einmalcode |
| O-5 | Wird Standort geprüft oder nur gewählt? | Wählen + einmalige, optionale Standortbestätigung; keine laufende Ortung |
| O-6 | Wie lange bleibt jemand sichtbar? | Selbst gewähltes Zeitfenster, max. 6 h, danach automatisch unsichtbar |
| O-7 | Geschlechtsangabe / Filter? | Keine Pflichtangabe, kein Geschlechterfilter im MVP (Dating-Drift vermeiden) – bewusste Entscheidung des Gründers nötig |
| O-8 | Treffpunkt-Vorschläge | Öffentliche Orte; später Partner-Cafés („GateBuddy Spots“) |
| O-9 | Rechtsform, Sitz, Gründungszeitpunkt | Vor öffentlichem Launch gründen; Beratung wegen Wohnsitzwechsel CH→DE (01.01.2027) |
| O-10 | Validierungs-Schwellen (Go/No-Go) | Vorschlag in `ROADMAP.md`, Phase 2 |

## 8. Technische Anforderungen

**[ENTSCHIEDEN]** iOS + Android · vollständig kontrollierbarer Quellcode · KI-gestützte Entwicklung · React Native + Expo + TypeScript · Supabase in Frankfurt (EU).
**[EMPFEHLUNG]** (Begründung in `ARCHITECTURE.md`):
- Zugriffsschutz auf Datenbankebene (Row Level Security) für jede Tabelle.
- Getrennte Umgebungen: Entwicklung, Staging, Produktion.
- Automatisierte Tests + CI (GitHub Actions) vor jedem Merge.
- Keine dauerhafte Speicherung von GPS-Koordinaten.
- Fluginformationen nur über serverseitige Funktion mit Cache (Kostenkontrolle).
- Internationalisierung ab Tag 1 (keine fest eingebauten Texte).

## 9. Geschäftsziele

**[ENTSCHIEDEN]** Marktfähiges MVP · Validierung des Nutzerbedarfs · internationale Nutzerbasis · nachhaltige Monetarisierung · B2B-Partnerschaften · Skalierung.

**[EMPFEHLUNG] Reihenfolge:** Bedarf und Nutzungsdichte an *einem* Flughafen nachweisen → erst dann Monetarisierung und zweiter Standort. Kennzahlen und Schwellen: `ROADMAP.md`.

**[ANNAHME]** Direkte B2C-Zahlungsbereitschaft ist gering (seltene Nutzung pro Person). B2B2C (Gastronomie, Flughäfen) ist die plausiblere Erlösquelle – unbelegt, muss validiert werden.

## 10. Sicherheitsanforderungen [EMPFEHLUNG, teils Store-Pflicht]

- Melden von Profilen und Nachrichten; Blockieren; Reaktion auf Meldungen innerhalb 24 h (Apple-Anforderung, s. Feasibility §6).
- Nutzungsbedingungen mit Null-Toleranz gegenüber missbräuchlichen Inhalten, vor Nutzung zu akzeptieren.
- Filter für anstössige Inhalte (Text-Filter MVP, Bildprüfung später).
- Kontaktinformationen des Betreibers in der App.
- Keine exakten Standorte, keine Gate-Anzeige gegenüber anderen Nutzern.
- Sicherheitshinweise vor dem ersten Treffen (öffentlicher Ort, kein Verlassen des Sicherheitsbereichs gemeinsam mit Fremden etc.).
- Rate-Limits gegen Spam; Sperren von Geräten/Konten.
- Admin-Moderation mit Protokoll.
- Account-Löschung direkt in der App.

## 11. Datenschutzanforderungen [EMPFEHLUNG]

- Rechtsrahmen: EU-DSGVO und Schweizer revDSG; bei Rechtsträger in der EU zusätzlich EU Digital Services Act (Pflichten u. a. Melde-/Abhilfeverfahren).
- Datensparsamkeit: Standort nur als Flughafen-Code + Zeitfenster speichern.
- Flugnummer: freiwillig, nur so lange gespeichert wie nötig, für andere Nutzer standardmässig unsichtbar.
- Chats: Aufbewahrungsfrist festlegen ([OFFEN]); Zugriff durch Moderation nur bei Meldung.
- Datenverarbeitungsvereinbarungen (DPA) mit allen Dienstleistern.
- Datenschutzerklärung und Nutzungsbedingungen vor Beta durch Fachperson prüfen lassen.
- Keine Weitergabe/Verkauf von Nutzerdaten an Partner – auch nicht für B2B. [EMPFEHLUNG, sollte als Grundsatz entschieden werden]

## 12. Designvorgaben

**[ENTSCHIEDEN]** International verständlich · einfach und intuitiv · vertrauensbildend · vermeidet unangenehme Situationen · barrierearm.
**[OFFEN]** Farben, Logo, Typografie, Tonalität. Noch keine Designvorgaben vorhanden.
**[EMPFEHLUNG]** Ruhige, „aviation-neutrale“ Gestaltung; keine Swipe-Mechanik im Tinder-Stil (Dating-Assoziation); Barrierefreiheit nach WCAG-Grundsätzen; Dark Mode.

## 13. Entwicklungsstrategie

**[ENTSCHIEDEN]** Claude Code entwickelt, Gründer entscheidet. Kosten und Veröffentlichungen nur nach Freigabe.
**[EMPFEHLUNG]**
1. Validierung (Landingpage, Interviews) **parallel** zur technischen Einrichtung – nicht nacheinander.
2. Ein Flughafen, ein Funktionsumfang, ein klarer Erfolgsmassstab.
3. Jede Funktion mit Tests; Status-Kennzeichnung: *Implementiert · Getestet · Nicht getestet · Bekanntes Problem · Geplant*.
4. Entscheidungen als ADR in `DECISIONS.md`.

## 14. Glossar

| Begriff | Bedeutung |
|---|---|
| Airside | Bereich nach der Sicherheitskontrolle |
| Cold Start | Startphase, in der zu wenige Nutzer gleichzeitig aktiv sind |
| Match | Beidseitig bekundetes Interesse |
| Zeitfenster / Check-in | Zeitraum, in dem ein Nutzer am Flughafen sichtbar ist |
| RLS | Row Level Security – Zugriffsregeln direkt in der Datenbank |
| ADR | Architecture/Any Decision Record – dokumentierte Entscheidung |
| MAU | Monatlich aktive Nutzer |
