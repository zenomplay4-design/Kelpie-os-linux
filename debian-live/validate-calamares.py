#!/usr/bin/env python3
"""Static validation of Kelpie's Calamares sequence against Debian 13 modules."""
from pathlib import Path
import sys
import yaml

ROOT = Path(__file__).resolve().parent
SETTINGS = ROOT / "config/includes.chroot/etc/calamares/settings.conf"

# Module names present in Debian Trixie's Calamares 3.3.14 configuration.
VIEW_MODULES = {"welcome", "locale", "keyboard", "partition", "users", "summary", "finished"}
JOB_MODULES = {
    "partition", "mount", "unpackfs", "machineid", "locale", "keyboard",
    "localecfg", "fstab", "initcpiocfg", "initcpio", "users",
    "displaymanager", "networkcfg", "hwclock", "services-systemd",
    "initramfs", "bootloader", "umount",
}

def fail(message):
    print(f"ERRO Calamares: {message}", file=sys.stderr)
    raise SystemExit(1)

if not SETTINGS.is_file():
    fail(f"arquivo ausente: {SETTINGS}")

try:
    data = yaml.safe_load(SETTINGS.read_text(encoding="utf-8"))
except Exception as exc:
    fail(f"YAML inválido: {exc}")

if not isinstance(data, dict):
    fail("settings.conf precisa conter um mapa YAML")
if data.get("modules-search") != ["local"]:
    fail("modules-search deve ser [ local ]")
if data.get("branding") != "kelpie":
    fail("branding deve apontar para kelpie")
if data.get("prompt-install") is not True:
    fail("prompt-install deve permanecer true")
if data.get("dont-chroot") is not False:
    fail("dont-chroot deve ser false para instalação normal")

sequence = data.get("sequence")
if not isinstance(sequence, list) or len(sequence) != 3:
    fail("a sequência deve ter show, exec e show")

expected_phases = ("show", "exec", "show")
for index, (phase, expected) in enumerate(zip(sequence, expected_phases)):
    if not isinstance(phase, dict) or list(phase) != [expected]:
        fail(f"fase {index + 1} deve ser {expected}")
    modules = phase[expected]
    if not isinstance(modules, list) or not modules:
        fail(f"fase {expected} vazia ou inválida")
    if len(modules) != len(set(modules)):
        fail(f"módulo duplicado na fase {expected}")
    allowed = VIEW_MODULES if expected == "show" else JOB_MODULES
    unknown = sorted(set(modules) - allowed)
    if unknown:
        fail(f"módulos não reconhecidos para Debian Trixie: {', '.join(unknown)}")

shown = set(sequence[0]["show"])
executed = set(sequence[1]["exec"])
for module in ("partition", "locale", "keyboard", "users"):
    if module not in shown or module not in executed:
        fail(f"módulo de interface {module} precisa aparecer em show e exec")
if sequence[2]["show"] != ["finished"]:
    fail("a última tela deve ser finished")
for module in ("mount", "unpackfs", "fstab", "initramfs", "bootloader", "umount"):
    if module not in executed:
        fail(f"etapa essencial ausente: {module}")

print("SUCESSO: sequência Calamares válida para o conjunto de módulos Debian Trixie.")
