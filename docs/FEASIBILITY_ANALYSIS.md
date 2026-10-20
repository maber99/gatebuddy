# GATEBUDDY – KRITISCHE MACHBARKEITSPRÜFUNG

> Stand: 20.10.2026 · Perspektive: Gründer, CTO, Investor
> Kennzeichnung: **[FAKT]** = mit Quelle belegt · **[SCHÄTZUNG]** = eigene Rechnung mit offengelegten Annahmen · **[HYPOTHESE]** = plausibel, unbelegt, muss getestet werden

---

## 0. Gesamturteil

**Technisch: gut machbar.** Kein Bestandteil des MVP erfordert Forschung; der empfohlene Stack deckt alles ab.

**Marktseitig: hohes Risiko.** Die Idee ist nicht neu. Seit mindestens 2011 gab es mehrere Anläufe (Airline-Programme und Startups), von denen nach meiner Recherche keiner breite Verbreitung erreicht hat. Das Kernproblem ist nicht die Software, sondern **Gleichzeitigkeit**: genug passende, offene Menschen am selben Ort zur selben Zeit.

**Wirtschaftlich: unbelegt.** Weder Zahlungsbereitschaft noch B2B-Nutzen sind nachgewiesen. Beides muss vor nennenswerten Investitionen getestet werden.

**Empfehlung:** Weiterverfolgen – aber mit einem bewusst kleinen, günstigen MVP, einem einzigen Startflughafen, einem Produktdesign, das mit wenigen Nutzern funktioniert (Vorab-Zeitfenster statt nur „jetzt“), und klaren Abbruchkriterien.

---

## 1. Tatsächlicher Nutzerbedarf

**[FAKT] Es gibt Bedarf, Fremde strukturiert kennenzulernen – nicht dating-bezogen.** Timeleft (Abendessen mit Fremden) startete im Mai 2023 in Lissabon und meldet nach eigenen Angaben über 1 Mio. App-Nutzer sowie wöchentlich über 15.000 Teilnehmende in über 275 Städten. Quelle: Timeleft-Unternehmensprofil (cake.me), Connexion France.
→ Relevant ist **warum** Timeleft funktioniert: Es bündelt Menschen künstlich auf **einen festen Termin (mittwochs)**. Das ist eine Lösung für genau das Dichteproblem, das GateBuddy hat.

**[FAKT] Die Flughafen-Variante hat eine lange Liste gescheiterter oder stagnierter Vorgänger:**
- KLM „Meet & Seat“ (2012): Sitzplatzwahl nach Social-Profil. In einer Umfrage von TripAdvisor gaben nur 9 % der US-Befragten an, so etwas nutzen zu wollen; Vielflieger berichteten später, das Angebot praktisch nie im Einsatz gesehen zu haben. Quellen: NBC News, BoardingArea.
- MeetAtTheAirport.com (seit 2011): NBC berichtete von Startschwierigkeiten; positioniert sich heute als Dating-Plattform.
- Lounger, Btrfly, AirDates (Mitte der 2010er-Jahre, genaue Jahre nicht verifiziert): alle mit Dating-Ausrichtung, medial beachtet, keine erkennbare dauerhafte Verbreitung. Quellen: SmarterTravel, Traveller.com.au, The Zoe Report.
- Flight Mate (ca. 2022/23): Sitzplatz-Sharing und Kontakte am Flughafen. Quelle: MTL Blog.

**[FAKT] Aktuelle Wettbewerber (Stand Recherche Oktober 2026):**
| Anbieter | Ausrichtung | Hinweis |
|---|---|---|
| Layover AI | KI-Reiseassistent + Kontakte zu Mitreisenden, Pro-Abo 4,99 USD/Monat | App Store / Google Play, Angabe „200+ Flughäfen“ |
| Runaway | Dating/Social an Flughäfen, Flug-Authentifizierung per Bordkarte | Google Play |
| Almost | Matching nach Flughafen und Zeitfenster, Dating/Freundschaft/Business, gegenseitige Zustimmung | Laut Entwickler mit FlutterFlow + Supabase gebaut, live in beiden Stores |
| Aere Social | Social-Travel-App, Warteliste | Noch nicht gestartet |
| MeetAtTheAirport | Airport-Dating (Web) | Seit 2011 |

