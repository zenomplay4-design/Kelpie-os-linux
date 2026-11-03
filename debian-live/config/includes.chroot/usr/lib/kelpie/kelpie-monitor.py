#!/usr/bin/python3
"""Kelpie Monitor: lightweight GTK4 system monitor for Kelpie OS."""
from __future__ import annotations

import shutil
import subprocess
from typing import Optional

import psutil
import gi

gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, GLib


class KelpieMonitor(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="local.kelpie.Monitor")
        self.window = None
        self.cpu_bar = None
        self.ram_bar = None
        self.cpu_value = None
        self.ram_value = None
        self.gpu_value = None
        self.temp_value = None
        self.disk_value = None
        self.process_list = None
        psutil.cpu_percent(interval=None)

    def do_activate(self):
        if self.window:
            self.window.present()
            return

        self.window = Gtk.ApplicationWindow(
            application=self,
            title="Kelpie Monitor",
            default_width=820,
            default_height=640,
        )
        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        root.set_margin_top(18)
        root.set_margin_bottom(18)
        root.set_margin_start(18)
        root.set_margin_end(18)
        self.window.set_child(root)

        heading = Gtk.Label(label="Kelpie Monitor")
        heading.add_css_class("title-1")
        heading.set_halign(Gtk.Align.START)
        root.append(heading)

        subtitle = Gtk.Label(label="Monitoramento de hardware e processos")
        subtitle.add_css_class("dim-label")
        subtitle.set_halign(Gtk.Align.START)
        root.append(subtitle)

        grid = Gtk.Grid(column_spacing=18, row_spacing=14)
        root.append(grid)

        self.cpu_value = self._metric(grid, "Processador", 0, 0)
        self.ram_value = self._metric(grid, "Memória RAM", 1, 0)
        self.gpu_value = self._metric(grid, "Placa de vídeo", 0, 1)
        self.temp_value = self._metric(grid, "Temperaturas", 1, 1)
        self.disk_value = self._metric(grid, "Armazenamento", 0, 2)

        process_heading = Gtk.Label(label="Processos em execução")
        process_heading.add_css_class("title-3")
        process_heading.set_halign(Gtk.Align.START)
        root.append(process_heading)

        scroll = Gtk.ScrolledWindow()
        scroll.set_vexpand(True)
        scroll.set_min_content_height(220)
        root.append(scroll)

        self.process_list = Gtk.ListBox()
        self.process_list.set_selection_mode(Gtk.SelectionMode.NONE)
        self.process_list.add_css_class("boxed-list")
        scroll.set_child(self.process_list)

        self.refresh()
        GLib.timeout_add_seconds(2, self.refresh)
        self.window.present()

    def _metric(self, grid, title: str, column: int, row: int):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        box.add_css_class("card")
        box.set_margin_top(4)
        box.set_margin_bottom(4)
        box.set_margin_start(4)
        box.set_margin_end(4)
        label = Gtk.Label(label=title)
        label.add_css_class("heading")
        label.set_halign(Gtk.Align.START)
        value = Gtk.Label(label="Coletando dados…")
        value.set_wrap(True)
        value.set_halign(Gtk.Align.START)
        box.append(label)
        box.append(value)
        grid.attach(box, column, row, 1, 1)
        return value

    @staticmethod
    def _gpu_status() -> str:
        if not shutil.which("nvidia-smi"):
            return "NVIDIA: ferramenta/driver proprietário não detectado"
        try:
            result = subprocess.run(
                [
                    "nvidia-smi",
                    "--query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu",
                    "--format=csv,noheader,nounits",
                ],
                capture_output=True,
                text=True,
                timeout=2,
                check=False,
            )
            if result.returncode == 0 and result.stdout.strip():
                return result.stdout.strip().replace(", ", " · ")
            return "GPU NVIDIA detectada, mas sem leitura disponível"
        except (OSError, subprocess.TimeoutExpired):
            return "Não foi possível consultar a GPU NVIDIA"

    @staticmethod
    def _temperatures() -> str:
        try:
            readings = psutil.sensors_temperatures(fahrenheit=False)
            values = []
            for group in readings.values():
                for item in group:
                    if item.current is not None:
                        values.append(f"{item.label or item.name}: {item.current:.0f} °C")
            return " · ".join(values[:4]) if values else "Sensores não disponíveis"
        except (AttributeError, NotImplementedError, OSError):
            return "Sensores não disponíveis"

    def refresh(self):
        if not self.window:
            return GLib.SOURCE_REMOVE

        try:
            cpu = psutil.cpu_percent(interval=None)
            memory = psutil.virtual_memory()
            disk = psutil.disk_usage("/")
            self.cpu_value.set_text(f"{cpu:.0f}% de uso · {psutil.cpu_count(logical=True) or '?'} threads")
            self.ram_value.set_text(
                f"{memory.percent:.0f}% usado · {memory.used / (1024 ** 3):.1f} / "
                f"{memory.total / (1024 ** 3):.1f} GB"
            )
            self.gpu_value.set_text(self._gpu_status())
            self.temp_value.set_text(self._temperatures())
            self.disk_value.set_text(
                f"{disk.percent:.0f}% usado · {disk.used / (1024 ** 3):.1f} / "
                f"{disk.total / (1024 ** 3):.1f} GB"
            )
            self._refresh_processes()
        except (psutil.Error, OSError, RuntimeError) as error:
            self.gpu_value.set_text(f"Leitura parcial: {error}")
        return GLib.SOURCE_CONTINUE

    def _refresh_processes(self):
        child = self.process_list.get_first_child()
        while child:
            next_child = child.get_next_sibling()
            self.process_list.remove(child)
            child = next_child

        processes = []
        for proc in psutil.process_iter(["pid", "name", "memory_percent", "cpu_percent"]):
            try:
                info = proc.info
                processes.append(
                    (
                        float(info.get("cpu_percent") or 0),
                        int(info.get("pid") or 0),
                        str(info.get("name") or "Processo"),
                        float(info.get("memory_percent") or 0),
                    )
                )
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                continue

        for cpu, pid, name, memory in sorted(processes, reverse=True)[:12]:
            row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
            row.set_margin_top(7)
            row.set_margin_bottom(7)
            row.set_margin_start(10)
            row.set_margin_end(10)
            process_label = Gtk.Label(label=f"{name}  (PID {pid})")
            process_label.set_halign(Gtk.Align.START)
            process_label.set_hexpand(True)
            stats = Gtk.Label(label=f"CPU {cpu:.1f}% · RAM {memory:.1f}%")
            stats.add_css_class("dim-label")
            row.append(process_label)
            row.append(stats)
            self.process_list.append(row)


if __name__ == "__main__":
    app = KelpieMonitor()
    raise SystemExit(app.run(None))
