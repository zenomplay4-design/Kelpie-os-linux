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


def calculate_io_rates(previous, current, now):
    """Return read/write bytes per second from cumulative disk counters."""
    try:
        read_bytes, write_bytes = int(current[0]), int(current[1])
        if previous is None:
            return None
        previous_time, previous_read, previous_write = previous
        elapsed = float(now) - float(previous_time)
        previous_read, previous_write = int(previous_read), int(previous_write)
        if elapsed <= 0 or read_bytes < previous_read or write_bytes < previous_write:
            return None
        return ((read_bytes - previous_read) / elapsed, (write_bytes - previous_write) / elapsed)
    except (TypeError, ValueError, IndexError, OverflowError):
        return None


def summarize_block_devices(devices):
    """Summarize lsblk JSON recursively without changing device state."""
    result = {"disks": 0, "partitions": 0, "mounted": 0, "readonly": 0}
    def visit(items):
        for item in items or []:
            kind = str(item.get("type") or "").lower()
            if kind == "disk":
                result["disks"] += 1
            elif kind == "part":
                result["partitions"] += 1
            mounts = item.get("mountpoints") or []
            if isinstance(mounts, str):
                mounts = [mounts]
            if any(mounts):
                result["mounted"] += 1
            if str(item.get("ro")) == "1":
                result["readonly"] += 1
            visit(item.get("children"))
    visit(devices)
    return result
