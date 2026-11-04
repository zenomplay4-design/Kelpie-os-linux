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

Types: deb
URIs: http://deb.debian.org/debian
Suites: trixie-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

apt-get update
apt-get install -y --no-install-recommends \
  live-build debootstrap xorriso squashfs-tools dosfstools \
  grub-pc-bin grub-efi-amd64-bin mtools isolinux syslinux-common \
  ca-certificates file librsvg2-bin python3-yaml

# Validate structure and configuration after installing the YAML parser.
bash /src/preflight.sh
python3 /src/validate-appstream.py

# Fail early if any requested package is unavailable or dependencies conflict.
bash /src/validate-packages.sh

mkdir -p /build /out
cp -a /src/config /build/config

# The source tree is intentionally mounted read-only by CI. Generate live-build
# archive configuration in the writable build copy, never under /src.
mkdir -p /build/config/archives
cat > /build/config/archives/trixie-backports.list.chroot <<'EOF'
deb http://deb.debian.org/debian trixie-backports main contrib non-free non-free-firmware
EOF
cat > /build/config/archives/trixie-backports.pref.chroot <<'EOF'
# Keep the NVIDIA driver stack and kernel ABI internally consistent:
# their exact-version dependencies (including linux-base) must come from backports.
Package: nvidia-* libnvidia-* xserver-xorg-video-nvidia linux-*
Pin: release n=trixie-backports
Pin-Priority: 990

# All other backports remain opt-in; do not upgrade the whole live system.
Package: *
Pin: release n=trixie-backports
Pin-Priority: 100
EOF

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
cp /tmp/paw.svg config/includes.chroot/usr/share/pixmaps/kelpie-paw.svg
rsvg-convert -w 512 -h 512 /tmp/paw.svg > config/includes.chroot/usr/share/pixmaps/kelpie-paw.png
cp config/includes.chroot/usr/share/pixmaps/kelpie-paw.png config/includes.chroot/usr/share/pixmaps/kelpie-os-logo.png
cp config/includes.chroot/usr/share/pixmaps/kelpie-paw.png config/includes.chroot/usr/share/icons/hicolor/128x128/apps/kelpie-os.png
cp config/includes.chroot/usr/share/pixmaps/kelpie-paw.png config/includes.chroot/usr/share/icons/hicolor/512x512/apps/kelpie-os.png
mkdir -p config/includes.chroot/etc/calamares/branding/kelpie
cp config/includes.chroot/usr/share/pixmaps/kelpie-paw.png config/includes.chroot/etc/calamares/branding/kelpie/kelpie-paw.png
# Calamares branding.desc references the SVG asset, so ship it beside the branding file.
cp config/includes.chroot/usr/share/pixmaps/kelpie-paw.svg config/includes.chroot/etc/calamares/branding/kelpie/kelpie-paw.svg

# Render the approved 16:9 Kelpie dog-constellation artwork.
test -s /src/assets/kelpie-constellation.svg
rsvg-convert -w 1920 -h 1080 /src/assets/kelpie-constellation.svg > config/includes.chroot/usr/share/backgrounds/kelpie/kelpie-constellation.png

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
bash /src/validate-iso.sh /out/kelpie-os-linux-v3-amd64.iso
