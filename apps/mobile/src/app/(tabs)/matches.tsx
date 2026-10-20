import { router } from 'expo-router';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';

import { ThemedText } from '@/components/themed-text';
import { Button, Card, Notice, Screen } from '@/components/ui';
import { errorKey } from '@/domain/errors';
import { getMyMatches, type MatchSummary } from '@/lib/api';
import { useSession } from '@/lib/session';

/**
 * Liste der Matches. Der Chat-Bildschirm folgt in Phase 10 (docs/ROADMAP.md).
 * Status: Liste implementiert · gegen echten Server noch nicht getestet · Chat: Geplant.
 */
export default function MatchesScreen() {
  const { t } = useTranslation();
  const { previewMode } = useSession();
  const [matches, setMatches] = useState<MatchSummary[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (previewMode) return;
    getMyMatches().then(setMatches).catch((e) => setError(t(errorKey(e))));
  }, [previewMode, t]);

  return (
    <Screen>
      <ThemedText type="subtitle" accessibilityRole="header">{t('matches.title')}</ThemedText>
      {error ? <Notice tone="warning" text={error} /> : null}
      {matches.length === 0 ? <ThemedText themeColor="textSecondary">{t('matches.empty')}</ThemedText> : null}
      {matches.map((m) => (
        <Card key={m.match_id}>
          <ThemedText type="smallBold">
            {m.partner_name}
            {m.closed_at ? ` · ${t('matches.closed')}` : ''}
          </ThemedText>
          {m.last_message_preview ? <ThemedText type="small" themeColor="textSecondary">{m.last_message_preview}</ThemedText> : null}
        </Card>
      ))}
      <Button label={t('matches.safetyCta')} variant="secondary" onPress={() => router.push('/safety')} />
    </Screen>
  );
}
