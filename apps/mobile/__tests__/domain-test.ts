import { INTENTS, INTERESTS, LIMITS } from '@/domain/constants';
import { errorKey, KNOWN_BACKEND_ERRORS } from '@/domain/errors';
import { distanceMeters, isWithinAirport } from '@/domain/geo';
import { isMeaningfulOverlap, nowWindow, overlapMinutes, plannedWindow, validatePresenceWindow } from '@/domain/presence';
import { normalizeFlightNumber, validateBio, validateDisplayName, validateOnboarding } from '@/domain/validation';

const NOW = new Date('2026-10-20T12:00:00Z');
const min = (m: number) => new Date(NOW.getTime() + m * 60_000);

describe('Profilangaben', () => {
  it('verlangt einen Namen und begrenzt die Länge', () => {
    expect(validateDisplayName('   ')).toBe('name_required');
    expect(validateDisplayName('A'.repeat(31))).toBe('name_too_long');
    expect(validateDisplayName('  Marco ')).toBeNull();
  });

  it('erlaubt keine Links in Name und Text (Spam-Schutz, wie in der Datenbank)', () => {
    expect(validateDisplayName('www.spam.ch')).toBe('links_not_allowed');
    expect(validateBio('Mehr auf https://example.com')).toBe('links_not_allowed');
    expect(validateBio('')).toBeNull();
    expect(validateBio('x'.repeat(301))).toBe('bio_too_long');
  });

  it('verlangt 18+ und Zustimmung zu den Bedingungen', () => {
    expect(validateOnboarding({ displayName: 'Lea', bio: '', isAdultConfirmed: false, termsAccepted: false })).toEqual({
      isAdultConfirmed: 'adult_required',
      termsAccepted: 'terms_required',
    });
    expect(validateOnboarding({ displayName: 'Lea', bio: '', isAdultConfirmed: true, termsAccepted: true })).toEqual({});
  });
});

describe('Flugnummer (freiwillig, kein Buchungsnachweis)', () => {
  it.each([
    [' lx 318 ', 'LX318'],
    ['u21234', 'U21234'],
    ['SWR8A', 'SWR8A'],
  ])('vereinheitlicht %p zu %p', (input, expected) => {
    expect(normalizeFlightNumber(input)).toEqual({ ok: true, value: expected });
  });

  it('leere Eingabe bedeutet keine Flugnummer', () => {
    expect(normalizeFlightNumber('   ')).toEqual({ ok: true, value: null });
  });

  it.each(['LX-318!', 'L', '12345678', 'LX12345'])('lehnt %p ab', (input) => {
    expect(normalizeFlightNumber(input)).toEqual({ ok: false, error: 'flight_number_invalid' });
  });
});

describe('Zeitfenster (gleiche Regeln wie die Datenbank)', () => {
  it('akzeptiert ein Jetzt-Fenster von 2 Stunden', () => {
    const w = nowWindow(120, NOW);
    expect(validatePresenceWindow(w.start, w.end, NOW)).toBeNull();
  });

  it('begrenzt auf 6 Stunden', () => {
    expect(validatePresenceWindow(min(0), min(361), NOW)).toBe('presence_too_long');
    expect(validatePresenceWindow(min(0), min(360), NOW)).toBeNull();
  });

  it('begrenzt die Planung auf 14 Tage', () => {
    expect(validatePresenceWindow(min(15 * 24 * 60), min(15 * 24 * 60 + 60), NOW)).toBe('presence_too_far_ahead');
    expect(validatePresenceWindow(min(13 * 24 * 60), min(13 * 24 * 60 + 60), NOW)).toBeNull();
  });

  it('lehnt Vergangenheit und vertauschte Zeiten ab', () => {
    expect(validatePresenceWindow(min(-180), min(-60), NOW)).toBe('presence_in_past');
    expect(validatePresenceWindow(min(60), min(30), NOW)).toBe('presence_time_order');
  });

  it('berechnet gemeinsame Restzeit und Mindestüberschneidung von 15 Minuten', () => {
    const a = { start: min(0), end: min(120) };
    const b = { start: min(110), end: min(170) };
    expect(overlapMinutes(a, b, NOW)).toBe(10);
    expect(isMeaningfulOverlap(10)).toBe(false);
    expect(isMeaningfulOverlap(LIMITS.minOverlapMinutes)).toBe(true);
    expect(overlapMinutes(a, { start: min(200), end: min(300) }, NOW)).toBe(0);
  });

  it('baut geplante Fenster in Ortszeit des Geräts', () => {
    const w = plannedWindow(1, 14, 0, 90, NOW);
    expect(w.end.getTime() - w.start.getTime()).toBe(90 * 60_000);
    expect(w.start.getHours()).toBe(14);
  });
});

describe('Standortprüfung ZRH (nur auf dem Gerät)', () => {
  const ZRH = { center_lat: 47.4647, center_lon: 8.5492, radius_m: 3000 };

  it('berechnet Entfernungen plausibel (Zürich HB – Flughafen ca. 9–10 km)', () => {
    const d = distanceMeters({ latitude: 47.3779, longitude: 8.5403 }, { latitude: 47.4647, longitude: 8.5492 });
    expect(d).toBeGreaterThan(9000);
    expect(d).toBeLessThan(10500);
  });

  it('erkennt Terminalbereich, nicht aber die Innenstadt', () => {
    expect(isWithinAirport({ latitude: 47.4505, longitude: 8.562 }, ZRH)).toBe(true);
    expect(isWithinAirport({ latitude: 47.3779, longitude: 8.5403 }, ZRH)).toBe(false);
  });

  it('sehr ungenaue Messungen führen nicht automatisch zur Bestätigung', () => {
    expect(isWithinAirport({ latitude: 47.3779, longitude: 8.5403 }, ZRH, 20_000)).toBe(false);
  });
});

describe('Fehlermeldungen', () => {
  it('übersetzt bekannte Datenbank-Codes', () => {
    expect(errorKey({ message: 'not_available', code: 'P0001' })).toBe('errors.not_available');
    expect(errorKey({ message: 'conflicting key', code: '23P01' })).toBe('errors.overlap');
    expect(errorKey({ message: 'new row violates row-level security policy', code: '42501' })).toBe('errors.permission');
    expect(errorKey(new Error('irgendwas'))).toBe('errors.unknown');
    expect(errorKey(undefined)).toBe('errors.unknown');
  });

  it('kennt genau die Codes, die die App übersetzt', () => {
    expect(new Set(KNOWN_BACKEND_ERRORS).size).toBe(KNOWN_BACKEND_ERRORS.length);
  });
});

describe('Kataloge', () => {
  it('sechs Kontaktinteressen und 24 Interessen ohne Duplikate', () => {
    expect(INTENTS).toHaveLength(6);
    expect(new Set(INTERESTS).size).toBe(24);
  });
});
