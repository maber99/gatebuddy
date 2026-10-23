# GATEBUDDY – ENTSCHEIDUNGSREGISTER

> Index aller Entscheidungen. Nur der Gründer setzt den Status „Angenommen“.
> Stand: 20.10.2026

## Bereits getroffene Grundsatzentscheidungen (vor diesem Register)

| ID | Entscheidung | Status |
|---|---|---|
| D-000a | Markenname GateBuddy, Domain gatebuddy.app (Cloudflare) | Angenommen |
| D-000b | iOS + Android, Code vollständig im Eigentum des Gründers, Entwicklung mit Claude Code | Angenommen |
| D-000c | Kontopflicht, kein Gastmodus; Flugnummer freiwillig, jederzeit änderbar, kein Buchungsnachweis | Angenommen |
| D-000d | Kontakt nur bei gegenseitigem Interesse; Ablehnungen unsichtbar; Chat erst nach Match; Blockieren/Melden; Sichtbarkeit steuerbar | Angenommen |
| D-000e | Keine reine Dating-App | Angenommen |

## Register (ADR)

| ID | Frage | Empfehlung | Begründung (kurz) | Status |
|---|---|---|---|---|
| ADR-001 | App-Technologie | React Native + Expo + TypeScript | Eine Codebasis, Open Source, gute KI-Entwicklung | **Angenommen (20.10.2026)** |
| ADR-002 | Backend | Supabase (PostgreSQL, Auth, Realtime, Storage, Edge Functions) | Deckt MVP ab, Open Source, Migrationspfad zu jedem PostgreSQL | **Angenommen (20.10.2026)** |
| ADR-003 | Datenregion | Supabase Frankfurt (EU) | EU-Nutzer, Gründerwohnsitz DE ab 2027, einfachste DSGVO-Lage | **Angenommen (20.10.2026)** |
| ADR-004 | Rolle Cloudflare | Nur Domain, DNS, Landingpage, E-Mail-Weiterleitung, Bot-Schutz | Kein zweites Backend | **Vorgeschlagen** |
| ADR-005 | Startflughafen | Nur Zürich (ZRH); MUC als zweiter nach Go-Kriterien | Dichte, Transferanteil, Nähe | **Angenommen (20.10.2026)** |
| ADR-006 | Mindestalter | 18 Jahre, Store-Einstufung 18+ | Treffen mit Fremden, Store-Altersregeln | **Angenommen (20.10.2026)** |
| ADR-007 | Profilbild-Sichtbarkeit | Nutzer entscheidet selbst; Standard: erst nach Match | Wahlfreiheit, datenschutzfreundliche Voreinstellung | **Angenommen (20.10.2026), abweichend von Empfehlung „nur nach Match“** |
| ADR-008 | Login | Apple + Google + E-Mail-Code, kein Passwort | Apple 4.8, Sicherheit | **Vorgeschlagen** |
| ADR-009 | Standort | Einmalige Prüfung, nur Flughafen-Code speichern, keine Hintergrundortung, keine Gate-Erkennung | Datenschutz, Sicherheit, Zuverlässigkeit | **Vorgeschlagen** |
| ADR-010 | Zeitfenster | „Jetzt“ + „vorab bis 14 Tage“, automatisches Ablaufen, max. 6 h | Cold-Start-Hebel | **Vorgeschlagen** |
| ADR-011 | Fluginformationen | MVP manuell; Live-Daten ab v1.1 über Server-Funktion mit Cache | Kosten, Lizenz, Fokus | **Vorgeschlagen** |
| ADR-012 | Geschlechterangabe/-filter | Keine Pflichtangabe, kein Filter im MVP | Dating-Drift vermeiden | **Vorgeschlagen – bewusste Abwägung nötig** |
| ADR-013 | Datenweitergabe | Keine Weitergabe/kein Verkauf personenbezogener Daten an Partner; B2B nur aggregiert | Vertrauen als Kernwert | **Vorgeschlagen** |
| ADR-014 | Validierung | Landingpage + Interviews parallel zur Entwicklung, Go/No-Go nach 6 Wochen | Risiko früh senken ohne Stillstand | **Vorgeschlagen** |

## Vorlage für neue Entscheidungen (`docs/adr/ADR-XXX-titel.md`)

```markdown
# ADR-XXX: <Titel>
- Status: Vorgeschlagen | Angenommen | Abgelehnt | Ersetzt durch ADR-YYY
- Datum: JJJJ-MM-TT
- Entschieden von: Gründer
## Kontext
## Optionen (mit Vor-/Nachteilen, Kosten)
## Entscheidung
## Begründung
## Folgen (technisch, wirtschaftlich, rechtlich)
```
| ADR-015 | Paket-Updates | Expo/React/React Native nur gesammelt beim Expo-SDK-Wechsel; TypeScript folgt der Expo-Vorgabe; übrige Pakete ohne Hauptversionssprünge; Actions frei | Expo legt kompatible Versionen fest; Einzel-Updates können Builds brechen | **Technische Detailentscheidung (Claude), 23.10.2026** |
