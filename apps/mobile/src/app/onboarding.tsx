import { router } from 'expo-router';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';

import { ThemedText } from '@/components/themed-text';
import { Button, Checkbox, Chip, ChipGroup, Field, Notice, Screen, SectionTitle } from '@/components/ui';
import {
  INTEREST_CATEGORIES,
  LANGUAGES,
  LIMITS,
  TERMS_VERSION,
  type InterestCategory,
  type LanguageCode,
  type PhotoVisibility,
} from '@/domain/constants';
import { errorKey } from '@/domain/errors';
import { validateOnboarding } from '@/domain/validation';
import { createProfile } from '@/lib/api';
import { useSession } from '@/lib/session';

function toggle<T>(list: T[], value: T, max: number): T[] {
  if (list.includes(value)) return list.filter((v) => v !== value);
  return list.length >= max ? list : [...list, value];
}

/** Profil anlegen: Name, Sprachen, Interessen, Bild-Sichtbarkeit, 18+ und Nutzungsbedingungen. */
export default function OnboardingScreen() {
  const { t } = useTranslation();
  const { previewMode } = useSession();
  const [displayName, setDisplayName] = useState('');
  const [bio, setBio] = useState('');
  const [speaks, setSpeaks] = useState<LanguageCode[]>([]);
  const [learns, setLearns] = useState<LanguageCode[]>([]);
  const [interests, setInterests] = useState<string[]>([]);
  const [photoVisibility, setPhotoVisibility] = useState<PhotoVisibility>('matches');
  const [isAdult, setIsAdult] = useState(false);
  const [terms, setTerms] = useState(false);
  const [errors, setErrors] = useState<ReturnType<typeof validateOnboarding>>({});
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function submit() {
    const found = validateOnboarding({ displayName, bio, isAdultConfirmed: isAdult, termsAccepted: terms });
    setErrors(found);
    if (Object.keys(found).length > 0) return;
    if (previewMode) return router.replace('/airport');
    setBusy(true);
    setSubmitError(null);
    try {
      await createProfile({
        displayName,
        bio: bio.trim() || null,
        photoVisibility,
        termsVersion: TERMS_VERSION,
        speaks,
        learns,
        interests,
      });
      router.replace('/airport');
    } catch (e) {
      setSubmitError(t(errorKey(e)));
    } finally {
      setBusy(false);
    }
  }

  return (
    <Screen>
      <ThemedText themeColor="textSecondary">{t('onboarding.intro')}</ThemedText>

      <Field
        testID="display-name"
        label={t('onboarding.displayName')}
        value={displayName}
        onChangeText={setDisplayName}
        maxLength={LIMITS.displayNameMax}
        autoComplete="given-name"
        error={errors.displayName ? t(`errors.${errors.displayName}`) : undefined}
      />
      <Field
        label={`${t('onboarding.bio')} (${t('common.optional')})`}
        value={bio}
        onChangeText={setBio}
        placeholder={t('onboarding.bioPlaceholder')}
        multiline
        maxLength={LIMITS.bioMax}
        error={errors.bio ? t(`errors.${errors.bio}`) : undefined}
      />

      <SectionTitle>{t('onboarding.speaks')}</SectionTitle>
      <ChipGroup>
        {LANGUAGES.map((code) => (
          <Chip key={code} label={t(`languages.${code}`)} selected={speaks.includes(code)}
            onPress={() => setSpeaks((l) => toggle(l, code, LIMITS.maxLanguagesPerMode))} />
        ))}
      </ChipGroup>

      <SectionTitle>{t('onboarding.learns')}</SectionTitle>
      <ChipGroup>
        {LANGUAGES.map((code) => (
          <Chip key={code} label={t(`languages.${code}`)} selected={learns.includes(code)}
            onPress={() => setLearns((l) => toggle(l, code, LIMITS.maxLanguagesPerMode))} />
        ))}
      </ChipGroup>

      <SectionTitle>{t('onboarding.interests')}</SectionTitle>
      {(Object.keys(INTEREST_CATEGORIES) as InterestCategory[]).map((category) => (
        <ChipGroup key={category}>
          {INTEREST_CATEGORIES[category].map((code) => (
            <Chip key={code} label={t(`interests.${code}`)} selected={interests.includes(code)}
              onPress={() => setInterests((l) => toggle(l, code, LIMITS.maxInterests))} />
          ))}
        </ChipGroup>
      ))}

      <SectionTitle>{t('onboarding.photoTitle')}</SectionTitle>
      <ChipGroup>
        <Chip label={t('onboarding.photoMatches')} selected={photoVisibility === 'matches'} onPress={() => setPhotoVisibility('matches')} />
        <Chip label={t('onboarding.photoAirport')} selected={photoVisibility === 'airport'} onPress={() => setPhotoVisibility('airport')} />
      </ChipGroup>
      <ThemedText type="small" themeColor="textSecondary">{t('onboarding.photoHint')}</ThemedText>

      <Checkbox label={t('onboarding.adult')} checked={isAdult} onChange={setIsAdult}
        error={errors.isAdultConfirmed ? t(`errors.${errors.isAdultConfirmed}`) : undefined} />
      <Checkbox label={t('onboarding.terms')} checked={terms} onChange={setTerms}
        error={errors.termsAccepted ? t(`errors.${errors.termsAccepted}`) : undefined} />
      <Notice text={t('onboarding.termsDraftNote')} />

      {submitError ? <Notice tone="warning" text={submitError} /> : null}
      <Button testID="finish-onboarding" label={t('onboarding.finish')} onPress={submit} disabled={busy} />
    </Screen>
  );
}
