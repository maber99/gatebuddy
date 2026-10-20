import { router } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';

import { ThemedText } from '@/components/themed-text';
import { Button, Notice, Screen, SectionTitle } from '@/components/ui';
import { errorKey } from '@/domain/errors';
import { deleteMyAccount } from '@/lib/api';
import { useSession } from '@/lib/session';
import { supabase } from '@/lib/supabase';

/**
 * Einstellungen: Sicherheit, Kontakt, Abmelden, Konto löschen (App-Store-Pflicht).
 * Status: Implementiert · gegen echten Server noch nicht getestet.
 */
export default function ProfileScreen() {
  const { t } = useTranslation();
  const { previewMode } = useSession();

  function confirmDelete() {
    Alert.alert(t('profile.deleteConfirmTitle'), t('profile.deleteConfirmText'), [
      { text: t('common.cancel'), style: 'cancel' },
      {
        text: t('profile.deleteConfirm'),
        style: 'destructive',
        onPress: async () => {
          try {
            await deleteMyAccount();
            router.replace('/');
          } catch (e) {
            Alert.alert(t(errorKey(e)));
          }
        },
      },
    ]);
  }

  return (
    <Screen>
      <ThemedText type="subtitle" accessibilityRole="header">{t('profile.title')}</ThemedText>
      {previewMode ? <Notice tone="warning" text={t('dev.backendMissing')} /> : null}

      <Button label={t('profile.safety')} variant="secondary" onPress={() => router.push('/safety')} />

      <SectionTitle>{t('profile.contact')}</SectionTitle>
      <ThemedText selectable>{t('profile.contactEmail')}</ThemedText>

      <SectionTitle>{t('profile.terms')}</SectionTitle>
      <Notice text={t('onboarding.termsDraftNote')} />

      <Button label={t('profile.signOut')} variant="secondary" disabled={previewMode}
        onPress={async () => { await supabase?.auth.signOut(); router.replace('/'); }} />
      <Button label={t('profile.deleteAccount')} variant="danger" disabled={previewMode} onPress={confirmDelete} />
    </Screen>
  );
}
