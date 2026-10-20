/**
 * Below are the colors that are used in the app. The colors are defined in the light and dark mode.
 * There are many other ways to style your app. For example, [Nativewind](https://www.nativewind.dev/), [Tamagui](https://tamagui.dev/), [unistyles](https://unistyl.es/), etc.
 */

import '@/global.css';

import { Platform } from 'react-native';

/**
 * Farben (vorläufig, Designentscheidung des Gründers steht aus – siehe docs/ROADMAP.md Phase 5).
 * Ruhig, kontrastreich, ohne Dating-Assoziation. Kontraste für Text >= 4.5:1 gewählt.
 */
export const Colors = {
  light: {
    text: '#0E1A24',
    background: '#FFFFFF',
    backgroundElement: '#F1F4F7',
    backgroundSelected: '#DCE6EE',
    textSecondary: '#4F5D6B',
    primary: '#0B5F8A',
    onPrimary: '#FFFFFF',
    border: '#C9D3DC',
    danger: '#B42318',
    success: '#1E7A46',
  },
  dark: {
    text: '#F3F6F9',
    background: '#0B1218',
    backgroundElement: '#17212B',
    backgroundSelected: '#22313E',
    textSecondary: '#A9B6C2',
    primary: '#5FB4E0',
    onPrimary: '#06202F',
    border: '#2E3E4C',
    danger: '#F97066',
    success: '#4FC783',
  },
} as const;

export type ThemeColor = keyof typeof Colors.light & keyof typeof Colors.dark;

export const Fonts = Platform.select({
  ios: {
    /** iOS `UIFontDescriptorSystemDesignDefault` */
    sans: 'system-ui',
    /** iOS `UIFontDescriptorSystemDesignSerif` */
    serif: 'ui-serif',
    /** iOS `UIFontDescriptorSystemDesignRounded` */
    rounded: 'ui-rounded',
    /** iOS `UIFontDescriptorSystemDesignMonospaced` */
    mono: 'ui-monospace',
  },
  default: {
    sans: 'normal',
    serif: 'serif',
    rounded: 'normal',
    mono: 'monospace',
  },
  web: {
    sans: 'var(--font-display)',
    serif: 'var(--font-serif)',
    rounded: 'var(--font-rounded)',
    mono: 'var(--font-mono)',
  },
});

export const Spacing = {
  half: 2,
  one: 4,
  two: 8,
  three: 16,
  four: 24,
  five: 32,
  six: 64,
} as const;

export const BottomTabInset = Platform.select({ ios: 50, android: 80 }) ?? 0;
export const MaxContentWidth = 800;
