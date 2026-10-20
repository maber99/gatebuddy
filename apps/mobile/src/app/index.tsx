import { Redirect, router } from 'expo-router';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { ActivityIndicator, StyleSheet, View } from 'react-native';

import { ThemedText } from '@/components/themed-text';
import { Button, Notice, Screen } from '@/components/ui';
import { Spacing } from '@/constants/theme';
import { getMyProfile } from '@/lib/api';
import { useSession } from '@/lib/session';

/** Startbildschirm: Begrüssung und Anmeldung, oder Weiterleitung für angemeldete Personen. */
export default function WelcomeScreen() {
  const { t } = useTranslation();
  const { session, loading, previewMode } = useSession();
  const [target, setTarget] = useState<'/airport' | '/onboarding' | null>(null);

  useEffect(() => {
    if (!session) return;
    getMyProfile()
      .then((profile) => setTarget(profile ? '/airport' : '/onboarding'))
      .catch(() => setTarget('/onboarding'));
  }, [session]);

  if (target) return <Redirect href={target} />;
  if (loading || session) {
    return (
      <Screen scroll={false}>
        <View style={styles.center}>
          <ActivityIndicator accessibilityLabel={t('common.loading')} />
        </View>
      </Screen>
    );
  }

  return (
    <Screen>
      <View style={styles.hero}>
        <ThemedText type="title" accessibilityRole="header">
          {t('app.name')}
        </ThemedText>
        <ThemedText type="subtitle">{t('app.tagline')}</ThemedText>
        <ThemedText themeColor="textSecondary">{t('app.subtitle')}</ThemedText>
      </View>

      {previewMode ? <Notice tone="warning" text={t('dev.backendMissing')} /> : null}

      <View style={styles.actions}>
        <Button label={t('auth.continueApple')} disabled hint={t('auth.notYetAvailable')} />
        <Button label={t('auth.continueGoogle')} variant="secondary" disabled hint={t('auth.notYetAvailable')} />
        <ThemedText type="small" themeColor="textSecondary">
          {t('auth.notYetAvailable')}
        </ThemedText>
        <Button
          testID="email-sign-in"
          label={t('auth.continueEmail')}
          variant="secondary"
          disabled={previewMode}
          onPress={() => router.push('/sign-in')}
        />
        {previewMode ? (
          <Button testID="preview" label={t('dev.previewApp')} variant="secondary" onPress={() => router.push('/onboarding')} />
        ) : null}
        <ThemedText type="small" themeColor="textSecondary">
          {t('auth.legalHint')}
        </ThemedText>
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  hero: { gap: Spacing.three, marginTop: Spacing.five },
  actions: { gap: Spacing.two, marginTop: Spacing.four },
});
