import { router } from 'expo-router';
import { useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { StyleSheet, View } from 'react-native';

import { ThemedText } from '@/components/themed-text';
import { Button, Card, Chip, ChipGroup, Field, Notice, Screen, SectionTitle } from '@/components/ui';
import { Spacing } from '@/constants/theme';
import { INTENTS, LIMITS, START_AIRPORT, type Intent } from '@/domain/constants';
import { errorKey } from '@/domain/errors';
import { nowWindow, plannedWindow, validatePresenceWindow } from '@/domain/presence';
import { normalizeFlightNumber } from '@/domain/validation';
import { cancelPresence, createPresence, getAirportActivity, getMyUpcomingPresences, type Presence } from '@/lib/api';
import { useSession } from '@/lib/session';

const DURATIONS = [60, 120, 180, 240, 360];
const HOURS = Array.from({ length: 18 }, (_, i) => i + 5); // 05–22 Uhr
const DAYS = Array.from({ length: LIMITS.presenceMaxDaysAhead }, (_, i) => i);

function formatTime(iso: string, locale: string) {
  return new Date(iso).toLocaleTimeString(locale, { hour: '2-digit', minute: '2-digit', timeZone: 'Europe/Zurich' });
}

/**
 * Flughafen ZRH: echte Aktivitätszahlen, eigenes Zeitfenster anlegen ("jetzt" oder "vorab").
 * Status: Implementiert · Logik getestet (Unit-Tests) · gegen echten Server noch nicht getestet.
 */
export default function AirportScreen() {
  const { t, i18n } = useTranslation();
  const { previewMode } = useSession();
  const [activity, setActivity] = useState<{ active_now: number; planned_next_7_days: number } | null>(null);
  const [mine, setMine] = useState<Presence[]>([]);
  const [mode, setMode] = useState<'now' | 'plan'>('now');
  const [duration, setDuration] = useState(120);
  const [dayOffset, setDayOffset] = useState(1);
  const [hour, setHour] = useState(14);
  const [intents, setIntents] = useState<Intent[]>(['coffee']);
  const [flightNumber, setFlightNumber] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const [reloadKey, setReloadKey] = useState(0);
  const reload = () => setReloadKey((k) => k + 1);

  useEffect(() => {
    if (previewMode) return;
    let active = true;
    Promise.all([getAirportActivity(START_AIRPORT), getMyUpcomingPresences()])
      .then(([a, p]) => {
        if (!active) return;
        setActivity(a);
        setMine(p);
      })
      .catch((e) => active && setError(t(errorKey(e))));
    return () => {
      active = false;
    };
  }, [previewMode, reloadKey, t]);

  const dayLabel = useMemo(
    () => (offset: number) => {
      if (offset === 0) return t('airport.today');
      if (offset === 1) return t('airport.tomorrow');
      const d = new Date();
      d.setDate(d.getDate() + offset);
      return d.toLocaleDateString(i18n.language, { weekday: 'short', day: 'numeric', month: 'numeric' });
    },
    [t, i18n.language],
  );

  async function submit() {
    setError(null);
    const window = mode === 'now' ? nowWindow(duration) : plannedWindow(dayOffset, hour, 0, duration);
    const windowError = validatePresenceWindow(window.start, window.end);
    if (windowError) return setError(t(`errors.${windowError}`));
    const flight = normalizeFlightNumber(flightNumber);
    if (!flight.ok) return setError(t(`errors.${flight.error}`));
    if (intents.length === 0) return setError(t('errors.invalid_intent'));
    if (previewMode) return router.push({ pathname: '/candidates', params: { presenceId: 'preview' } });

    setBusy(true);
    try {
      const created = await createPresence({
        airport: START_AIRPORT,
        start: window.start,
        end: window.end,
        intents,
        flightNumber: flight.value,
        locationVerified: false,
      });
      setFlightNumber('');
      reload();
      router.push({ pathname: '/candidates', params: { presenceId: created.id } });
    } catch (e) {
      setError(t(errorKey(e)));
    } finally {
      setBusy(false);
    }
  }

  return (
    <Screen>
      <ThemedText type="subtitle" accessibilityRole="header">{t('airport.title')}</ThemedText>
      {previewMode ? <Notice tone="warning" text={t('dev.backendMissing')} /> : null}

      <Card>
        <View style={styles.stats}>
          <View style={styles.stat}>
            <ThemedText type="subtitle">{activity ? activity.active_now : '–'}</ThemedText>
            <ThemedText type="small" themeColor="textSecondary">{t('airport.activityNow')}</ThemedText>
          </View>
          <View style={styles.stat}>
            <ThemedText type="subtitle">{activity ? activity.planned_next_7_days : '–'}</ThemedText>
            <ThemedText type="small" themeColor="textSecondary">{t('airport.activityPlanned')}</ThemedText>
          </View>
        </View>
        <ThemedText type="small" themeColor="textSecondary">{t('airport.activityHonest')}</ThemedText>
      </Card>

      {mine.map((p) => (
        <Card key={p.id}>
          <ThemedText>{t('airport.visibleUntil', { time: formatTime(p.ends_at, i18n.language) })}</ThemedText>
          <Button label={t('airport.seeCandidates')}
            onPress={() => router.push({ pathname: '/candidates', params: { presenceId: p.id } })} />
          <Button label={t('airport.endVisibility')} variant="secondary"
            onPress={async () => { await cancelPresence(p.id); reload(); }} />
        </Card>
      ))}

      <SectionTitle>{t('airport.checkInTitle')}</SectionTitle>
      <ChipGroup>
        <Chip label={t('airport.modeNow')} selected={mode === 'now'} onPress={() => setMode('now')} />
        <Chip label={t('airport.modePlan')} selected={mode === 'plan'} onPress={() => setMode('plan')} />
      </ChipGroup>

      {mode === 'plan' ? (
        <>
          <SectionTitle>{t('airport.day')}</SectionTitle>
          <ChipGroup>
            {DAYS.map((d) => <Chip key={d} label={dayLabel(d)} selected={dayOffset === d} onPress={() => setDayOffset(d)} />)}
          </ChipGroup>
          <SectionTitle>{t('airport.time')}</SectionTitle>
          <ChipGroup>
            {HOURS.map((h) => <Chip key={h} label={`${String(h).padStart(2, '0')}:00`} selected={hour === h} onPress={() => setHour(h)} />)}
          </ChipGroup>
        </>
      ) : null}

      <SectionTitle>{t('airport.duration')}</SectionTitle>
      <ChipGroup>
        {DURATIONS.map((m) => <Chip key={m} label={`${m / 60} h`} selected={duration === m} onPress={() => setDuration(m)} />)}
      </ChipGroup>

      <SectionTitle>{t('airport.intentsTitle')}</SectionTitle>
      <ChipGroup>
        {INTENTS.map((code) => (
          <Chip key={code} label={t(`intents.${code}`)} selected={intents.includes(code)}
            onPress={() => setIntents((l) => (l.includes(code) ? l.filter((i) => i !== code) : [...l, code]))} />
        ))}
      </ChipGroup>

      <Field label={`${t('airport.flightNumber')} (${t('common.optional')})`} value={flightNumber}
        onChangeText={setFlightNumber} autoCapitalize="characters" placeholder="LX318" hint={t('airport.flightNumberHint')} />

      <Button label={`${t('airport.verifyLocation')} – ${t('common.planned')}`} variant="secondary" disabled
        hint={t('airport.verifyLocationHint')} />

      {error ? <Notice tone="warning" text={error} /> : null}
      <Button testID="submit-presence" label={t('airport.submit')} onPress={submit} disabled={busy} />
      <ThemedText type="small" themeColor="textSecondary">{t('airport.otherAirports')}</ThemedText>
    </Screen>
  );
}

const styles = StyleSheet.create({
  stats: { flexDirection: 'row', gap: Spacing.four },
  stat: { flex: 1 },
});
