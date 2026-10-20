# GATEBUDDY – DATENINVENTAR (Grundlage für die Datenschutzerklärung)

> Stand: 20.10.2026 · Status: **Entwurf – vor Beta durch Fachperson prüfen lassen.** Kein Rechtsrat.
> Jede neue personenbezogene Spalte wird hier eingetragen und begründet (Regel aus `CLAUDE.md`).

| Daten | Zweck | Wer sieht es | Speicherdauer (Vorschlag) |
|---|---|---|---|
| E-Mail (Anmeldung) | Login | Nur Betreiber (Supabase Auth) | Bis Kontolöschung |
| Anzeigename, Kurztext | Profil | Personen mit Zeitüberschneidung am selben Flughafen oder Match | Bis Kontolöschung |
| Sprachen, Interessen | Matching | wie Profil | Bis Kontolöschung |
| Profilbild (optional) | Vertrauen | Nach Wahl: erst nach Match (Standard) oder passende Personen am Flughafen | Bis Löschung/Kontolöschung |
| 18+-Bestätigung (ja), Version der Nutzungsbedingungen, Zeitpunkt | Nachweis Zustimmung/Altersgrenze | Betreiber | Bis Kontolöschung |
| Zeitfenster (Flughafen, Beginn, Ende, Kontaktinteressen) | Kernfunktion | Eigene: man selbst. Andere sehen nur gemeinsame Zeit, nicht das ganze Fenster | 90 Tage nach Ende (für Kennzahlen), dann gelöscht |
| Flugnummer (optional) | Komfort, später Flugstatus | Nur man selbst | Mit dem Zeitfenster |
| Standort | Einmalige Prüfung „am Flughafen?“ | **Wird nicht gespeichert**, verlässt das Gerät nicht | – |
| „Interesse“ / „Weiter“ | Matching | Nur man selbst | Bis Kontolöschung [OFFEN: kürzer?] |
| Matches, Nachrichten | Kontakt | Beide Beteiligten | Nachrichten: 30 Tage nach Ende des Matches [OFFEN] |
| Meldungen inkl. Kopie gemeldeter Nachricht | Sicherheit, Beweis | Nur Moderation | [OFFEN] – bei Kontolöschung anonymisiert |
| Push-Token | Benachrichtigungen | Betreiber | Bis Abmeldung/Kontolöschung |
| Nachfrage nach weiteren Flughäfen | Expansion planen | Betreiber (nur Anzahlen auswerten) | Bis Kontolöschung |

**Dienstleister (Auftragsverarbeiter, geplant):** Supabase (Datenbank/Login/Speicher, Region Frankfurt), Expo (Builds, Push-Weiterleitung), Apple/Google (Push-Zustellung, App Stores). Später ggf. Flugdaten-Anbieter (ohne Personendaten), Fehlerüberwachung. Für jeden: Datenverarbeitungsvertrag (DPA) prüfen.

**Grundsätze:** keine Weitergabe/kein Verkauf personenbezogener Daten (ADR-013, vorgeschlagen); keine Werbe-Tracker; Konto in der App löschbar.
