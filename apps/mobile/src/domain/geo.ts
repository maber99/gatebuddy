/**
 * Einmalige Standortprüfung auf dem Gerät (ADR-009).
 * Die Koordinaten verlassen das Gerät NICHT. Gespeichert wird nur "bestätigt: ja/nein".
 */

export type Coordinates = { latitude: number; longitude: number };
export type AirportArea = { center_lat: number; center_lon: number; radius_m: number };

const EARTH_RADIUS_M = 6_371_000;
const toRad = (deg: number) => (deg * Math.PI) / 180;

/** Entfernung zweier Punkte in Metern (Haversine-Formel). */
export function distanceMeters(a: Coordinates, b: Coordinates): number {
  const dLat = toRad(b.latitude - a.latitude);
  const dLon = toRad(b.longitude - a.longitude);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(a.latitude)) * Math.cos(toRad(b.latitude)) * Math.sin(dLon / 2) ** 2;
  return 2 * EARTH_RADIUS_M * Math.asin(Math.min(1, Math.sqrt(h)));
}

/**
 * Liegt die Position im Flughafenbereich?
 * `accuracyM` (Messungenauigkeit) wird berücksichtigt, aber begrenzt,
 * damit sehr ungenaue Messungen nicht automatisch "bestätigt" ergeben.
 */
export function isWithinAirport(position: Coordinates, airport: AirportArea, accuracyM = 0): boolean {
  const tolerance = Math.min(Math.max(accuracyM, 0), 500);
  const distance = distanceMeters(position, { latitude: airport.center_lat, longitude: airport.center_lon });
  return distance <= airport.radius_m + tolerance;
}
