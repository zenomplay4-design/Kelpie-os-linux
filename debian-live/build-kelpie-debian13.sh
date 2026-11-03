#!/usr/bin/env bash
set -Eeuo pipefail
if [[ "$(. /etc/os-release; printf '%s' "${VERSION_CODENAME:-}")" != "trixie" ]]; then echo 'Use Debian 13 Trixie.' >&2; exit 1; fi
if [[ "$(dpkg --print-architecture)" != amd64 || $EUID -eq 0 ]]; then echo 'Execute como usuário normal em Debian 13 amd64.' >&2; exit 1; fi
command -v sudo >/dev/null || exit 1
FREE_KB=$(df -Pk "$HOME" | awk 'NR==2 {print $4}')
(( FREE_KB >= 25*1024*1024 )) || { echo 'São necessários 25 GB livres.' >&2; exit 1; }
SRC="$(cd -- "$(dirname -- "$0")" && pwd)"; WORK="$HOME/kelpie-os-build"; OUT="$HOME/kelpie-os-build-output"
mkdir -p "$WORK" "$OUT"; sudo apt-get update
sudo apt-get install -y live-build debootstrap xorriso squashfs-tools dosfstools grub-pc-bin grub-efi-amd64-bin mtools isolinux syslinux-common
sudo rm -rf "$WORK/config"; cp -a "$SRC/config" "$WORK/config"; cd "$WORK"
sudo lb config --distribution trixie --architectures amd64 --binary-images iso-hybrid --debian-installer live --archive-areas 'main contrib non-free non-free-firmware' --bootappend-live 'boot=live components username=kelpie hostname=kelpie-os locales=pt_BR.UTF-8 keyboard-layouts=br' --iso-application 'Kelpie OS Linux' --iso-publisher 'Kelpie OS Project' --iso-volume KELPIE_OS_LINUX --apt-recommends true
sudo lb build
ISO=$(sudo find "$WORK" -maxdepth 1 -type f -name 'live-image-amd64.hybrid.iso' -print -quit); test -s "$ISO"
sudo install -m 0644 "$ISO" "$OUT/kelpie-os-linux-debian13-amd64.iso"; cd "$OUT"; sha256sum kelpie-os-linux-debian13-amd64.iso | tee SHA256SUMS
