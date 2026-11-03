#!/usr/bin/env bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive

# Use the complete Debian 13 archive components, including firmware and NVIDIA.
mkdir -p /etc/apt/sources.list.d
cat > /etc/apt/sources.list.d/debian.sources <<'EOF'
Types: deb
URIs: http://deb.debian.org/debian
Suites: trixie trixie-updates
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://deb.debian.org/debian-security
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

apt-get update
apt-get install -y --no-install-recommends \
  live-build debootstrap xorriso squashfs-tools dosfstools \
  grub-pc-bin grub-efi-amd64-bin mtools isolinux syslinux-common \
  ca-certificates file librsvg2-bin

# Fail early if any requested package is unavailable or dependencies conflict.
bash /src/validate-packages.sh /src/config/package-lists/kelpie.list.chroot

mkdir -p /build /out
cp -a /src/config /build/config
cd /build

mkdir -p \
  config/includes.chroot/usr/share/backgrounds/kelpie \
  config/includes.chroot/usr/share/pixmaps \
  config/includes.chroot/usr/share/icons/hicolor/128x128/apps \
  config/includes.chroot/usr/share/icons/hicolor/512x512/apps

# Official menu/boot mark: a simple white paw on transparent background.
cat > /tmp/paw.svg <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512"><g fill="#fff"><ellipse cx="128" cy="164" rx="54" ry="72"/><ellipse cx="256" cy="112" rx="54" ry="72"/><ellipse cx="384" cy="164" rx="54" ry="72"/><ellipse cx="448" cy="286" rx="48" ry="64"/><path d="M256 220c-94 0-178 105-178 185 0 52 40 78 91 78 35 0 57-17 87-17s52 17 87 17c51 0 91-26 91-78 0-80-84-185-178-185z"/></g></svg>
SVG
rsvg-convert -w 512 -h 512 /tmp/paw.svg > config/includes.chroot/usr/share/pixmaps/kelpie-paw.png
cp config/includes.chroot/usr/share/pixmaps/kelpie-paw.png config/includes.chroot/usr/share/pixmaps/kelpie-os-logo.png
cp config/includes.chroot/usr/share/pixmaps/kelpie-paw.png config/includes.chroot/usr/share/icons/hicolor/128x128/apps/kelpie-os.png
cp config/includes.chroot/usr/share/pixmaps/kelpie-paw.png config/includes.chroot/usr/share/icons/hicolor/512x512/apps/kelpie-os.png

# Temporary constellation wallpaper used until the approved final artwork is added.
cat > /tmp/wallpaper.svg <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080">
<defs><radialGradient id="sky"><stop stop-color="#173b70"/><stop offset="1" stop-color="#040918"/></radialGradient><filter id="glow"><feGaussianBlur stdDeviation="8"/></filter></defs>
<rect width="1920" height="1080" fill="url(#sky)"/>
<g fill="#cfe4ff" opacity=".7">
<circle cx="120" cy="140" r="2"/><circle cx="260" cy="330" r="2"/><circle cx="420" cy="170" r="3"/><circle cx="610" cy="260" r="2"/><circle cx="790" cy="120" r="2"/><circle cx="980" cy="230" r="2"/><circle cx="1170" cy="120" r="2"/><circle cx="1390" cy="270" r="3"/><circle cx="1600" cy="140" r="2"/><circle cx="1780" cy="350" r="2"/><circle cx="170" cy="760" r="2"/><circle cx="430" cy="900" r="2"/><circle cx="680" cy="780" r="2"/><circle cx="1210" cy="900" r="2"/><circle cx="1510" cy="790" r="2"/><circle cx="1780" cy="930" r="2"/>
</g>
<g fill="none" stroke="#a9cfff" stroke-width="5" stroke-linecap="round" stroke-linejoin="round" opacity=".85">
<path d="M760 650 L690 520 L710 350 L820 220 L930 330 L1010 350 L1110 300 L1220 360 L1260 470 L1190 560 L1130 700 L1160 820 L1080 850 L990 800 L930 690 L850 700 L820 850 L730 850 L760 650"/>
<path d="M710 350 L610 300 L560 390 L690 520 M930 330 L1010 350 L1050 470 L970 510 L880 470 L930 330 M1190 560 L1300 600 L1370 540"/>
<path d="M850 700 L930 690 L990 800 M820 850 L730 850"/>
</g>
<g fill="#e0eeff">
<circle cx="760" cy="650" r="11"/><circle cx="690" cy="520" r="9"/><circle cx="710" cy="350" r="10"/><circle cx="820" cy="220" r="12"/><circle cx="930" cy="330" r="10"/><circle cx="1010" cy="350" r="9"/><circle cx="1110" cy="300" r="11"/><circle cx="1220" cy="360" r="10"/><circle cx="1260" cy="470" r="11"/><circle cx="1190" cy="560" r="9"/><circle cx="1130" cy="700" r="10"/><circle cx="1160" cy="820" r="9"/><circle cx="1080" cy="850" r="10"/><circle cx="990" cy="800" r="9"/><circle cx="930" cy="690" r="10"/><circle cx="850" cy="700" r="9"/><circle cx="820" cy="850" r="10"/><circle cx="730" cy="850" r="9"/><circle cx="610" cy="300" r="9"/><circle cx="560" cy="390" r="10"/><circle cx="1050" cy="470" r="8"/><circle cx="970" cy="510" r="8"/><circle cx="880" cy="470" r="8"/><circle cx="1300" cy="600" r="8"/><circle cx="1370" cy="540" r="8"/>
</g>
<g fill="#fff" filter="url(#glow)" opacity=".45"><circle cx="820" cy="220" r="18"/><circle cx="1110" cy="300" r="18"/><circle cx="1260" cy="470" r="18"/></g>
</svg>
SVG
rsvg-convert -w 1920 -h 1080 /tmp/wallpaper.svg > config/includes.chroot/usr/share/backgrounds/kelpie/kelpie-constellation.png

chmod +x config/hooks/normal/*.hook.chroot
lb config \
  --distribution trixie \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --debian-installer live \
  --archive-areas "main contrib non-free non-free-firmware" \
  --bootappend-live "boot=live components username=kelpie hostname=kelpie-os locales=pt_BR.UTF-8 keyboard-layouts=br" \
  --iso-application "Kelpie OS Linux V3" \
  --iso-publisher "Kelpie OS Project" \
  --iso-volume "KELPIE_OS_V3" \
  --apt-recommends true

lb build

ISO="$(find /build -maxdepth 1 -type f -name "live-image-amd64.hybrid.iso" -print -quit)"
test -n "$ISO" && test -s "$ISO"
xorriso -indev "$ISO" -report_el_torito plain
install -m 0644 "$ISO" /out/kelpie-os-linux-v3-amd64.iso
cd /out
sha256sum kelpie-os-linux-v3-amd64.iso | tee SHA256SUMS
file kelpie-os-linux-v3-amd64.iso
