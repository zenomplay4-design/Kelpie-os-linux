#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$ROOT/config"
ERRORS=0

fail() { echo "FALHA: $*" >&2; ERRORS=$((ERRORS + 1)); }
need_file() { [[ -f "$1" ]] || fail "arquivo ausente: ${1#"$ROOT"/}"; }
need_dir() { [[ -d "$1" ]] || fail "diretório ausente: ${1#"$ROOT"/}"; }

echo "Kelpie OS V3 — verificações pré-compilação"
need_file "$ROOT/build-in-container.sh"
need_file "$ROOT/validate-packages.sh"
need_file "$CONFIG/package-lists/kelpie.list.chroot"
need_file "$CONFIG/hooks/normal/0200-kelpie-branding.hook.chroot"
need_file "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"
need_file "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/extension.js"
need_file "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/metadata.json"
need_dir "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local"

bash -n "$ROOT/build-in-container.sh" || fail "sintaxe Bash inválida em build-in-container.sh"
bash -n "$ROOT/validate-packages.sh" || fail "sintaxe Bash inválida em validate-packages.sh"
sh -n "$CONFIG/hooks/normal/0200-kelpie-branding.hook.chroot" || fail "sintaxe POSIX shell inválida no hook de identidade"

if ! grep -q 'kelpie-menu@kelpieos.local' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "extensão Kelpie não está habilitada no dconf"
fi
if ! grep -q 'kelpie-constellation.png' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "wallpaper de constelação não está configurado"
fi
if ! grep -q 'kelpie-paw.png' "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/extension.js"; then
  fail "ícone oficial da pata não está referenciado no menu"
fi

if ((ERRORS)); then
  echo "Pré-verificação reprovada: $ERRORS problema(s)." >&2
  exit 1
fi

echo "Pré-verificação estrutural aprovada."
