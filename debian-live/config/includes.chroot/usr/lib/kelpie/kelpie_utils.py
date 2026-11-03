"""Pure helper functions shared by Kelpie desktop utilities."""


def has_upgradable_packages(apt_simulation_output):
    """Return True only when APT simulation lists at least one install action."""
    return any(line.startswith("Inst ") for line in apt_simulation_output.splitlines())


def format_size(value):
    """Format a byte count using decimal units, matching lsblk's display."""
    try:
        amount = float(value)
    except (TypeError, ValueError):
        return "Tamanho desconhecido"
    if amount < 0:
        return "Tamanho desconhecido"
    units = ("B", "KB", "MB", "GB", "TB", "PB")
    for unit in units:
        if amount < 1000 or unit == units[-1]:
            return f"{amount:.0f} {unit}" if unit == "B" else f"{amount:.1f} {unit}"
        amount /= 1000
    return f"{amount:.1f} PB"


def read_nouveau_gpu_stats(drm_root="/sys/class/drm"):
    """Read GPU busy percentage and temperature from Nouveau sysfs when exposed."""
    from pathlib import Path
    root = Path(drm_root)
    readings = []
    for device in sorted(root.glob("card[0-9]*/device")):
        values = []
        busy = device / "gpu_busy_percent"
        try:
            if busy.is_file():
                value = float(busy.read_text(encoding="ascii").strip())
                if 0 <= value <= 100:
                    values.append(f"GPU {value:.0f}%")
        except (OSError, ValueError):
            pass
        for sensor in sorted((device / "hwmon").glob("hwmon*/temp1_input"))[:1]:
            try:
                temp = int(sensor.read_text(encoding="ascii").strip())
                if -40000 <= temp <= 150000:
                    values.append(f"{temp / 1000:.0f} °C")
            except (OSError, ValueError):
                pass
        if values:
            readings.append(" · ".join(values))
    return " · ".join(readings[:2]) if readings else "Métricas Nouveau indisponíveis"


def read_cpu_model(cpuinfo_path="/proc/cpuinfo"):
    """Return the reported CPU model, with a safe fallback."""
    from pathlib import Path
    try:
        for line in Path(cpuinfo_path).read_text(encoding="utf-8", errors="replace").splitlines():
            key, separator, value = line.partition(":")
            if separator and key.strip().lower() in ("model name", "hardware") and value.strip():
                return value.strip()
    except OSError:
        pass
    return "Modelo não identificado"
