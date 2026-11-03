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
need_file "$ROOT/README-V3-VALIDATION.md"
need_file "$CONFIG/package-lists/kelpie.list.chroot"
need_file "$CONFIG/package-lists/kelpie-diagnostics.list.chroot"
need_file "$CONFIG/hooks/normal/0200-kelpie-branding.hook.chroot"
need_file "$CONFIG/hooks/normal/0300-kelpie-dconf.hook.chroot"
need_file "$CONFIG/includes.chroot/etc/apt/apt.conf.d/20auto-upgrades"
need_file "$CONFIG/includes.chroot/etc/default/ufw"
need_file "$CONFIG/includes.chroot/etc/ufw/ufw.conf"
need_file "$CONFIG/hooks/normal/0400-kelpie-firewall.hook.chroot"
need_file "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"
need_file "$CONFIG/includes.chroot/etc/calamares/settings.conf"
need_file "$CONFIG/includes.chroot/etc/calamares/branding/kelpie/branding.desc"
need_file "$CONFIG/includes.chroot/usr/share/applications/kelpie-install.desktop"
need_file "$CONFIG/includes.chroot/usr/share/applications/kelpie-monitor.desktop"
need_file "$CONFIG/includes.chroot/usr/share/applications/kelpie-update.desktop"
need_file "$CONFIG/includes.chroot/usr/share/applications/kelpie-tweaks.desktop"
need_file "$CONFIG/includes.chroot/usr/share/applications/kelpie-disk.desktop"
need_file "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie-monitor.py"
need_file "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie-update.py"
need_file "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie-tweaks.py"
need_file "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie-disk.py"
need_file "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/extension.js"
need_file "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/metadata.json"
need_dir "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local"

bash -n "$ROOT/preflight.sh" || fail "sintaxe Bash inválida em preflight.sh"
bash -n "$ROOT/build-in-container.sh" || fail "sintaxe Bash inválida em build-in-container.sh"
bash -n "$ROOT/validate-packages.sh" || fail "sintaxe Bash inválida em validate-packages.sh"
sh -n "$CONFIG/hooks/normal/0200-kelpie-branding.hook.chroot" || fail "sintaxe POSIX shell inválida no hook de identidade"
sh -n "$CONFIG/hooks/normal/0300-kelpie-dconf.hook.chroot" || fail "sintaxe POSIX shell inválida no hook dconf"
sh -n "$CONFIG/hooks/normal/0400-kelpie-firewall.hook.chroot" || fail "sintaxe POSIX shell inválida no hook do firewall"

if command -v python3 >/dev/null 2>&1; then
  python3 -m json.tool "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/metadata.json" >/dev/null || fail "metadata.json da extensão não é JSON válido"
  PYTHONPYCACHEPREFIX=/tmp/kelpie-pycache python3 -m py_compile "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie-monitor.py" || fail "sintaxe Python inválida no Kelpie Monitor"
  PYTHONPYCACHEPREFIX=/tmp/kelpie-pycache python3 -m py_compile "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie-update.py" || fail "sintaxe Python inválida no Kelpie Update"
  PYTHONPYCACHEPREFIX=/tmp/kelpie-pycache python3 -m py_compile "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie-tweaks.py" || fail "sintaxe Python inválida no Kelpie Tweaks"
  PYTHONPYCACHEPREFIX=/tmp/kelpie-pycache python3 -m py_compile "$CONFIG/includes.chroot/usr/lib/kelpie/kelpie-disk.py" || fail "sintaxe Python inválida no Kelpie Disk"
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

if ! grep -q '^ENABLED=yes
  fail "atualizações automáticas de segurança não estão habilitadas"
fi
if ! grep -q 'gnome-shell-extension-dashtodock' "$CONFIG/package-lists/kelpie.list.chroot"; then
  fail "Dash to Dock não está incluído na imagem"
fi
if ! grep -q "dock-position='BOTTOM'" "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "dock não está configurado na posição inferior"
fi
if ! grep -q 'autohide=false' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "dock deve permanecer visível"
fi
if ! grep -q 'intellihide=false' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "ocultação inteligente do dock deve estar desativada"
fi
if ! grep -q 'dconf update' "$CONFIG/hooks/normal/0300-kelpie-dconf.hook.chroot"; then
  fail "hook não compila o banco dconf"
fi

if ! grep -q 'kelpie-menu@kelpieos.local' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "extensão Kelpie não está habilitada no dconf"
fi
if ! grep -q 'kelpie-constellation.png' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "wallpaper de constelação não está configurado"
fi
if ! grep -q 'kelpie-paw.png' "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/extension.js"; then
  fail "ícone oficial da pata não está referenciado no menu"
fi
if ! grep -q '^branding: kelpie$' "$CONFIG/includes.chroot/etc/calamares/settings.conf"; then
  fail "Calamares não está usando a identidade Kelpie"
fi
if ! grep -q '^prompt-install: true$' "$CONFIG/includes.chroot/etc/calamares/settings.conf"; then
  fail "Calamares deve pedir confirmação antes de iniciar a instalação"
fi

if ((ERRORS)); then
  echo "Pré-verificação reprovada: $ERRORS problema(s)." >&2
  exit 1
fi

echo "Pré-verificação estrutural aprovada."
 "$CONFIG/includes.chroot/etc/ufw/ufw.conf"; then
  fail "UFW não está habilitado para o primeiro boot"
fi
if ! grep -q '^DEFAULT_INPUT_POLICY="DROP"
  fail "atualizações automáticas de segurança não estão habilitadas"
