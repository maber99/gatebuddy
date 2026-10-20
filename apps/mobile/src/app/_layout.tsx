import '@/i18n';

import { DarkTheme, DefaultTheme, Stack, ThemeProvider } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { useColorScheme } from 'react-native';

import { SessionProvider } from '@/lib/session';

SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const colorScheme = useColorScheme();
  const { t } = useTranslation();

  useEffect(() => {
    SplashScreen.hideAsync();
  }, []);

  return (
    <SessionProvider>
      <ThemeProvider value={colorScheme === 'dark' ? DarkTheme : DefaultTheme}>
        <Stack screenOptions={{ headerBackTitle: t('common.back') }}>
          <Stack.Screen name="index" options={{ headerShown: false }} />
          <Stack.Screen name="sign-in" options={{ title: t('auth.emailTitle') }} />
          <Stack.Screen name="onboarding" options={{ title: t('onboarding.title') }} />
          <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
          <Stack.Screen name="candidates" options={{ title: t('candidates.title') }} />
          <Stack.Screen name="safety" options={{ title: t('safety.title'), presentation: 'modal' }} />
        </Stack>
      </ThemeProvider>
    </SessionProvider>
  );
}
