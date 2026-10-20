import { LIMITS } from './constants';

export type PresenceWindowError =
  | 'presence_in_past'
  | 'presence_too_far_ahead'
  | 'presence_too_long'
  | 'presence_time_order';

const MINUTE = 60_000;
const DAY = 24 * 60 * MINUTE;

/**
 * Prüft ein Zeitfenster vor dem Absenden mit denselben Regeln wie die Datenbank.
 * Die Datenbank bleibt die verbindliche Prüfung; hier geht es um schnelle Rückmeldung.
 */
export function validatePresenceWindow(start: Date, end: Date, now: Date = new Date()): PresenceWindowError | null {
  if (end.getTime() <= start.getTime()) return 'presence_time_order';
  if (end.getTime() - start.getTime() > LIMITS.presenceMaxMinutes * MINUTE) return 'presence_too_long';
  if (start.getTime() < now.getTime() - 10 * MINUTE || end.getTime() <= now.getTime()) return 'presence_in_past';
  if (start.getTime() > now.getTime() + LIMITS.presenceMaxDaysAhead * DAY) return 'presence_too_far_ahead';
  return null;
}

/** Gemeinsame verbleibende Zeit zweier Zeitfenster in Minuten (0, wenn keine). */
export function overlapMinutes(
  a: { start: Date; end: Date },
  b: { start: Date; end: Date },
  now: Date = new Date(),
): number {
  const start = Math.max(a.start.getTime(), b.start.getTime(), now.getTime());
  const end = Math.min(a.end.getTime(), b.end.getTime());
  return Math.max(0, Math.floor((end - start) / MINUTE));
}

export function isMeaningfulOverlap(minutes: number): boolean {
  return minutes >= LIMITS.minOverlapMinutes;
}

/** Baut ein "Jetzt"-Zeitfenster: ab sofort für die gewählte Dauer. */
export function nowWindow(durationMinutes: number, now: Date = new Date()): { start: Date; end: Date } {
  return { start: new Date(now.getTime()), end: new Date(now.getTime() + durationMinutes * MINUTE) };
}

/** Baut ein geplantes Zeitfenster: Tag (0 = heute) und Uhrzeit in Ortszeit des Geräts. */
export function plannedWindow(
  dayOffset: number,
  hour: number,
  minute: number,
  durationMinutes: number,
  now: Date = new Date(),
): { start: Date; end: Date } {
  const start = new Date(now.getFullYear(), now.getMonth(), now.getDate() + dayOffset, hour, minute, 0, 0);
  return { start, end: new Date(start.getTime() + durationMinutes * MINUTE) };
}