Nutzerzahlen dieser Anbieter konnte ich **nicht** verifizieren. Daraus folgt nicht, dass sie klein sind – nur, dass es keine öffentlichen Belege für Erfolg gibt.

**[HYPOTHESE] Interpretation:** Das wiederholte Scheitern spricht dafür, dass entweder (a) der Bedarf kleiner ist als intuitiv angenommen, oder (b) alle Anbieter am Dichteproblem und an der Dating-Drift gescheitert sind. GateBuddy hat nur eine Chance, wenn (b) zutrifft und das Produkt genau diese zwei Probleme anders löst.

**[HYPOTHESE] Gegenkräfte zum Bedarf:**
- Viele Reisende wollen am Flughafen ihre Ruhe (Arbeit, Telefonate, Erschöpfung).
- Vielflieger verbringen tendenziell *weniger* Zeit am Flughafen; Lounge-Nutzer sind eine kleine Gruppe.
- Sicherheits- und Peinlichkeitsbedenken, besonders bei Frauen.
- Zeitdruck: Boarding-Aufrufe machen Treffen unplanbar.

**[FAKT] Freie Zeit airside ist begrenzt und sinkt:** Laut einer von Kearney für die TFWA erstellten Auswertung sank die freie Zeit airside in Asien-Pazifik zwischen 2018 und 2024 von etwa 60 auf 44 Minuten. Quelle: KSI Vision. Für Transferpassagiere dürfte sie deutlich länger sein [HYPOTHESE].

## 2. Marktpotenzial

**[FAKT] Passagierzahlen 2025:**
| Flughafen | Passagiere 2025 | Quelle |
|---|---|---|
| Zürich (ZRH) | 32,6 Mio. (Rekord, +4,5 %) | SRF, Flughafen Zürich via meilenoptimieren.com |
| München (MUC) | 43,4 Mio. (+4,4 %) | Flughafen München, Stadt München |
| Schweiz gesamt (ZRH, GVA, BSL) | ca. 60 Mio. | Bundesamt für Statistik via Südostschweiz |

**[FAKT] Transferanteil Zürich:** Monatswerte 2025 zwischen ca. 27,6 % (September) und 32 % (März). Quellen: aviation.direct, park-sleep-fly.de. Hoher Transferanteil = viele Menschen mit Wartezeit ohne Heimweg → günstig für GateBuddy.

**[SCHÄTZUNG] Was „Marktpotenzial“ hier wirklich bedeutet:** Nicht Passagiere pro Jahr, sondern **gleichzeitig anwesende, offene Nutzer**. Rechnung (Skript: `docs/research/density_estimate.py`):

Annahmen: Hälfte der gezählten Passagiere sind Abflüge; 18 relevante Betriebsstunden pro Tag; freie Zeit airside 0,75–1,5 h; gleichmässige Verteilung (in Wahrheit gibt es Spitzen).

| Flughafen | Abflüge/Tag | Ø gleichzeitig airside | Anteil aller Anwesenden, der aktiv sein müsste, damit **10** Personen sichtbar sind |
|---|---|---|---|
| ZRH | ca. 44.600 | ca. 1.900–3.700 | **0,27–0,54 %** |
| MUC | ca. 59.500 | ca. 2.500–5.000 | **0,20–0,40 %** |

Ein bis zwei von 200–400 Anwesenden müssten **in genau diesem Moment** GateBuddy installiert *und* geöffnet *und* sich sichtbar geschaltet haben. Das entspricht – grob – **10.000–20.000 aktiven Nutzern mit Bezug zu ZRH** (bei 8 Abflügen pro Nutzer und Jahr). Für ein unbekanntes Startup ohne Marketingbudget ist das ein sehr hohes Ziel.

**Konsequenz:** Ein reines „Wer ist jetzt gerade hier?“-Produkt wird am Anfang fast immer leer sein. Das Produkt muss so gebaut werden, dass es auch mit wenigen Nutzern Wert erzeugt (siehe §3).

