import 'expo-sqlite/localStorage/install';

import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import { AppState } from 'react-native';

import { isBackendConfigured, SUPABASE_PUBLISHABLE_KEY, SUPABASE_URL } from './config';

/**
 * Supabase-Client nach offizieller Expo-Anleitung (docs.expo.dev/guides/using-supabase).
 * Ist kein Server konfiguriert, ist der Client `null` und die App zeigt eine Vorschau.
 */
export const supabase: SupabaseClient | null = isBackendConfigured
  ? createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
      auth: {
        storage: localStorage,
        autoRefreshToken: true,
        persistSession: true,
        detectSessionInUrl: false,
      },
    })
  : null;

if (supabase) {
  // Token nur im Vordergrund erneuern
  AppState.addEventListener('change', (state) => {
    if (state === 'active') supabase.auth.startAutoRefresh();
    else supabase.auth.stopAutoRefresh();
  });
}

export function requireSupabase(): SupabaseClient {
  if (!supabase) throw new Error('backend_not_configured');
  return supabase;
}
