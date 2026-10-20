import { router } from 'expo-router';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';

import { ThemedText } from '@/components/themed-text';
import { Button, Field, Screen } from '@/components/ui';
import { requireSupabase } from '@/lib/supabase';

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

/**
 * Anmeldung per E-Mail-Einmalcode (kein Passwort, ADR-008 vorgeschlagen).
 * Status: Implementiert · gegen echten Server noch nicht getestet.
 */
export default function SignInScreen() {
  const { t } = useTranslation();
  const [email, setEmail] = useState('');
  const [code, setCode] = useState('');
  const [step, setStep] = useState<'email' | 'code'>('email');
  const [error, setError] = useState<string | undefined>();
  const [busy, setBusy] = useState(false);

  async function sendCode() {
    const value = email.trim().toLowerCase();
    if (!EMAIL_PATTERN.test(value)) return setError(t('auth.emailInvalid'));
    setBusy(true);
    setError(undefined);
    const { error: e } = await requireSupabase().auth.signInWithOtp({ email: value, options: { shouldCreateUser: true } });
    setBusy(false);
    if (e) return setError(t('errors.unknown'));
    setStep('code');
  }

  async function verify() {
    setBusy(true);
    setError(undefined);
    const { error: e } = await requireSupabase().auth.verifyOtp({ email: email.trim().toLowerCase(), token: code.trim(), type: 'email' });
    setBusy(false);
    if (e) return setError(t('auth.codeInvalid'));
    router.replace('/');
  }

  return (
    <Screen>
      {step === 'email' ? (
        <>
          <Field
            label={t('auth.emailLabel')}
            value={email}
            onChangeText={setEmail}
            autoCapitalize="none"
            autoComplete="email"
            keyboardType="email-address"
            error={error}
          />
          <Button label={t('auth.sendCode')} onPress={sendCode} disabled={busy} />
        </>
      ) : (
        <>
          <ThemedText>{t('auth.codeSent')}</ThemedText>
          <Field
            label={t('auth.codeLabel')}
            value={code}
            onChangeText={setCode}
            keyboardType="number-pad"
            autoComplete="one-time-code"
            maxLength={6}
            error={error}
          />
          <Button label={t('auth.verify')} onPress={verify} disabled={busy || code.trim().length !== 6} />
        </>
      )}
      <ThemedText type="small" themeColor="textSecondary">
        {t('auth.legalHint')}
      </ThemedText>
    </Screen>
  );
}
