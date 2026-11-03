#!/usr/bin/env python3
"""Validate AppStream metadata and desktop launch targets for Kelpie apps."""
from pathlib import Path
import configparser
import xml.etree.ElementTree as ET

ROOT = Path(__file__).parent / "config/includes.chroot"
META = ROOT / "usr/share/metainfo"
DESKTOP = ROOT / "usr/share/applications"
LIB = ROOT / "usr/lib/kelpie"
EXPECTED = {
    "local.kelpie.Monitor": ("kelpie-monitor.desktop", "kelpie-monitor.py"),
    "local.kelpie.Update": ("kelpie-update.desktop", "kelpie-update.py"),
    "local.kelpie.Tweaks": ("kelpie-tweaks.desktop", "kelpie-tweaks.py"),
    "local.kelpie.Disk": ("kelpie-disk.desktop", "kelpie-disk.py"),
}

def main():
    errors = []
    for app_id, (desktop_id, script_name) in EXPECTED.items():
        meta_path = META / f"{app_id}.metainfo.xml"
        desktop_path = DESKTOP / desktop_id
        script_path = LIB / script_name
        try:
            root = ET.parse(meta_path).getroot()
        except (OSError, ET.ParseError) as exc:
            errors.append(f"Metadado inválido/ausente {meta_path}: {exc}")
            continue
        if root.tag != "component" or root.get("type") != "desktop-application":
            errors.append(f"Tipo AppStream incorreto: {meta_path}")
        if root.findtext("id") != app_id:
            errors.append(f"ID divergente: {meta_path}")
        if not root.findtext("name") or not root.findtext("summary"):
            errors.append(f"Nome/resumo ausente: {meta_path}")
        if not root.findall("summary[@xml:lang='pt_BR']"):
            errors.append(f"Resumo pt_BR ausente: {meta_path}")
        launchable = root.find("launchable")
        if launchable is None or launchable.get("type") != "desktop-id" or launchable.text != desktop_id:
            errors.append(f"Launchable incorreto: {meta_path}")
        if not desktop_path.is_file():
            errors.append(f"Desktop entry ausente: {desktop_path}")
        else:
            parser = configparser.ConfigParser(interpolation=None)
            try:
                parser.read(desktop_path, encoding="utf-8")
                entry = parser["Desktop Entry"]
                if entry.get("Type") != "Application":
                    errors.append(f"Type não é Application: {desktop_path}")
                if not entry.get("Name") or not entry.get("Exec"):
                    errors.append(f"Name/Exec ausente: {desktop_path}")
                if script_name not in entry.get("Exec", ""):
                    errors.append(f"Exec não aponta para {script_name}: {desktop_path}")
            except (KeyError, configparser.Error) as exc:
                errors.append(f"Desktop entry inválido {desktop_path}: {exc}")
        if not script_path.is_file():
            errors.append(f"Aplicativo ausente: {script_path}")
    if errors:
        raise SystemExit("\n".join(errors))
    print(f"OK: {len(EXPECTED)} metadados, traduções, launchers e scripts Kelpie validados.")

if __name__ == "__main__":
    main()
