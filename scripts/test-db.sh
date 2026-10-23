#!/usr/bin/env bash
# Datenbank-Tests ohne Docker: frische Testdatenbank, Supabase-Nachbildung, alle Migrationen, pgTAP-Tests.
# Voraussetzungen: PostgreSQL 15+ (psql), pgTAP-Extension installiert, "prove" (Perl, meist vorinstalliert).
# Verbindung über die üblichen Variablen: PGHOST, PGPORT, PGUSER (Superuser nötig).
# Mit Supabase CLI + Docker stattdessen:  npx supabase start && npx supabase test db
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DB="${TEST_DB:-gatebuddy_test}"
PSQL=(psql -X -q -v ON_ERROR_STOP=1)

echo "==> Testdatenbank $DB neu anlegen"
"${PSQL[@]}" -d postgres -c "drop database if exists $DB with (force);" >/dev/null
"${PSQL[@]}" -d postgres -c "create database $DB;" >/dev/null

echo "==> Supabase-Nachbildung einspielen"
"${PSQL[@]}" -d "$DB" -f "$ROOT/scripts/local-supabase-shim.sql" >/dev/null

echo "==> Migrationen einspielen"
for f in "$ROOT"/supabase/migrations/*.sql; do
  echo "    $(basename "$f")"
  "${PSQL[@]}" -d "$DB" -f "$f" >/dev/null
done

echo "==> Entwicklungsdaten (seed.sql) einspielen – wie 'supabase db start'"
"${PSQL[@]}" -d "$DB" -f "$ROOT/supabase/seed.sql" >/dev/null

echo "==> pgTAP-Tests"
cd "$ROOT/supabase/tests"
export PGDATABASE="$DB"
export PGOPTIONS="-c search_path=public,extensions"
prove --ext .sql --exec 'psql -X -q -t -A -v ON_ERROR_STOP=1 -f' ./*.test.sql