## 3. Cold-Start-Problem – konkrete Strategien

Grundregel: **Dichte künstlich erzeugen, statt auf Zufall zu hoffen.** Bewertet nach Wirkung und Aufwand.

| # | Strategie | Wirkung | Aufwand | Empfehlung |
|---|---|---|---|---|
| 1 | **Ein einziger Startflughafen** (ZRH). Alle Marketing-Mittel dort bündeln. | hoch | gering | **MVP** |
| 2 | **Vorab-Zeitfenster:** Nutzer melden „Do 14–17 Uhr in ZRH“ Tage im Voraus an. Matching über *geplante Überschneidung*, nicht nur „jetzt“. Erhöht die effektive Dichte um ein Vielfaches, weil Überschneidungen über Tage gesammelt werden. | sehr hoch | mittel | **MVP – zentraler Hebel** |
| 3 | **Ehrlicher Leerzustand:** „Heute 3 geplante Zeitfenster in ZRH“ statt leerer Liste; Benachrichtigung, sobald jemand passt. Niemals Fake-Profile (Vertrauens- und Rechtsrisiko). | hoch | gering | **MVP** |
| 4 | **Community-Seeding:** Gezielte Startgruppen mit hoher Reisefrequenz und klarer Nicht-Dating-Motivation: Sprachtandem-Gruppen, Austauschstudierende, Expat-Communities, Vielflieger-Foren, Digital-Nomad-Gruppen. | mittel–hoch | mittel (Gründerzeit) | **Launch** |
| 5 | **Event-Wellen:** Grossanlässe, die viele Gleichgesinnte zeitgleich durch denselben Flughafen leiten (Messen, Kongresse, Sportereignisse). Termine konkret prüfen. | hoch, punktuell | mittel | **Nach Launch testen** |
| 6 | **Störungsmodus:** Bei Streik, Wetter oder Massenverspätungen gezielte Hinweise an Nutzer im Flughafen. | hoch, selten | gering | **1.1** |
| 7 | **Kooperation mit Gastronomie** als feste Treffpunkte („GateBuddy Spot“) + Sichtbarkeit vor Ort (Tischaufsteller, QR-Code). | mittel | hoch (Vertrieb) | **Nach Validierung** |
| 8 | **Kooperation mit Flughafen/Airline** (Kommunikationskanäle, WLAN-Portal). | sehr hoch | sehr hoch, langsam | **Später; erst mit Nutzungsdaten** |
| 9 | Ausweitung des „Ortes“ (z. B. Bahnhöfe) | unklar | hoch | Nicht empfohlen (Fokusverlust) |

**Geografisch begrenzter Start vs. sofort international:** Eindeutig **ein Flughafen**. Bei weltweitem Start verteilen sich wenige Nutzer auf hunderte Flughäfen; jede einzelne Person sieht dann niemanden und löscht die App. Netzwerkeffekte wirken lokal. Zweiter Flughafen erst, wenn der erste die Go-Kriterien erfüllt (`ROADMAP.md`).

**Warum Zürich als Start (Empfehlung, Entscheidung beim Gründer):**
- Hoher Transferanteil (ca. 28–32 %) → viele Wartende ohne Heimweg.
- Ein Terminal-Komplex mit gemeinsamem Airside-Bereich [HYPOTHESE – vor Ort zu prüfen; relevant für „Treffen ist praktisch möglich“].
- Nähe zum Gründer (Feldtests, Interviews vor Ort, Kontakte).
- Mehrsprachiges, internationales Publikum.
- Alternative München: grösser (43,4 Mio.), aber Terminals 1 und 2 räumlich getrennt [HYPOTHESE, vor Ort prüfen] – das kann Treffen erschweren.

## 4. Technische Machbarkeit

