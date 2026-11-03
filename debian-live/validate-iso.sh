#!/usr/bin/env bash
set -Eeuo pipefail

ISO="${1:-dist/kelpie-os-linux-v3-amd64.iso}"
OUT_DIR="$(dirname "$ISO")"
NAME="$(basename "$ISO")"
[[ -s "$ISO" ]] || { echo "ERRO: ISO ausente ou vazia: $ISO" >&2; exit 1; }

SIZE="$(stat -c '%s' "$ISO")"
# A GNOME live image should be comfortably larger than a minimal installer.
(( SIZE > 500000000 )) || { echo "ERRO: ISO inesperadamente pequena ($SIZE bytes)." >&2; exit 1; }

command -v xorriso >/dev/null
REPORT="$(mktemp)"
TREE="$(mktemp)"
trap 'rm -f "$REPORT" "$TREE"' EXIT

xorriso -indev "$ISO" -report_el_torito plain >"$REPORT" 2>&1
grep -qi 'El Torito' "$REPORT" || { cat "$REPORT"; echo "ERRO: catálogo El Torito ausente." >&2; exit 1; }
xorriso -indev "$ISO" -find / -type f -exec lsdl >"$TREE" 2>&1

for required in vmlinuz initrd filesystem.squashfs; do
  grep -qi "$required" "$TREE" || { cat "$TREE"; echo "ERRO: arquivo essencial ausente na ISO: $required" >&2; exit 1; }
done

cd "$OUT_DIR"
sha256sum "$NAME" | tee SHA256SUMS
sha256sum --check SHA256SUMS
file "$NAME"
echo "ISO estruturalmente validada: $NAME ($SIZE bytes)."
echo "Atenção: esta validação não substitui boot/instalação em VM ou hardware real."
