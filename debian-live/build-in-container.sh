#!/usr/bin/env bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends live-build debootstrap xorriso squashfs-tools dosfstools grub-pc-bin grub-efi-amd64-bin mtools isolinux syslinux-common ca-certificates file librsvg2-bin
mkdir -p /build
cp -a /src/config /build/config
cd /build
mkdir -p config/includes.chroot/usr/share/backgrounds/kelpie config/includes.chroot/usr/share/pixmaps config/includes.chroot/usr/share/icons/hicolor/128x128/apps config/includes.chroot/usr/share/icons/hicolor/512x512/apps
cat > /tmp/paw.svg <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512"><g fill="#fff"><ellipse cx="128" cy="164" rx="54" ry="72"/><ellipse cx="256" cy="112" rx="54" ry="72"/><ellipse cx="384" cy="164" rx="54" ry="72"/><ellipse cx="448" cy="286" rx="48" ry="64"/><path d="M256 220c-94 0-178 105-178 185 0 52 40 78 91 78 35 0 57-17 87-17s52 17 87 17c51 0 91-26 91-78 0-80-84-185-178-185z"/></g></svg>
SVG
rsvg-convert -w 512 -h 512 /tmp/paw.svg > config/includes.chroot/usr/share/pixmaps/kelpie-paw.png
cp config/includes.chroot/usr/share/pixmaps/kelpie-paw.png config/includes.chroot/usr/share/pixmaps/kelpie-os-logo.png
cp config/includes.chroot/usr/share/pixmaps/kelpie-paw.png config/includes.chroot/usr/share/icons/hicolor/128x128/apps/kelpie-os.png
cp config/includes.chroot/usr/share/pixmaps/kelpie-paw.png config/includes.chroot/usr/share/icons/hicolor/512x512/apps/kelpie-os.png
cat > /tmp/wallpaper.svg <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080"><defs><radialGradient id="g"><stop stop-color="#173c70"/><stop offset="1" stop-color="#050b1c"/></radialGradient></defs><rect width="100%" height="100%" fill="url(#g)"/><g fill="#d7e8ff" opacity=".8"><circle cx="160" cy="130" r="2"/><circle cx="430" cy="260" r="2"/><circle cx="780" cy="120" r="2"/><circle cx="1120" cy="230" r="2"/><circle cx="1600" cy="140" r="2"/><circle cx="1750" cy="700" r="2"/><circle cx="300" cy="820" r="2"/><circle cx="900" cy="900" r="2"/><circle cx="1350" cy="820" r="2"/><circle cx="1520" cy="400" r="2"/></g><g fill="none" stroke="#a9cfff" stroke-width="5" opacity=".8"><path d="M730 510 L820 390 L930 440 L1040 370 L1160 450 L1260 560 L1150 660 L1010 700 L880 660 L780 590 Z"/><path d="M820 390 L780 300 L900 340 L930 440 M1040 370 L1100 270 L1160 450"/></g><g fill="#d9eaff"><circle cx="730" cy="510" r="9"/><circle cx="820" cy="390" r="9"/><circle cx="930" cy="440" r="9"/><circle cx="1040" cy="370" r="9"/><circle cx="1160" cy="450" r="9"/><circle cx="1260" cy="560" r="9"/><circle cx="1150" cy="660" r="9"/><circle cx="1010" cy="700" r="9"/><circle cx="880" cy="660" r="9"/><circle cx="780" cy="590" r="9"/><circle cx="780" cy="300" r="9"/><circle cx="900" cy="340" r="9"/><circle cx="1100" cy="270" r="9"/></g></svg>
SVG
rsvg-convert -w 1920 -h 1080 /tmp/wallpaper.svg > config/includes.chroot/usr/share/backgrounds/kelpie/kelpie-wolf.png
sed -i "s/kelpie-wolf.jpg/kelpie-wolf.png/g" config/includes.chroot/etc/dconf/db/local.d/00-kelpie
chmod +x config/hooks/normal/*.hook.chroot
lb config --distribution trixie --architectures amd64 --binary-images iso-hybrid --debian-installer live --archive-areas "main contrib non-free non-free-firmware" --bootappend-live "boot=live components username=kelpie hostname=kelpie-os locales=pt_BR.UTF-8 keyboard-layouts=br" --iso-application "Kelpie OS Linux" --iso-publisher "Kelpie OS Project" --iso-volume "KELPIE_OS_LINUX" --apt-recommends true
lb build
ISO="$(find /build -maxdepth 1 -type f -name "live-image-amd64.hybrid.iso" -print -quit)"
test -n "$ISO" && test -s "$ISO"
xorriso -indev "$ISO" -report_el_torito plain
install -m 0644 "$ISO" /out/kelpie-os-linux-debian13-amd64.iso
cd /out
sha256sum kelpie-os-linux-debian13-amd64.iso > SHA256SUMS
file kelpie-os-linux-debian13-amd64.iso
