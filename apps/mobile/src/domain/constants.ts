/**
 * Fachliche Konstanten. Müssen mit der Datenbank übereinstimmen
 * (supabase/migrations/*). Tests prüfen die Übereinstimmung, wo möglich.
 */

export const START_AIRPORT = 'ZRH' as const; // ADR-005

export const INTENTS = [
  'coffee',
  'casual_chat',
  'business_networking',
  'language_practice',
  'meet_people',
  'travel_stories',
] as const;
export type Intent = (typeof INTENTS)[number];

export const INTEREST_CATEGORIES = {
  travel: ['aviation', 'backpacking', 'city_trips', 'nature_travel'],
  work: ['technology', 'startups', 'business', 'design', 'science', 'education', 'healthcare', 'sustainability'],
  culture: ['books', 'film', 'music', 'art', 'history', 'photography'],
  lifestyle: ['food', 'sports', 'running', 'hiking', 'gaming', 'languages'],
} as const;
export type InterestCategory = keyof typeof INTEREST_CATEGORIES;
export type Interest = (typeof INTEREST_CATEGORIES)[InterestCategory][number];
export const INTERESTS: readonly Interest[] = Object.values(INTEREST_CATEGORIES).flat();

/** ISO-639-1-Codes, die in der App zur Auswahl stehen (Datenbank akzeptiert jeden gültigen Code). */
export const LANGUAGES = [
  'de', 'en', 'fr', 'it', 'es', 'pt', 'nl', 'pl', 'tr', 'ar', 'ru', 'uk', 'zh', 'ja', 'ko', 'hi',
] as const;
export type LanguageCode = (typeof LANGUAGES)[number];

export const LIMITS = {
  displayNameMax: 30,
  bioMax: 300,
  maxLanguagesPerMode: 8,
  maxInterests: 10,
  presenceMaxMinutes: 6 * 60,
  presenceMaxDaysAhead: 14,
  minOverlapMinutes: 15,
  messageMax: 2000,
} as const;

export const PHOTO_VISIBILITY = ['matches', 'airport'] as const; // ADR-007, Standard: 'matches'
export type PhotoVisibility = (typeof PHOTO_VISIBILITY)[number];

/** Version der Nutzungsbedingungen. Erhöhen, wenn sich die Texte ändern. */
export const TERMS_VERSION = '2026-10-draft';
