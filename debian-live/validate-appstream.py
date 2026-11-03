#!/usr/bin/env python3
"""Validate Kelpie AppStream metadata and desktop launch targets."""
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).parent / "config/includes.chroot"
META = ROOT / "usr/share/metainfo"
DESKTOP = ROOT / "usr/share/applications"
EXPECTED = {
    "local.kelpie.Monitor": "kelpie-monitor.desktop",
    "local.kelpie.Update": "kelpie-update.desktop",
    "local.kelpie.Tweaks": "kelpie-tweaks.desktop",
    "local.kelpie.Disk": "kelpie-disk.desktop",
}

def main():
    errors = []
    for app_id, desktop_id in EXPECTED.items():
        path = META / f"{app_id}.metainfo.xml"
        if not path.is_file():
            errors.append(f"Metainfo ausente: {path}")
            continue
        try:
            root = ET.parse(path).getroot()
        except ET.ParseError as exc:
            errors.append(f"XML inválido em {path}: {exc}")
            continue
        if root.tag != "component" or root.get("type") != "desktop-application":
            errors.append(f"Componente AppStream inválido: {path}")
        if root.findtext("id") != app_id:
            errors.append(f"ID divergente em {path}")
        if not root.findtext("name") or not root.findtext("summary"):
            errors.append(f"Nome ou resumo ausente em {path}")
        launchable = root.find("launchable")
        if launchable is None or launchable.get("type") != "desktop-id" or launchable.text != desktop_id:
            errors.append(f"Launchable incorreto em {path}")
        if not (DESKTOP / desktop_id).is_file():
            errors.append(f"Desktop entry ausente: {desktop_id}")
    if errors:
        raise SystemExit("\n".join(errors))
    print(f"OK: {len(EXPECTED)} metadados AppStream e launchers Kelpie validados.")

if __name__ == "__main__":
    main()
