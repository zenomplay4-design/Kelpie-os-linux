#!/usr/bin/env python3
"""Kelpie Disk — inventário de armazenamento somente leitura."""
import json
import shutil
import subprocess

from kelpie_utils import format_size

import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, GLib

APP_ID = "local.kelpie.Disk"
LSBLK_COLUMNS = "NAME,PATH,SIZE,TYPE,FSTYPE,LABEL,UUID,MOUNTPOINTS,MODEL,TRAN,RM,RO"




class KelpieDisk(Gtk.Application):
    def __init__(self):
        super().__init__(application_id=APP_ID)
        self.window = None
        self.list_box = None
        self.status = None
        self.summary = None
        self.refresh_button = None

    def do_activate(self):
        if self.window:
            self.window.present()
            self.refresh()
            return

        self.window = Gtk.ApplicationWindow(application=self, title="Kelpie Disk")
        self.window.set_default_size(760, 580)
        self.window.set_resizable(True)

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        root.set_margin_top(20)
        root.set_margin_bottom(20)
        root.set_margin_start(20)
        root.set_margin_end(20)
        self.window.set_child(root)

        heading = Gtk.Label(label="Discos e partições")
        heading.add_css_class("title-1")
        heading.set_xalign(0)
        root.append(heading)

        description = Gtk.Label(
            label="Inventário de armazenamento do computador. Esta versão não altera discos nem partições."
        )
        description.set_wrap(True)
        description.set_xalign(0)
        description.add_css_class("dim-label")
        root.append(description)

        toolbar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.refresh_button = Gtk.Button(label="Atualizar lista")
        self.refresh_button.connect("clicked", self.on_refresh)
        toolbar.append(self.refresh_button)
        root.append(toolbar)

        self.summary = Gtk.Label(label='Resumo do armazenamento: aguardando leitura…')
        self.summary.set_xalign(0)
        self.summary.add_css_class('dim-label')
        root.append(self.summary)

        scroller = Gtk.ScrolledWindow()
        scroller.set_vexpand(True)
        self.list_box = Gtk.ListBox()
        self.list_box.set_selection_mode(Gtk.SelectionMode.NONE)
        self.list_box.add_css_class("boxed-list")
        scroller.set_child(self.list_box)
        root.append(scroller)

        warning = Gtk.Label(
            label="Proteção de dados: nenhum botão de formatar, apagar, redimensionar ou montar está disponível nesta versão."
        )
        warning.set_wrap(True)
        warning.set_xalign(0)
        warning.add_css_class("warning")
        root.append(warning)

        self.status = Gtk.Label(label="Preparando leitura dos dispositivos…")
        self.status.set_xalign(0)
        self.status.add_css_class("dim-label")
        root.append(self.status)

        self.window.present()
        self.refresh()

    def on_refresh(self, _button):
        self.refresh()

    def clear_rows(self):
        child = self.list_box.get_first_child()
        while child:
            next_child = child.get_next_sibling()
            self.list_box.remove(child)
            child = next_child

    def refresh(self):
        if not self.window:
            return GLib.SOURCE_REMOVE
        self.refresh_button.set_sensitive(False)
        self.status.set_text("Lendo informações dos discos…")
        self.clear_rows()
        GLib.idle_add(self.load_devices)
        return GLib.SOURCE_REMOVE

    def load_devices(self):
        try:
            executable = shutil.which("lsblk")
            if not executable:
                raise RuntimeError("O utilitário lsblk não está instalado.")
            result = subprocess.run(
                [executable, "--json", "--bytes", "--output", LSBLK_COLUMNS],
                capture_output=True,
                text=True,
                timeout=8,
                check=False,
            )
            if result.returncode != 0:
                detail = result.stderr.strip() or f"lsblk retornou código {result.returncode}"
                raise RuntimeError(detail)
            payload = json.loads(result.stdout)
            devices = payload.get("blockdevices", [])
            from kelpie_utils import summarize_block_devices
            summary = summarize_block_devices(devices)
            self.summary.set_text(f"{summary['disks']} disco(s) · {summary['partitions']} partição(ões) · {summary['mounted']} montado(s) · {summary['readonly']} somente leitura")
            if not devices:
                self.add_empty("Nenhum dispositivo de armazenamento foi encontrado.")
            for device in devices:
                self.add_device(device, depth=0)
            self.status.set_text(f"{len(devices)} dispositivo(s) principal(is) encontrado(s).")
        except (OSError, subprocess.SubprocessError, json.JSONDecodeError, RuntimeError) as error:
            self.add_empty(f"Não foi possível listar os discos: {error}")
            self.status.set_text("Leitura não concluída.")
        finally:
            self.refresh_button.set_sensitive(True)
        return GLib.SOURCE_REMOVE

    def add_empty(self, message):
        label = Gtk.Label(label=message)
        label.set_wrap(True)
        label.set_margin_top(12)
        label.set_margin_bottom(12)
        label.set_margin_start(12)
        label.set_margin_end(12)
        self.list_box.append(label)

    def add_device(self, device, depth):
        name = str(device.get("name") or "Dispositivo")
        path = str(device.get("path") or ("/dev/" + name))
        kind = str(device.get("type") or "desconhecido")
        model = str(device.get("model") or "").strip()
        size = format_size(device.get("size"))
        fstype = str(device.get("fstype") or "sem sistema de arquivos")
        label_text = str(device.get("label") or "")
        mountpoints = device.get("mountpoints") or []
        if isinstance(mountpoints, str):
            mountpoints = [mountpoints]
        mounts = ", ".join(str(point) for point in mountpoints if point) or "não montado"
        transport = str(device.get("tran") or "")
        removable = "removível" if str(device.get("rm")) == "1" else "fixo"
        readonly = " · somente leitura" if str(device.get("ro")) == "1" else ""
        title_text = f"{'  ' * depth}{name} — {size}"
        details = [path, kind, fstype, mounts, removable + readonly]
        if model:
            details.append(model)
        if transport:
            details.append(transport.upper())
        if label_text:
            details.append("Rótulo: " + label_text)
        if device.get("uuid"):
            details.append("UUID: " + str(device["uuid"]))

        row = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        row.set_margin_top(9)
        row.set_margin_bottom(9)
        row.set_margin_start(12 + depth * 14)
        row.set_margin_end(12)
        title = Gtk.Label(label=title_text)
        title.set_xalign(0)
        title.add_css_class("heading")
        detail = Gtk.Label(label=" · ".join(details))
        detail.set_xalign(0)
        detail.set_wrap(True)
        detail.add_css_class("dim-label")
        row.append(title)
        row.append(detail)
        self.list_box.append(row)

        for child in device.get("children") or []:
            self.add_device(child, depth + 1)


if __name__ == "__main__":
    raise SystemExit(KelpieDisk().run(None))
