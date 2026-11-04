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
  "$ROOT/build-in-container.sh" "$ROOT/validate-packages.sh" "$ROOT/validate-iso.sh" \
  "$ROOT/validate-appstream.py" "$ROOT/assets/kelpie-constellation.svg" \
  "$ROOT/README-V3-VALIDATION.md" "$ROOT/CALAMARES-TEST-PLAN-V3.md" "$ROOT/HARDWARE-VALIDATION-MATRIX-V3.md" \
  "$CONFIG/package-lists/kelpie.list.chroot" "$CONFIG/package-lists/kelpie-diagnostics.list.chroot" \
  "$CONFIG/hooks/normal/0200-kelpie-branding.hook.chroot" \
  "$CONFIG/hooks/normal/0300-kelpie-dconf.hook.chroot" \
  "$CONFIG/hooks/normal/0400-kelpie-firewall.hook.chroot" \
  "$CONFIG/hooks/normal/0500-kelpie-flatpak.hook.chroot" \
  "$CONFIG/includes.chroot/etc/apt/apt.conf.d/20auto-upgrades" \
  "$CONFIG/includes.chroot/etc/default/ufw" "$CONFIG/includes.chroot/etc/ufw/ufw.conf" \
  "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie" \
  "$CONFIG/includes.chroot/etc/dconf/profile/gdm" "$CONFIG/includes.chroot/etc/dconf/db/gdm.d/01-kelpie" \
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

grep -q 'viewBox="0 0 1920 1080"' "$ROOT/assets/kelpie-constellation.svg" || fail "wallpaper oficial deve ter proporção 16:9"
for script in preflight.sh build-in-container.sh validate-packages.sh validate-iso.sh; do
  bash -n "$ROOT/$script" || fail "sintaxe Bash inválida em $script"
done
for hook in "$CONFIG"/hooks/normal/*.hook.chroot; do
  sh -n "$hook" || fail "sintaxe POSIX inválida em $hook"
done

python3 -m json.tool "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/metadata.json" >/dev/null || fail "metadata.json inválido"
for app in monitor update tweaks disk; do
  PYTHONPYCACHEPREFIX=/tmp/kelpie-pycache python3 -m py_compile "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie-$app.py" || fail "sintaxe Python inválida no Kelpie $app"
done
PYTHONPYCACHEPREFIX=/tmp/kelpie-pycache python3 -m py_compile "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie_utils.py" || fail "sintaxe Python inválida em kelpie_utils.py"
ROOT="$ROOT" python3 - <<'PY' || fail "YAML do Calamares inválido"
import os, yaml
from pathlib import Path
root = Path(os.environ["ROOT"])
for name in ("config/includes.chroot/etc/calamares/settings.conf",
             "config/includes.chroot/etc/calamares/branding/kelpie/branding.desc"):
    with open(root / name, encoding="utf-8") as stream:
        yaml.safe_load(stream)
print("YAML do Calamares válido.")
PY

grep -q '^ENABLED=yes$' "$CONFIG/includes.chroot/etc/ufw/ufw.conf" || fail "UFW não habilitado"
grep -q '^DEFAULT_INPUT_POLICY="DROP"$' "$CONFIG/includes.chroot/etc/default/ufw" || fail "UFW deve bloquear entrada"
grep -q '^DEFAULT_OUTPUT_POLICY="ACCEPT"$' "$CONFIG/includes.chroot/etc/default/ufw" || fail "UFW deve permitir saída"
grep -q 'remote-add --if-not-exists flathub' "$CONFIG/hooks/normal/0500-kelpie-flatpak.hook.chroot" || fail "Flathub não configurado"
grep -q 'APT::Periodic::Unattended-Upgrade "1"' "$CONFIG/includes.chroot/etc/apt/apt.conf.d/20auto-upgrades" || fail "atualizações automáticas ausentes"
grep -q 'gnome-shell-extension-dashtodock' "$CONFIG/package-lists/kelpie.list.chroot" || fail "Dash to Dock ausente"
grep -q "dock-position='BOTTOM'" "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie" || fail "dock não está embaixo"
grep -q 'autohide=false' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie" || fail "dock deve ficar visível"
grep -q 'dconf update' "$CONFIG/hooks/normal/0300-kelpie-dconf.hook.chroot" || fail "hook dconf ausente"
grep -q 'kelpie-constellation.png' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie" || fail "wallpaper não configurado"
grep -q 'kelpie-paw.svg' "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/extension.js" || fail "pata não referenciada no menu"
grep -q '^branding: kelpie$' "$CONFIG/includes.chroot/etc/calamares/settings.conf" || fail "branding Calamares ausente"
grep -q '^prompt-install: true$' "$CONFIG/includes.chroot/etc/calamares/settings.conf" || fail "confirmação Calamares ausente"
grep -q 'trixie-backports' "$ROOT/build-in-container.sh" || fail "Debian backports não configurado no build"
grep -q 'Pin-Priority: 990' "$ROOT/build-in-container.sh" || fail "prioridade backports não configurada"
grep -q 'xserver-xorg-video-nvidia' "$ROOT/build-in-container.sh" || fail "pin NVIDIA ausente"
if grep -A2 '^Package: nvidia-' "$ROOT/build-in-container.sh" | grep -q 'linux-\\*'; then
  fail "kernel não deve ser atualizado automaticamente para backports"
fi
grep -Fq 'kernel estável Debian 13 (6.12 LTS)' "$CONFIG/package-lists/kelpie.list.chroot" || fail "kernel estável para NVIDIA não documentado"

if (( ERRORS > 0 )); then
  echo "Pré-verificação reprovada: $ERRORS problema(s)." >&2
  exit 1
fi
echo "Pré-verificação estrutural aprovada."
