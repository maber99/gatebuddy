/**
 * Wiederverwendbare Bausteine. Alle sind barrierearm beschriftet (accessibilityRole/Label/State).
 */
import type { ReactNode } from 'react';
import { Pressable, ScrollView, StyleSheet, TextInput, View, type TextInputProps } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { ThemedText } from '@/components/themed-text';
import { MaxContentWidth, Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';

export function Screen({ children, scroll = true }: { children: ReactNode; scroll?: boolean }) {
  const theme = useTheme();
  const content = <View style={styles.content}>{children}</View>;
  return (
    <SafeAreaView style={[styles.flex, { backgroundColor: theme.background }]} edges={['top', 'left', 'right']}>
      {scroll ? (
        <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
          {content}
        </ScrollView>
      ) : (
        content
      )}
    </SafeAreaView>
  );
}

type ButtonProps = {
  label: string;
  onPress?: () => void;
  variant?: 'primary' | 'secondary' | 'danger';
  disabled?: boolean;
  hint?: string;
  testID?: string;
};

export function Button({ label, onPress, variant = 'primary', disabled, hint, testID }: ButtonProps) {
  const theme = useTheme();
  const bg = variant === 'primary' ? theme.primary : variant === 'danger' ? theme.danger : theme.backgroundElement;
  const fg = variant === 'secondary' ? theme.text : theme.onPrimary;
  return (
    <Pressable
      testID={testID}
      accessibilityRole="button"
      accessibilityLabel={label}
      accessibilityHint={hint}
      accessibilityState={{ disabled: !!disabled }}
      disabled={disabled}
      onPress={onPress}
      style={({ pressed }) => [
        styles.button,
        { backgroundColor: bg, opacity: disabled ? 0.45 : pressed ? 0.8 : 1 },
      ]}>
      <ThemedText style={[styles.buttonLabel, { color: fg }]}>{label}</ThemedText>
    </Pressable>
  );
}

export function Chip({
  label,
  selected,
  onPress,
}: {
  label: string;
  selected: boolean;
  onPress: () => void;
}) {
  const theme = useTheme();
  return (
    <Pressable
      accessibilityRole="checkbox"
      accessibilityLabel={label}
      accessibilityState={{ checked: selected }}
      onPress={onPress}
      style={[
        styles.chip,
        {
          backgroundColor: selected ? theme.primary : theme.backgroundElement,
          borderColor: selected ? theme.primary : theme.border,
        },
      ]}>
      <ThemedText type="small" style={{ color: selected ? theme.onPrimary : theme.text }}>
        {label}
      </ThemedText>
    </Pressable>
  );
}

export function ChipGroup({ children }: { children: ReactNode }) {
  return <View style={styles.chipGroup}>{children}</View>;
}

export function Field({
  label,
  error,
  hint,
  ...props
}: TextInputProps & { label: string; error?: string; hint?: string }) {
  const theme = useTheme();
  return (
    <View style={styles.field}>
      <ThemedText type="smallBold">{label}</ThemedText>
      <TextInput
        accessibilityLabel={label}
        placeholderTextColor={theme.textSecondary}
        style={[
          styles.input,
          { color: theme.text, borderColor: error ? theme.danger : theme.border, backgroundColor: theme.backgroundElement },
        ]}
        {...props}
      />
      {hint && !error ? <ThemedText type="small" themeColor="textSecondary">{hint}</ThemedText> : null}
      {error ? <ThemedText type="small" style={{ color: theme.danger }} accessibilityLiveRegion="polite">{error}</ThemedText> : null}
    </View>
  );
}

export function Checkbox({
  label,
  checked,
  onChange,
  error,
}: {
  label: string;
  checked: boolean;
  onChange: (value: boolean) => void;
  error?: string;
}) {
  const theme = useTheme();
  return (
    <View style={styles.field}>
      <Pressable
        accessibilityRole="checkbox"
        accessibilityLabel={label}
        accessibilityState={{ checked }}
        onPress={() => onChange(!checked)}
        style={styles.checkboxRow}>
        <View
          style={[
            styles.checkbox,
            { borderColor: error ? theme.danger : theme.border, backgroundColor: checked ? theme.primary : 'transparent' },
          ]}>
          {checked ? <ThemedText style={{ color: theme.onPrimary, lineHeight: 18 }}>✓</ThemedText> : null}
        </View>
        <ThemedText style={styles.flex}>{label}</ThemedText>
      </Pressable>
      {error ? <ThemedText type="small" style={{ color: theme.danger }}>{error}</ThemedText> : null}
    </View>
  );
}

export function Card({ children }: { children: ReactNode }) {
  const theme = useTheme();
  return <View style={[styles.card, { backgroundColor: theme.backgroundElement, borderColor: theme.border }]}>{children}</View>;
}

export function Notice({ text, tone = 'info' }: { text: string; tone?: 'info' | 'warning' }) {
  const theme = useTheme();
  return (
    <View
      accessibilityRole="text"
      style={[styles.notice, { borderColor: tone === 'warning' ? theme.danger : theme.primary, backgroundColor: theme.backgroundElement }]}>
      <ThemedText type="small">{text}</ThemedText>
    </View>
  );
}

export function SectionTitle({ children }: { children: string }) {
  return (
    <ThemedText type="smallBold" accessibilityRole="header" style={styles.sectionTitle}>
      {children}
    </ThemedText>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  scroll: { flexGrow: 1 },
  content: {
    flex: 1,
    width: '100%',
    maxWidth: MaxContentWidth,
    alignSelf: 'center',
    padding: Spacing.three,
    gap: Spacing.three,
  },
  button: {
    minHeight: 48,
    borderRadius: 12,
    paddingHorizontal: Spacing.three,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonLabel: { fontWeight: 700 },
  chip: {
    minHeight: 36,
    borderRadius: 18,
    borderWidth: 1,
    paddingHorizontal: Spacing.three,
    justifyContent: 'center',
  },
  chipGroup: { flexDirection: 'row', flexWrap: 'wrap', gap: Spacing.two },
  field: { gap: Spacing.one },
  input: {
    minHeight: 48,
    borderWidth: 1,
    borderRadius: 12,
    paddingHorizontal: Spacing.three,
    paddingVertical: Spacing.two,
    fontSize: 16,
  },
  checkboxRow: { flexDirection: 'row', alignItems: 'flex-start', gap: Spacing.two, minHeight: 44 },
  checkbox: {
    width: 24,
    height: 24,
    borderRadius: 6,
    borderWidth: 2,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 2,
  },
  card: { borderRadius: 16, borderWidth: 1, padding: Spacing.three, gap: Spacing.two },
  notice: { borderLeftWidth: 4, borderRadius: 8, padding: Spacing.three },
  sectionTitle: { marginTop: Spacing.two },
});