| Bereich | Bewertung |
|---|---|
| Registrierung, Profile, Matching, Chat, Push | Standardtechnik, gut machbar |
| Flughafenerkennung | Machbar über Geofence (Flughafengelände) bei geöffneter App. GPS in Gebäuden ist ungenau; für „bin am Flughafen“ reicht es [HYPOTHESE – im Feldtest prüfen]. |
| Unterscheidung landside/airside | Unzuverlässig per GPS. Lösung: Nutzer gibt es selbst an. |
| Gate-Erkennung | Nicht zuverlässig ohne Flughafen-Infrastruktur (Beacons, Indoor-Ortung). **Nicht verfolgen.** Zudem ein Datenschutz- und Sicherheitsrisiko. |
| Live-Flugdaten | Kommerziell verfügbar (AeroDataBox, FlightAware AeroAPI u. a.). Datenqualität und Lizenzbedingungen vor Einsatz prüfen; FlightAware „Personal“-Stufe ist laut Anbieter nur für persönliche/akademische Zwecke. |

## 5. Wirtschaftliche Tragfähigkeit

**[HYPOTHESE] B2C-Abo ist schwach:** Ein typischer Nutzer fliegt wenige Male pro Jahr; ein Monatsabo passt schlecht zu seltenem Bedarf. Layover AI verlangt 4,99 USD/Monat für ein Pro-Abo – ob das trägt, ist nicht öffentlich.

**Mögliche Erlösmodelle (alle unbelegt):**
| Modell | Plausibilität | Konflikt mit Nutzervertrauen |
|---|---|---|
| Einzelkauf pro Reise („Trip Pass“) statt Abo | mittel | gering |
| Premium (Vorab-Planung über mehrere Flughäfen, erweiterte Filter) | gering–mittel | gering |
| Partner-Gastronomie: Treffpunkt-Angebote („Kaffee für zwei“), Vermittlungsprovision | mittel | gering, wenn klar gekennzeichnet |
| Flughafen-Lizenz (Passenger-Experience-Angebot) | ungewiss, langer Vertriebszyklus | mittel |
| Werbung | gering bei kleiner Reichweite | hoch |
| Datenverkauf / Bewegungsprofile | – | **ausschliessen** |

**[FAKT] Warum Flughäfen grundsätzlich zuhören könnten:** Eine Studie über 89 US-Flughäfen fand, dass 10 % mehr Verweildauer mit etwa 5 % höheren Non-Aviation-Erlösen einhergehen. Quelle: Universität Bergamo / Universität Luxemburg (2024).
**[HYPOTHESE] Aber:** GateBuddy müsste nachweisen, dass es Konsum oder Zufriedenheit messbar steigert. Ohne eigene Nutzungsdaten ist ein B2B-Gespräch verfrüht.

**Kostenseite (MVP):** sehr gering (Details `ARCHITECTURE.md` §8). Das grösste „Kostenrisiko“ ist die Zeit des Gründers für Community-Aufbau und Moderation.

## 6. Recht, Plattformregeln, Datenschutz

**[FAKT] Apple App Store, Richtlinie 1.2 (nutzergenerierte Inhalte):** Social-Apps müssen u. a. Melden anstössiger Inhalte mit zeitnaher Reaktion und Blockieren missbräuchlicher Nutzer ermöglichen. In Ablehnungsschreiben nennt Apple zusätzlich: Nutzungsbedingungen mit Null-Toleranz, eine Filtermethode, Reaktion auf Meldungen innerhalb von 24 Stunden sowie Kontaktmöglichkeit in der App. Quellen: Apple App Review Guidelines, Apple Developer Forums.
→ **Betriebliche Konsequenz:** Jemand muss Meldungen täglich bearbeiten. Für einen Solo-Gründer ist das eine echte Verpflichtung.

**[FAKT] Apple Richtlinie 4.8 (Login-Dienste):** Wer Login über Drittanbieter (z. B. Google) anbietet, muss eine gleichwertige datenschutzfreundliche Option anbieten; Sign in with Apple erfüllt dies. Quelle: Apple Developer Forums.

**[FAKT] Altersprüfung verschärft sich:** Seit 24.02.2026 blockiert Apple in Australien, Brasilien und Singapur Downloads von 18+-Apps, sofern das Erwachsenenalter nicht bestätigt ist; die Declared Age Range API liefert Altersgruppen-Signale. Quellen: TechCrunch, 9to5Mac, Help Net Security.
→ 18+-Einstufung ist für eine App, die Treffen zwischen Fremden vermittelt, die sichere Wahl.

