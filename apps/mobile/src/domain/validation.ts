import { LIMITS } from './constants';

/** Fehlercodes entsprechen den Übersetzungsschlüsseln unter `errors.*`. */
export type ValidationError =
  | 'name_required'
  | 'name_too_long'
  | 'bio_too_long'
  | 'links_not_allowed'
  | 'flight_number_invalid'
  | 'adult_required'
  | 'terms_required';

const LINK_PATTERN = /(https?:\/\/|www\.)/i;

/** Gleiche Regel wie in der Datenbank (presences.flight_number). */
export const FLIGHT_NUMBER_PATTERN = /^([A-Z0-9]{2}|[A-Z]{3})[0-9]{1,4}[A-Z]?$/;

export function validateDisplayName(raw: string): ValidationError | null {
  const name = raw.trim();
  if (name.length === 0) return 'name_required';
  if (name.length > LIMITS.displayNameMax) return 'name_too_long';
  if (LINK_PATTERN.test(name)) return 'links_not_allowed';
  return null;
}

export function validateBio(raw: string): ValidationError | null {
  const bio = raw.trim();
  if (bio.length > LIMITS.bioMax) return 'bio_too_long';
  if (LINK_PATTERN.test(bio)) return 'links_not_allowed';
  return null;
}

/**
 * Vereinheitlicht eine Flugnummer (" lx 318 " -> "LX318").
 * Leere Eingabe = keine Flugnummer (freiwillig). Ungültige Eingabe = Fehler.
 * Eine Flugnummer ist KEIN Buchungsnachweis.
 */
export function normalizeFlightNumber(
  raw: string,
): { ok: true; value: string | null } | { ok: false; error: ValidationError } {
  const value = raw.replace(/\s/g, '').toUpperCase();
  if (value.length === 0) return { ok: true, value: null };
  if (!FLIGHT_NUMBER_PATTERN.test(value)) return { ok: false, error: 'flight_number_invalid' };
  return { ok: true, value };
}

export function validateOnboarding(input: {
  displayName: string;
  bio: string;
  isAdultConfirmed: boolean;
  termsAccepted: boolean;
}): Partial<Record<'displayName' | 'bio' | 'isAdultConfirmed' | 'termsAccepted', ValidationError>> {
  const errors: Partial<Record<'displayName' | 'bio' | 'isAdultConfirmed' | 'termsAccepted', ValidationError>> = {};
  const nameError = validateDisplayName(input.displayName);
  if (nameError) errors.displayName = nameError;
  const bioError = validateBio(input.bio);
  if (bioError) errors.bio = bioError;
  if (!input.isAdultConfirmed) errors.isAdultConfirmed = 'adult_required';
  if (!input.termsAccepted) errors.termsAccepted = 'terms_required';
  return errors;
}
