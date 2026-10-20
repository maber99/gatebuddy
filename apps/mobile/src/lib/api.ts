/**
 * Alle Serverzugriffe an einem Ort. Die Datenbank prüft Berechtigungen selbst (RLS);
 * diese Funktionen sind nur bequeme, typisierte Aufrufe.
 * Status: Implementiert · gegen echten Server noch nicht getestet.
 */
import type { Intent, LanguageCode, PhotoVisibility } from '@/domain/constants';
import { requireSupabase } from './supabase';

export type Candidate = {
  profile_id: string;
  display_name: string;
  bio: string | null;
  avatar_path: string | null;
  speaks: string[];
  learns: string[];
  interests: string[];
  shared_intents: string[];
  overlap_starts_at: string;
  overlap_ends_at: string;
  location_verified: boolean;
  score: number;
};

export type MatchSummary = {
  match_id: string;
  partner_id: string;
  partner_name: string;
  partner_avatar_path: string | null;
  airport_iata: string;
  created_at: string;
  closed_at: string | null;
  last_message_at: string | null;
  last_message_preview: string | null;
};

export type Presence = {
  id: string;
  airport_iata: string;
  starts_at: string;
  ends_at: string;
  intents: string[];
  location_verified: boolean;
  flight_number: string | null;
  cancelled_at: string | null;
};

function unwrap<T>(result: { data: T | null; error: unknown }): T {
  if (result.error) throw result.error;
  return result.data as T;
}

export async function getMyProfile() {
  const rows = unwrap(await requireSupabase().rpc('my_profile'));
  return (rows as { id: string; display_name: string; status: string }[])[0] ?? null;
}

export async function createProfile(input: {
  displayName: string;
  bio: string | null;
  photoVisibility: PhotoVisibility;
  termsVersion: string;
  speaks: LanguageCode[];
  learns: LanguageCode[];
  interests: string[];
}) {
  const db = requireSupabase();
  const { data: auth } = await db.auth.getUser();
  const id = auth.user?.id;
  if (!id) throw { message: 'not_authenticated' };
  unwrap(
    await db.from('profiles').insert({
      id,
      display_name: input.displayName.trim(),
      bio: input.bio,
      photo_visibility: input.photoVisibility,
      is_adult_confirmed: true,
      terms_version: input.termsVersion,
    }),
  );
  const languages = [
    ...input.speaks.map((language_code) => ({ profile_id: id, language_code, mode: 'speaks' })),
    ...input.learns.map((language_code) => ({ profile_id: id, language_code, mode: 'learns' })),
  ];
  if (languages.length) unwrap(await db.from('profile_languages').insert(languages));
  if (input.interests.length) {
    unwrap(
      await db.from('profile_interests').insert(input.interests.map((interest_code) => ({ profile_id: id, interest_code }))),
    );
  }
}

export async function getAirportActivity(iata: string) {
  const rows = unwrap(await requireSupabase().rpc('airport_activity', { p_iata: iata }));
  return (rows as { active_now: number; planned_next_7_days: number }[])[0] ?? { active_now: 0, planned_next_7_days: 0 };
}

export async function getMyUpcomingPresences(): Promise<Presence[]> {
  return unwrap(
    await requireSupabase()
      .from('presences')
      .select('id, airport_iata, starts_at, ends_at, intents, location_verified, flight_number, cancelled_at')
      .is('cancelled_at', null)
      .gt('ends_at', new Date().toISOString())
      .order('starts_at'),
  ) as Presence[];
}

export async function createPresence(input: {
  airport: string;
  start: Date;
  end: Date;
  intents: Intent[];
  flightNumber: string | null;
  locationVerified: boolean;
}): Promise<Presence> {
  return unwrap(
    await requireSupabase()
      .from('presences')
      .insert({
        airport_iata: input.airport,
        starts_at: input.start.toISOString(),
        ends_at: input.end.toISOString(),
        intents: input.intents,
        flight_number: input.flightNumber,
        location_verified: input.locationVerified,
      })
      .select('id, airport_iata, starts_at, ends_at, intents, location_verified, flight_number, cancelled_at')
      .single(),
  ) as Presence;
}

export async function cancelPresence(id: string) {
  unwrap(await requireSupabase().from('presences').update({ cancelled_at: new Date().toISOString() }).eq('id', id));
}

export async function discoverCandidates(presenceId: string): Promise<Candidate[]> {
  return unwrap(await requireSupabase().rpc('discover_candidates', { p_presence_id: presenceId })) as Candidate[];
}

export async function react(targetId: string, kind: 'interested' | 'pass') {
  const rows = unwrap(await requireSupabase().rpc('react', { p_target: targetId, p_kind: kind }));
  return (rows as { is_match: boolean; match_id: string | null }[])[0];
}

export async function getMyMatches(): Promise<MatchSummary[]> {
  return unwrap(await requireSupabase().rpc('my_matches')) as MatchSummary[];
}

export async function blockUser(userId: string) {
  unwrap(await requireSupabase().from('blocks').insert({ blocked_id: userId }));
}

export async function submitReport(input: { profileId: string; reason: string; details?: string; messageId?: string }) {
  return unwrap(
    await requireSupabase().rpc('submit_report', {
      p_profile_id: input.profileId,
      p_reason: input.reason,
      p_details: input.details ?? null,
      p_message_id: input.messageId ?? null,
    }),
  );
}

export async function deleteMyAccount() {
  const db = requireSupabase();
  const { data: auth } = await db.auth.getUser();
  const id = auth.user?.id;
  if (id) {
    // Profilbild zuerst über die Storage-API löschen (direktes Löschen in der Datenbank ist nicht vorgesehen)
    const { data: files } = await db.storage.from('avatars').list(id);
    if (files?.length) await db.storage.from('avatars').remove(files.map((f) => `${id}/${f.name}`));
  }
  unwrap(await db.rpc('delete_my_account'));
  await db.auth.signOut();
}