**[FAKT] EU Digital Services Act:** Gilt für Hosting-Dienste und Online-Plattformen; Melde- und Abhilfeverfahren gelten breit, zusätzliche Plattformpflichten sind für Klein- und Kleinstunternehmen ausgenommen. Quellen: Verordnung (EU) 2022/2065, ACT | The App Association.

**[FAKT] Apple-Entwicklerkonto:** Als Einzelperson erscheint der **persönliche Name** als Anbieter im App Store; als Organisation braucht es eine juristische Person und eine D-U-N-S-Nummer, Einrichtung dauert typischerweise mehrere Wochen. Jahresgebühr 99 USD. Quellen: exercise.com FAQ, Analytics Insight.
→ Spricht für eine Gründung vor dem öffentlichen Launch (Haftung, Privatsphäre des Gründers).

**Datenschutz (Fachprüfung erforderlich):** DSGVO und Schweizer revDSG; besonders heikel sind Standort- und Bewegungsdaten sowie Chats. Mein Vorschlag zur Minimierung steht in `GATEBUDDY_MASTER_CONTEXT.md` §11. Ich bin kein Anwalt – Datenschutzerklärung, AGB und Rechtsform vor Beta durch Fachperson prüfen lassen.

## 7. Sicherheitsrisiken

| Risiko | Schwere | Gegenmassnahme |
|---|---|---|
| Belästigung, Stalking, „Dating-Drift“ | hoch | Intent-basiertes Profil, Foto erst nach Match, keine exakte Position, Melden/Blockieren, schnelle Sperren |
| Ortungsrückschlüsse (wer ist wann wo) | hoch | Nur Flughafen-Code + Zeitfenster, automatisches Ablaufen, keine Historie für andere sichtbar |
| Fake-Profile, Spam, Betrug (Romance Scam) | mittel–hoch | Rate-Limits, Gerätesperren, Meldungen, später Verifizierung |
| Minderjährige | hoch | 18+-Einstufung, Altersbestätigung, Meldegrund „vermutlich minderjährig“ |
| Datenleck | hoch | Row Level Security, Pentest vor Launch, Minimaldaten |
| Moderationsüberlastung des Gründers | mittel | Klare Prozesse, Automatisierung, Eskalationsregeln |

## 8. Langfristige Skalierbarkeit

- **Technisch:** unkritisch bis weit über das realistische Nutzerziel der ersten Jahre hinaus.
- **Operativ:** Skalierung erfolgt Flughafen für Flughafen; jeder neue Standort braucht eigenen Community-Aufbau. Das ist teuer und langsam.
- **Strategisch:** Wenn ein Flughafen funktioniert, ist das Playbook übertragbar – genau das muss zuerst bewiesen werden.

## 9. Die zehn wichtigsten Risiken (priorisiert)

1. Zu geringe Gleichzeitigkeit → leere App → Abwanderung.
2. Bedarf geringer als angenommen (historische Belege).
3. Dating-Drift → Vertrauensverlust, Sicherheitsvorfälle.
4. Moderationspflichten (24 h) übersteigen Gründerkapazität.
5. Keine tragfähige Erlösquelle.
6. Sicherheitsvorfall bei einem realen Treffen → Reputationsschaden.
7. Datenschutzverstoss bei Standortdaten.
8. App-Store-Ablehnung (Richtlinien 1.2, 4.8, Alter).
9. Markenrechtliche Kollision mit „GateBuddy“ (nicht geprüft).
10. Persönliche Rahmenbedingungen: Gründung neben Anstellung (Nebentätigkeitsregeln prüfen) und Wohnsitzwechsel CH→DE zum 01.01.2027 beeinflussen Rechtsform, Sitz und Steuern – Fachberatung nötig.

---

## Quellen

