/**
 * Übersetzt Fehler der Datenbank (stabile Codes aus den Migrationen) in Übersetzungsschlüssel.
 * Unbekannte Fehler werden nie roh angezeigt.
 */
export const KNOWN_BACKEND_ERRORS = [
  'not_authenticated',
  'account_inactive',
  'airport_inactive',
  'invalid_intent',
  'presence_in_past',
  'presence_too_far_ahead',
  'presence_not_found',
  'presence_immutable_fields',
  'too_many_presences',
  'too_many_languages',
  'too_many_interests',
  'content_blocked',
  'links_not_allowed',
  'rate_limited',
  'not_available',
  'already_reacted',
  'message_not_found',
  'forbidden',
  'report_not_found',
  'no_message_in_report',
] as const;
export type BackendErrorCode = (typeof KNOWN_BACKEND_ERRORS)[number];

type ErrorLike = { message?: unknown; code?: unknown } | null | undefined;

export function errorKey(error: unknown): `errors.${BackendErrorCode | 'overlap' | 'permission' | 'unknown'}` {
  const e = error as ErrorLike;
  const message = typeof e?.message === 'string' ? e.message : '';
  const code = typeof e?.code === 'string' ? e.code : '';
  const known = KNOWN_BACKEND_ERRORS.find((k) => message === k);
  if (known) return `errors.${known}`;
  if (code === '23P01') return 'errors.overlap';
  if (code === '42501') return 'errors.permission';
  return 'errors.unknown';
}
