# Änderungsprotokoll

## [0.1.0] – 20.10.2026 – Fundament

### Entschieden (Gründer)
- Technik: React Native + Expo + TypeScript + Supabase, Daten in Frankfurt (ADR-001–003)
- Start ausschliesslich am Flughafen Zürich (ADR-005), Mindestalter 18 (ADR-006)
- Profilbild: Nutzer wählt, Standard „erst nach Match“ (ADR-007)

### Neu
- Projektdokumentation: Master-Kontext, Machbarkeitsanalyse, Architektur, MVP, Roadmap, Organisation, Entscheidungsregister, Testbericht, Dateninventar
- Datenbank: Profile, Sprachen, Interessen, Zeitfenster, Interesse/Weiter, Matches, Chat, Blockieren, Melden, Moderation, Kennzahlen, Aufräumen – mit Zugriffsregeln auf jeder Tabelle
- 128 Datenbank-Tests (alle bestanden)
- App-Gerüst (Expo SDK 58): Start, E-Mail-Anmeldung, Profil anlegen, Flughafen/Zeitfenster, Kandidaten, Matches, Einstellungen, Sicherheitstipps; Deutsch und Englisch
- 63 App-Tests (alle bestanden), Typ- und Codeprüfung fehlerfrei, iOS- und Android-Bundles erfolgreich gebaut
- GitHub-Vorlagen: automatische Prüfungen (CI), Dependabot, Pull-Request- und Issue-Vorlagen
