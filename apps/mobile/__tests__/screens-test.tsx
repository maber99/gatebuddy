/**
 * Bildschirm-Tests im Vorschaumodus (ohne Server).
 */
import { render, screen, userEvent } from '@testing-library/react-native';

import '@/i18n';
import i18n from '@/i18n';
import OnboardingScreen from '@/app/onboarding';
import SafetyScreen from '@/app/safety';
import WelcomeScreen from '@/app/index';

jest.mock('expo-router', () => ({
  router: { push: jest.fn(), replace: jest.fn() },
  Redirect: () => null,
}));
jest.mock('@/lib/supabase', () => ({ supabase: null, requireSupabase: () => { throw new Error('backend_not_configured'); } }));

beforeAll(async () => {
  await i18n.changeLanguage('de');
});

describe('Startbildschirm', () => {
  it('zeigt Claim, Anmeldeoptionen und Hinweis auf den Vorschaumodus', async () => {
    await render(<WelcomeScreen />);
    expect(await screen.findByText('Aus Wartezeit wird gemeinsame Zeit.')).toBeTruthy();
    expect(screen.getByRole('button', { name: 'Mit Apple fortfahren' })).toBeDisabled();
    expect(screen.getByText(/Entwicklungsmodus/)).toBeTruthy();
    expect(screen.getByText(/mindestens 18 Jahre/)).toBeTruthy();
  });
});

describe('Profil anlegen', () => {
  it('verhindert das Absenden ohne Name, 18+-Bestätigung und Zustimmung', async () => {
    await render(<OnboardingScreen />);
    await userEvent.setup().press(screen.getByTestId('finish-onboarding'));
    expect(await screen.findByText('Bitte gib einen Namen ein.')).toBeTruthy();
    expect(screen.getByText('GateBuddy ist nur für Personen ab 18 Jahren.')).toBeTruthy();
    expect(screen.getByText('Bitte akzeptiere die Nutzungsbedingungen.')).toBeTruthy();
  });

  it('Bild-Sichtbarkeit ist standardmässig "erst nach Match" (ADR-007)', async () => {
    await render(<OnboardingScreen />);
    expect(screen.getByRole('checkbox', { name: 'Erst nach einem Match (empfohlen)' })).toBeChecked();
    expect(screen.getByRole('checkbox', { name: 'Passende Personen am Flughafen' })).not.toBeChecked();
  });

  it('auf Englisch umschaltbar', async () => {
    await i18n.changeLanguage('en');
    await render(<OnboardingScreen />);
    expect(screen.getByText('I am at least 18 years old.')).toBeTruthy();
    await i18n.changeLanguage('de');
  });
});

describe('Sicherheitstipps', () => {
  it('zeigt alle sechs Hinweise', async () => {
    await render(<SafetyScreen />);
    expect(screen.getByText(/öffentlichen Orten/)).toBeTruthy();
    expect(screen.getByText(/Sicherheitsbereich nicht gemeinsam/)).toBeTruthy();
    expect(screen.getAllByText(/./).length).toBeGreaterThanOrEqual(6);
  });
});
