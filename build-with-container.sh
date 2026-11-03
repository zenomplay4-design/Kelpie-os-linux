#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "$0")" && pwd)"
ENGINE=""
if command -v docker >/dev/null 2>&1; then ENGINE=docker; elif command -v podman >/dev/null 2>&1; then ENGINE=podman; fi
if [[ -z "$ENGINE" ]]; then echo 'Instale Docker ou Podman.' >&2; exit 1; fi
mkdir -p "$ROOT/dist"
"$ENGINE" run --rm --privileged -v "$ROOT/debian-live:/src:ro" -v "$ROOT/dist:/out" debian:trixie bash -Eeuc '
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends live-build debootstrap xorriso squashfs-tools dosfstools grub-pc-bin grub-efi-amd64-bin mtools isolinux syslinux-common ca-certificates file
mkdir -p /build && cp -a /src/config /build/config && cd /build
chmod +x config/hooks/normal/*.hook.chroot
lb config --distribution trixie --architectures amd64 --binary-images iso-hybrid --debian-installer live --archive-areas "main contrib non-free non-free-firmware" --bootappend-live "boot=live components username=kelpie hostname=kelpie-os locales=pt_BR.UTF-8 keyboard-layouts=br" --iso-application "Kelpie OS Linux" --iso-publisher "Kelpie OS Project" --iso-volume "KELPIE_OS_LINUX" --apt-recommends true
lb build
ISO="$(find /build -maxdepth 1 -type f -name "live-image-amd64.hybrid.iso" -print -quit)"
test -n "$ISO" && test -s "$ISO"
xorriso -indev "$ISO" -report_el_torito plain
install -m 0644 "$ISO" /out/kelpie-os-linux-debian13-amd64.iso
cd /out && sha256sum kelpie-os-linux-debian13-amd64.iso > SHA256SUMS
'
