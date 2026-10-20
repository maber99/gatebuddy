import { useLocalSearchParams } from 'expo-router';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { StyleSheet, View } from 'react-native';

import { ThemedText } from '@/components/themed-text';
import { Button, Card, Notice, Screen } from '@/components/ui';
import { Spacing } from '@/constants/theme';
import { errorKey } from '@/domain/errors';
import { discoverCandidates, react, type Candidate } from '@/lib/api';
import { useSession } from '@/lib/session';

function time(iso: string, locale: string) {
  return new Date(iso).toLocaleTimeString(locale, { hour: '2-digit', minute: '2-digit', timeZone: 'Europe/Zurich' });
}

/**
 * Passende Personen für das eigene Zeitfenster. "Weiter" bleibt für die andere Person unsichtbar.
 * Status: Implementiert · gegen echten Server noch nicht getestet.
 */
export default function CandidatesScreen() {
  const { t, i18n } = useTranslation();
  const { presenceId } = useLocalSearchParams<{ presenceId: string }>();
  const { previewMode } = useSession();
  const [items, setItems] = useState<Candidate[] | null>(previewMode ? [] : null);
  const [message, setMessage] = useState<string | null>(null);

  useEffect(() => {
    if (previewMode || !presenceId) return;
    let active = true;
    discoverCandidates(presenceId)
      .then((list) => active && setItems(list))
      .catch((e) => {
        if (!active) return;
        setMessage(t(errorKey(e)));
        setItems([]);
      });
    return () => {
      active = false;
    };
  }, [presenceId, previewMode, t]);

  async function respond(id: string, kind: 'interested' | 'pass') {
    try {
      const result = await react(id, kind);
      setItems((list) => (list ?? []).filter((c) => c.profile_id !== id));
      if (result?.is_match) setMessage(t('candidates.matched'));
    } catch (e) {
      setMessage(t(errorKey(e)));
    }
  }

  return (
    <Screen>
      {previewMode ? <Notice tone="warning" text={t('dev.backendMissing')} /> : null}
      {message ? <Notice text={message} /> : null}
      <ThemedText type="small" themeColor="textSecondary">{t('candidates.privacyNote')}</ThemedText>
      {items === null ? <ThemedText>{t('common.loading')}</ThemedText> : null}
      {items?.length === 0 ? <ThemedText>{t('candidates.empty')}</ThemedText> : null}
      {items?.map((c) => (
        <Card key={c.profile_id}>
          <ThemedText type="smallBold">{c.display_name}</ThemedText>
          {c.bio ? <ThemedText>{c.bio}</ThemedText> : null}
          <ThemedText type="small" themeColor="textSecondary">
            {c.shared_intents.map((i) => t(`intents.${i}`)).join(' · ')}
          </ThemedText>
          <ThemedText type="small" themeColor="textSecondary">
            {c.speaks.map((l) => t(`languages.${l}`, { defaultValue: l })).join(', ')}
          </ThemedText>
          <ThemedText type="small">
            {t('candidates.together', { from: time(c.overlap_starts_at, i18n.language), to: time(c.overlap_ends_at, i18n.language) })}
            {c.location_verified ? ` · ${t('candidates.verified')}` : ''}
          </ThemedText>
          <View style={styles.row}>
            <View style={styles.flex}><Button label={t('candidates.pass')} variant="secondary" onPress={() => respond(c.profile_id, 'pass')} /></View>
            <View style={styles.flex}><Button label={t('candidates.interested')} onPress={() => respond(c.profile_id, 'interested')} /></View>
          </View>
        </Card>
      ))}
    </Screen>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', gap: Spacing.two },
  flex: { flex: 1 },
});
