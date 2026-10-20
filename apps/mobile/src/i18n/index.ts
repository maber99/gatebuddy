import { getLocales } from 'expo-localization';
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

import de from './de';
import en from './en';

export const SUPPORTED_LANGUAGES = ['de', 'en'] as const;
export type AppLanguage = (typeof SUPPORTED_LANGUAGES)[number];

/** Wählt Deutsch oder Englisch anhand der Gerätesprache; sonst Englisch (internationales Publikum). */
export function pickLanguage(deviceLanguages: readonly (string | null | undefined)[]): AppLanguage {
  for (const lang of deviceLanguages) {
    const code = lang?.toLowerCase().slice(0, 2);
    if (code && (SUPPORTED_LANGUAGES as readonly string[]).includes(code)) return code as AppLanguage;
  }
  return 'en';
}

if (!i18n.isInitialized) {
  // eslint-disable-next-line import/no-named-as-default-member -- offizielle i18next-Schreibweise
  void i18n.use(initReactI18next).init({
    resources: { de: { translation: de }, en: { translation: en } },
    lng: pickLanguage(getLocales().map((l) => l.languageCode)),
    fallbackLng: 'en',
    interpolation: { escapeValue: false },
  });
}

export default i18n;
