set -euo pipefail

CONTAINER="${PGCONTAINER:-if4040-postgres}"
PGUSER="${PGUSER:-admin}"
PGDATABASE="${PGDATABASE:-project0_db}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="$SCRIPT_DIR/results"
mkdir -p "$OUT_DIR"

for f in "$SCRIPT_DIR"/read/*.sql "$SCRIPT_DIR"/write/*.sql; do
    kind="$(basename "$(dirname "$f")")"
    name="$(basename "$f" .sql)"
    out="$OUT_DIR/${kind}_${name}.out"
    echo "==> [$kind] $name"
    docker exec -i "$CONTAINER" psql -U "$PGUSER" -d "$PGDATABASE" < "$f" > "$out" 2>&1
    tail -n 3 "$out" | sed 's/^/    /'
done

echo ""
echo "Selesai. Semua output tersimpan di $OUT_DIR"