- [SRF – Flughafen Zürich Passagierrekord 2025](https://www.srf.ch/news/schweiz/32-6-millionen-passagiere-flughafen-zuerich-verzeichnet-2025-einen-passagierrekord)
- [meilenoptimieren.com – Verkehrszahlen ZRH 2025](https://meilenoptimieren.com/newsticker/die-verkehrszahlen-des-flughafen-zuerich-aus-dem-jahr-2025/)
- [meilenoptimieren.com – Verkehrszahlen MUC 2025](https://meilenoptimieren.com/newsticker/die-verkehrszahlen-des-flughafen-muenchen-aus-dem-jahr-2025/)
- [Stadt München – Fluggastzahlen](https://stadt.muenchen.de/news/fluggastzahlen.html)
- [Südostschweiz – Schweizer Flughäfen 2025 (BFS)](https://www.suedostschweiz.ch/schweiz-und-welt/in-der-schweiz-wurde-noch-nie-so-viel-geflogen-wie-2025-2-1573826)
- [aviation.direct – ZRH November 2025](https://aviation.direct/flughafen-zuerich-verzeichnet-passagierzuwachs-im-november-2025)
- [park-sleep-fly.de – ZRH September 2025](https://www.park-sleep-fly.de/magazin/flughafen-zuerich/flughafen-zuerich-verkehrszahlen-september-2025/)
- [NBC News – Social Seating](https://www.nbcnews.com/news/amp/wbna47268816)
- [BoardingArea – Has Meet & Seat failed?](https://thegate.boardingarea.com/has-meet-seat-by-klm-royal-dutch-airlines-failed/)
- [NBC News – Airport dating site struggles](https://www.nbcnews.com/business/travel/airport-dating-site-struggles-liftoff-flna1c8773769)
- [SmarterTravel – Lounger](https://www.smartertravel.com/?p=67799) · [The Zoe Report – Btrfly, AirDates, Lounger](https://www.thezoereport.com/living/relationships/airport-dating-app)
- [MTL Blog – Flight Mate](https://www.mtlblog.com/flying-solo-a-new-app-can-help-you-make-friends-at-the-airport-on-your-flight)
- [Layover AI – App Store](https://apps.apple.com/us/app/layover-ai/id6752505298) · [Runaway – Google Play](https://play.google.com/store/apps/details?id=com.cliqueraft.runaway&hl=en_US) · [Almost – Contra](https://contra.com/p/c7RYk3Bm-almost-airport-connection-app-development) · [Aere Social](https://www.aeresocial.com/) · [MeetAtTheAirport](https://meetattheairport.com/)
- [Timeleft – Unternehmensprofil](https://www.cake.me/companies/timeleft?locale=ja) · [Connexion France – Timeleft](https://www.connexionfrance.com/news/how-to-meet-new-people-over-dinner-in-france-we-try-out-new-app/682998)
- [KSI Vision – Dwell Time](https://www.ksivision.com/en/blog/dwell-time-airports-non-aeronautical-revenue)
- [Wu et al. 2024 – Dwell Time and Non-Aeronautical Revenues](https://orbilu.uni.lu/bitstream/10993/63566/1/Airport_Dwell_Time%202024-05-07%20Resubmission%20R1.pdf)
- [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) · [Apple Forum – Guideline 1.2](https://developer.apple.com/forums/thread/807358) · [Apple Forum – Guideline 4.8](https://developer.apple.com/forums/thread/765145)
- [TechCrunch – Apple age verification](https://techcrunch.com/2026/02/24/apple-rolls-out-age-verification-tools-worldwide-to-comply-with-growing-web-of-child-safety-laws/) · [9to5Mac](https://9to5mac.com/2026/02/24/apple-expands-age-assurance-tools-as-new-app-store-requirements-roll-out-in-several-regions/)
- [ACT | The App Association – DSA Explainer](https://actonline.org/wp-content/uploads/Digital-Services-Act-Explainer-for-Members_Final-002.pdf)
- [exercise.com – Apple Developer Account FAQ](https://exercise.com/support/faq-apple-developer-account) · [Analytics Insight – Individual vs Organization](https://www.analyticsinsight.net/tech-news/apple-developer-account-requirements-for-individual-vs-business-developers)
- [FlightAware AeroAPI](https://flightaware.com/commercial/aeroapi/)
