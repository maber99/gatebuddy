/**
 * Öffentliche Konfiguration. Werte kommen aus `.env` (siehe `.env.example`).
 * Nur öffentliche Schlüssel! Niemals Datenbankpasswort oder Secret Key in die App.
 */
export const SUPABASE_URL = process.env.EXPO_PUBLIC_SUPABASE_URL ?? '';
export const SUPABASE_PUBLISHABLE_KEY = process.env.EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY ?? '';

/** Ohne Serververbindung läuft die App im Vorschaumodus (nur Oberfläche, keine Daten). */
export const isBackendConfigured = SUPABASE_URL.length > 0 && SUPABASE_PUBLISHABLE_KEY.length > 0;
