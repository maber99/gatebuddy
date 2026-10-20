# GateBuddy – Mobile App

React Native + Expo (SDK 58) + TypeScript. Bildschirme in `src/app` (Expo Router), Fachlogik in `src/domain`, Serverzugriff in `src/lib`, Texte in `src/i18n` (Deutsch/Englisch).

```bash
cp .env.example .env    # Supabase-URL und öffentlichen Schlüssel eintragen (ohne: Vorschaumodus)
npm start               # Entwicklungsserver
npm run check           # Typen, Lint, Tests
```

Hinweise für Claude Code: siehe `../../CLAUDE.md` und `AGENTS.md` (Expo-spezifische Regeln).
