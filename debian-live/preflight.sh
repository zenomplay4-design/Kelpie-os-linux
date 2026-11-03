#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$ROOT/config"
ERRORS=0

fail() { echo "FALHA: $*" >&2; ERRORS=$((ERRORS + 1)); }
need_file() { [[ -f "$1" ]] || fail "arquivo ausente: ${1#"$ROOT"/}"; }
need_dir() { [[ -d "$1" ]] || fail "diretório ausente: ${1#"$ROOT"/}"; }

echo "Kelpie OS V3 — verificações pré-compilação"
for file in \
  "$ROOT/build-in-container.sh" "$ROOT/validate-packages.sh" "$ROOT/README-V3-VALIDATION.md" "$ROOT/CALAMARES-TEST-PLAN-V3.md" "$ROOT/HARDWARE-VALIDATION-MATRIX-V3.md" \
  "$CONFIG/package-lists/kelpie.list.chroot" "$CONFIG/package-lists/kelpie-diagnostics.list.chroot" \
  "$CONFIG/hooks/normal/0200-kelpie-branding.hook.chroot" \
  "$CONFIG/hooks/normal/0300-kelpie-dconf.hook.chroot" \
  "$CONFIG/hooks/normal/0400-kelpie-firewall.hook.chroot" \
  "$CONFIG/includes.chroot/etc/apt/apt.conf.d/20auto-upgrades" \
  "$CONFIG/includes.chroot/etc/default/ufw" "$CONFIG/includes.chroot/etc/ufw/ufw.conf" \
  "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie" \
  "$CONFIG/includes.chroot/etc/calamares/settings.conf" \
  "$CONFIG/includes.chroot/etc/calamares/branding/kelpie/branding.desc" \
  "$CONFIG/includes.chroot/usr/share/applications/kelpie-install.desktop" \
  "$CONFIG/includes.chroot/usr/share/applications/kelpie-monitor.desktop" \
  "$CONFIG/includes.chroot/usr/share/applications/kelpie-update.desktop" \
  "$CONFIG/includes.chroot/usr/share/applications/kelpie-tweaks.desktop" \
  "$CONFIG/includes.chroot/usr/share/applications/kelpie-disk.desktop" \
  "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie-monitor.py" \
  "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie-update.py" \
  "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie-tweaks.py" \
  "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie-disk.py" \
  "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie_utils.py" \
  "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/extension.js" \
  "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/metadata.json"; do
  need_file "$file"
done
need_dir "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local"

bash -n "$ROOT/preflight.sh" || fail "sintaxe Bash inválida em preflight.sh"
bash -n "$ROOT/build-in-container.sh" || fail "sintaxe Bash inválida em build-in-container.sh"
bash -n "$ROOT/validate-packages.sh" || fail "sintaxe Bash inválida em validate-packages.sh"
for hook in "$CONFIG"/hooks/normal/*.hook.chroot; do
  sh -n "$hook" || fail "sintaxe POSIX shell inválida em $hook"
done

if command -v python3 >/dev/null 2>&1; then
  python3 -m json.tool "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/metadata.json" >/dev/null || fail "metadata.json da extensão não é JSON válido"
  for app in monitor update tweaks disk; do
    PYTHONPYCACHEPREFIX=/tmp/kelpie-pycache python3 -m py_compile "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie-$app.py" || fail "sintaxe Python inválida no Kelpie $app"
  done
  ROOT="$ROOT" python3 - <<'PY' || fail "configurações YAML do Calamares inválidas"
import os
import yaml
from pathlib import Path
root = Path(os.environ["ROOT"])
for name in (
    "config/includes.chroot/etc/calamares/settings.conf",
    "config/includes.chroot/etc/calamares/branding/kelpie/branding.desc",
):
    with open(root / name, encoding="utf-8") as stream:
        yaml.safe_load(stream)
print("YAML do Calamares válido.")
PY
else
  fail "python3 não encontrado para validar JSON/YAML"
fi

grep -q '^ENABLED=yes$' "$CONFIG/includes.chroot/etc/ufw/ufw.conf" || fail "UFW não está habilitado para o primeiro boot"
grep -q '^DEFAULT_INPUT_POLICY="DROP"$' "$CONFIG/includes.chroot/etc/default/ufw" || fail "UFW deve bloquear conexões de entrada por padrão"
grep -q '^DEFAULT_OUTPUT_POLICY="ACCEPT"$' "$CONFIG/includes.chroot/etc/default/ufw" || fail "UFW deve permitir conexões de saída por padrão"
grep -q 'APT::Periodic::Unattended-Upgrade "1"' "$CONFIG/includes.chroot/etc/apt/apt.conf.d/20auto-upgrades" || fail "atualizações automáticas de segurança não estão habilitadas"
grep -q 'gnome-shell-extension-dashtodock' "$CONFIG/package-lists/kelpie.list.chroot" || fail "Dash to Dock não está incluído"
grep -q "dock-position='BOTTOM'" "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie" || fail "dock não está na posição inferior"
grep -q 'autohide=false' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie" || fail "dock deve permanecer visível"
grep -q 'intellihide=false' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie" || fail "ocultação inteligente do dock deve estar desativada"
grep -q 'dconf update' "$CONFIG/hooks/normal/0300-kelpie-dconf.hook.chroot" || fail "hook não compila o banco dconf"
grep -q 'kelpie-menu@kelpieos.local' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie" || fail "extensão Kelpie não está habilitada"
grep -q 'kelpie-constellation.png' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie" || fail "wallpaper de constelação não está configurado"
grep -q 'kelpie-paw.png' "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/extension.js" || fail "ícone oficial da pata não está referenciado"
grep -q '^branding: kelpie$' "$CONFIG/includes.chroot/etc/calamares/settings.conf" || fail "Calamares não usa a identidade Kelpie"
grep -q '^prompt-install: true$' "$CONFIG/includes.chroot/etc/calamares/settings.conf" || fail "Calamares deve pedir confirmação antes da instalação"

if (( ERRORS > 0 )); then
  echo "Pré-verificação reprovada: $ERRORS problema(s)." >&2
  exit 1
fi
echo "Pré-verificação estrutural aprovada."
