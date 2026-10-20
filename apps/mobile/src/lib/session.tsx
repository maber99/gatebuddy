import type { Session } from '@supabase/supabase-js';
import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';

import { supabase } from './supabase';

type SessionState = {
  session: Session | null;
  /** true, solange die gespeicherte Anmeldung geladen wird */
  loading: boolean;
  /** Ohne Server: Oberfläche ansehen ohne Daten */
  previewMode: boolean;
};

const SessionContext = createContext<SessionState>({ session: null, loading: false, previewMode: true });

export function SessionProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<SessionState>({ session: null, loading: !!supabase, previewMode: !supabase });

  useEffect(() => {
    if (!supabase) return;
    supabase.auth.getSession().then(({ data }) => {
      setState({ session: data.session, loading: false, previewMode: false });
    });
    const { data } = supabase.auth.onAuthStateChange((_event, session) => {
      setState({ session, loading: false, previewMode: false });
    });
    return () => data.subscription.unsubscribe();
  }, []);

  return <SessionContext.Provider value={state}>{children}</SessionContext.Provider>;
}

export function useSession() {
  return useContext(SessionContext);
}
