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