fi
if ! grep -q 'gnome-shell-extension-dashtodock' "$CONFIG/package-lists/kelpie.list.chroot"; then
  fail "Dash to Dock não está incluído na imagem"
fi
if ! grep -q "dock-position='BOTTOM'" "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "dock não está configurado na posição inferior"
fi
if ! grep -q 'autohide=false' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "dock deve permanecer visível"
fi
if ! grep -q 'intellihide=false' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "ocultação inteligente do dock deve estar desativada"
fi
if ! grep -q 'dconf update' "$CONFIG/hooks/normal/0300-kelpie-dconf.hook.chroot"; then
  fail "hook não compila o banco dconf"
fi

if ! grep -q 'kelpie-menu@kelpieos.local' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "extensão Kelpie não está habilitada no dconf"
fi
if ! grep -q 'kelpie-constellation.png' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "wallpaper de constelação não está configurado"
fi
if ! grep -q 'kelpie-paw.png' "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/extension.js"; then
  fail "ícone oficial da pata não está referenciado no menu"
fi
if ! grep -q '^branding: kelpie$' "$CONFIG/includes.chroot/etc/calamares/settings.conf"; then
  fail "Calamares não está usando a identidade Kelpie"
fi
if ! grep -q '^prompt-install: true$' "$CONFIG/includes.chroot/etc/calamares/settings.conf"; then
  fail "Calamares deve pedir confirmação antes de iniciar a instalação"
fi

if ((ERRORS)); then
  echo "Pré-verificação reprovada: $ERRORS problema(s)." >&2
  exit 1
fi

echo "Pré-verificação estrutural aprovada."
 "$CONFIG/includes.chroot/etc/default/ufw"; then
  fail "UFW deve bloquear conexões de entrada por padrão"
fi
if ! grep -q '^DEFAULT_OUTPUT_POLICY="ACCEPT"
  fail "atualizações automáticas de segurança não estão habilitadas"
fi
if ! grep -q 'gnome-shell-extension-dashtodock' "$CONFIG/package-lists/kelpie.list.chroot"; then
  fail "Dash to Dock não está incluído na imagem"
fi
if ! grep -q "dock-position='BOTTOM'" "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "dock não está configurado na posição inferior"
fi
if ! grep -q 'autohide=false' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "dock deve permanecer visível"
fi
if ! grep -q 'intellihide=false' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "ocultação inteligente do dock deve estar desativada"
fi
if ! grep -q 'dconf update' "$CONFIG/hooks/normal/0300-kelpie-dconf.hook.chroot"; then
  fail "hook não compila o banco dconf"
fi

if ! grep -q 'kelpie-menu@kelpieos.local' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "extensão Kelpie não está habilitada no dconf"
fi
if ! grep -q 'kelpie-constellation.png' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "wallpaper de constelação não está configurado"
fi
if ! grep -q 'kelpie-paw.png' "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/extension.js"; then
  fail "ícone oficial da pata não está referenciado no menu"
fi
if ! grep -q '^branding: kelpie$' "$CONFIG/includes.chroot/etc/calamares/settings.conf"; then
  fail "Calamares não está usando a identidade Kelpie"
fi
if ! grep -q '^prompt-install: true$' "$CONFIG/includes.chroot/etc/calamares/settings.conf"; then
  fail "Calamares deve pedir confirmação antes de iniciar a instalação"
fi

if ((ERRORS)); then
  echo "Pré-verificação reprovada: $ERRORS problema(s)." >&2
  exit 1
fi

echo "Pré-verificação estrutural aprovada."
 "$CONFIG/includes.chroot/etc/default/ufw"; then
  fail "UFW deve permitir conexões de saída por padrão"
fi
if ! grep -q 'APT::Periodic::Unattended-Upgrade "1"' "$CONFIG/includes.chroot/etc/apt/apt.conf.d/20auto-upgrades"; then
  fail "atualizações automáticas de segurança não estão habilitadas"
fi
if ! grep -q 'gnome-shell-extension-dashtodock' "$CONFIG/package-lists/kelpie.list.chroot"; then
  fail "Dash to Dock não está incluído na imagem"
fi
if ! grep -q "dock-position='BOTTOM'" "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "dock não está configurado na posição inferior"
fi
if ! grep -q 'autohide=false' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "dock deve permanecer visível"
fi
if ! grep -q 'intellihide=false' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "ocultação inteligente do dock deve estar desativada"
fi
if ! grep -q 'dconf update' "$CONFIG/hooks/normal/0300-kelpie-dconf.hook.chroot"; then
  fail "hook não compila o banco dconf"
fi

if ! grep -q 'kelpie-menu@kelpieos.local' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "extensão Kelpie não está habilitada no dconf"
fi
if ! grep -q 'kelpie-constellation.png' "$CONFIG/includes.chroot/etc/dconf/db/local.d/00-kelpie"; then
  fail "wallpaper de constelação não está configurado"
fi
if ! grep -q 'kelpie-paw.png' "$CONFIG/includes.chroot/usr/share/gnome-shell/extensions/kelpie-menu@kelpieos.local/extension.js"; then
  fail "ícone oficial da pata não está referenciado no menu"
fi
if ! grep -q '^branding: kelpie$' "$CONFIG/includes.chroot/etc/calamares/settings.conf"; then
  fail "Calamares não está usando a identidade Kelpie"
fi
if ! grep -q '^prompt-install: true$' "$CONFIG/includes.chroot/etc/calamares/settings.conf"; then
  fail "Calamares deve pedir confirmação antes de iniciar a instalação"
fi

if ((ERRORS)); then
  echo "Pré-verificação reprovada: $ERRORS problema(s)." >&2
  exit 1
fi

echo "Pré-verificação estrutural aprovada."
