/**
 * Stellt sicher, dass App und Datenbank dieselben Kataloge und Fehlercodes verwenden,
 * und dass jede Übersetzung in Deutsch UND Englisch vorhanden ist.
 */
import { readdirSync, readFileSync } from 'fs';
import { join } from 'path';

import { INTENTS, INTERESTS } from '@/domain/constants';
import { KNOWN_BACKEND_ERRORS } from '@/domain/errors';
import de from '@/i18n/de';
import en from '@/i18n/en';
import { pickLanguage } from '@/i18n';

const migrationsDir = join(__dirname, '..', '..', '..', 'supabase', 'migrations');
const sql = readdirSync(migrationsDir)
  .filter((f) => f.endsWith('.sql'))
  .map((f) => readFileSync(join(migrationsDir, f), 'utf8'))
  .join('\n');

function keys(obj: unknown, prefix = ''): string[] {
  if (Array.isArray(obj)) return [`${prefix}[${obj.length}]`];
  if (obj && typeof obj === 'object') {
    return Object.entries(obj).flatMap(([k, v]) => keys(v, prefix ? `${prefix}.${k}` : k));
  }
  return [prefix];
}

describe('App und Datenbank stimmen überein', () => {
  it.each([...INTENTS])('Kontaktinteresse %s ist in der Datenbank angelegt', (code) => {
    expect(sql).toContain(`('${code}', `);
  });

  it.each([...INTERESTS])('Interesse %s ist in der Datenbank angelegt', (code) => {
    expect(sql).toContain(`('${code}', '`);
  });

  it('jeder Fehlercode der Datenbank ist in der App bekannt', () => {
    const raised = new Set([...sql.matchAll(/raise exception '([a-z_]+)'/g)].map((m) => m[1]));
    for (const code of raised) {
      expect(KNOWN_BACKEND_ERRORS).toContain(code);
    }
  });
});

describe('Übersetzungen', () => {
  it('Deutsch und Englisch haben dieselben Schlüssel', () => {
    expect(keys(en).sort()).toEqual(keys(de).sort());
  });

  it('jeder bekannte Fehlercode hat einen Text', () => {
    for (const code of KNOWN_BACKEND_ERRORS) {
      expect(de.errors).toHaveProperty(code);
    }
  });

  it('keine leeren Texte', () => {
    const empty = (obj: unknown): boolean =>
      typeof obj === 'string' ? obj.trim() === '' : Object.values(obj as object).some(empty);
    expect(empty(de)).toBe(false);
    expect(empty(en)).toBe(false);
  });

  it('wählt die Sprache anhand des Geräts, sonst Englisch', () => {
    expect(pickLanguage(['de-CH'])).toBe('de');
    expect(pickLanguage(['fr', 'de'])).toBe('de');
    expect(pickLanguage(['fr'])).toBe('en');
    expect(pickLanguage([null])).toBe('en');
  });
});
