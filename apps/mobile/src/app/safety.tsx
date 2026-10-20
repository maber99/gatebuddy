import { useTranslation } from 'react-i18next';

import { ThemedText } from '@/components/themed-text';
import { Card, Screen } from '@/components/ui';

/** Sicherheitshinweise vor dem ersten Treffen (MVP-Pflichtfunktion). */
export default function SafetyScreen() {
  const { t } = useTranslation();
  const tips = t('safety.tips', { returnObjects: true }) as string[];
  return (
    <Screen>
      {tips.map((tip, index) => (
        <Card key={index}>
          <ThemedText>{tip}</ThemedText>
        </Card>
      ))}
    </Screen>
  );
}
