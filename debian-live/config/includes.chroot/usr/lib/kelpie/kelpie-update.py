#!/usr/bin/env python3
"""Kelpie Update — atualizador gráfico conservador para Debian/apt."""
import os
import subprocess
import threading
from datetime import datetime
from pathlib import Path

import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, GLib

APP_ID = "local.kelpie.Update"
LOG_DIR = Path.home() / ".local" / "state" / "kelpie"
LOG_FILE = LOG_DIR / "update.log"


class KelpieUpdate(Gtk.Application):
    def __init__(self):
        super().__init__(application_id=APP_ID)
        self.busy = False
        self.window = None
        self.status = None
        self.output = None
        self.check_button = None
        self.install_button = None

    def do_activate(self):
        if self.window:
            self.window.present()
            return
        self.window = Gtk.ApplicationWindow(application=self, title="Kelpie Update")
        self.window.set_default_size(720, 500)
        self.window.set_resizable(True)

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        root.set_margin_top(20)
        root.set_margin_bottom(20)
        root.set_margin_start(20)
        root.set_margin_end(20)
        self.window.set_child(root)

        title = Gtk.Label(label="Atualizações do sistema")
        title.add_css_class("title-1")
        title.set_xalign(0)
        root.append(title)

        self.status = Gtk.Label(label="Verifique se existem atualizações disponíveis.")
        self.status.set_xalign(0)
        self.status.set_wrap(True)
        root.append(self.status)

        scroller = Gtk.ScrolledWindow()
        scroller.set_vexpand(True)
        self.output = Gtk.TextView()
        self.output.set_editable(False)
        self.output.set_cursor_visible(False)
        self.output.set_monospace(True)
        self.output.set_wrap_mode(Gtk.WrapMode.WORD_CHAR)
        scroller.set_child(self.output)
        root.append(scroller)

        buttons = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.check_button = Gtk.Button(label="Verificar atualizações")
        self.check_button.connect("clicked", self.on_check)
        buttons.append(self.check_button)
        self.install_button = Gtk.Button(label="Instalar atualizações")
        self.install_button.add_css_class("suggested-action")
        self.install_button.set_sensitive(False)
        self.install_button.connect("clicked", self.on_install)
        buttons.append(self.install_button)
        root.append(buttons)

        note = Gtk.Label(
            label="O Kelpie Update usa APT. A autenticação administrativa é solicitada "
                  "somente quando necessário. Atualizações que exigem remoção de pacotes "
                  "ou mudança de distribuição não são executadas por este aplicativo."
        )
        note.set_wrap(True)
        note.set_xalign(0)
        note.add_css_class("dim-label")
        root.append(note)
        self.window.present()

    def append_output(self, text):
        buffer = self.output.get_buffer()
        end = buffer.get_end_iter()
        buffer.insert(end, text)
        mark = buffer.create_mark(None, buffer.get_end_iter(), False)
        self.output.scroll_to_mark(mark, 0.0, False, 0.0, 1.0)

    def set_busy(self, busy, message):
        self.busy = busy
        self.status.set_text(message)
        self.check_button.set_sensitive(not busy)
        self.install_button.set_sensitive(not busy and self.install_button.get_sensitive())

    def run_task(self, title, commands, on_success=None):
        if self.busy:
            return
        self.busy = True
        self.check_button.set_sensitive(False)
        self.install_button.set_sensitive(False)
        self.status.set_text(title)
        self.append_output("\n\n=== " + title + " ===\n")

        def worker():
            LOG_DIR.mkdir(parents=True, exist_ok=True)
            all_output = []
            success = True
            for command, env_extra in commands:
                env = os.environ.copy()
                env.update(env_extra)
                try:
                    proc = subprocess.Popen(
                        command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                        text=True, bufsize=1, env=env
                    )
                    for line in proc.stdout:
                        all_output.append(line)
                        GLib.idle_add(self.append_output, line)
                    code = proc.wait()
                    if code != 0:
                        success = False
                        all_output.append(f"\nComando terminou com código {code}.\n")
                        GLib.idle_add(self.append_output, f"\nComando terminou com código {code}.\n")
                        break
                except Exception as exc:
                    success = False
                    message = f"Falha ao iniciar comando: {exc}\n"
                    all_output.append(message)
                    GLib.idle_add(self.append_output, message)
                    break
            try:
                with LOG_FILE.open("a", encoding="utf-8") as log:
                    log.write(f"\n[{datetime.now().isoformat(timespec='seconds')}] {title}\n")
                    log.writelines(all_output)
            except OSError as exc:
                GLib.idle_add(self.append_output, f"Não foi possível gravar o log: {exc}\n")
            GLib.idle_add(self.finish_task, success, title, on_success)

        threading.Thread(target=worker, daemon=True).start()

    def finish_task(self, success, title, on_success):
        self.busy = False
        self.check_button.set_sensitive(True)
        if success:
            self.status.set_text("Concluído: " + title)
            if on_success:
                on_success()
        else:
            self.status.set_text("A operação falhou. Consulte a saída e o log.")
        return GLib.SOURCE_REMOVE

    def on_check(self, _button):
        self.install_button.set_sensitive(False)
        self.run_task(
            "Verificando atualizações",
            [
                (["pkexec", "/usr/bin/apt-get", "update"], {"DEBIAN_FRONTEND": "noninteractive"}),
                (["/usr/bin/apt-get", "-s", "upgrade"], {"LC_ALL": "C"}),
            ],
            self.enable_install
        )

    def enable_install(self):
        self.install_button.set_sensitive(True)
        self.status.set_text("Verificação concluída. Revise a saída antes de instalar.")

    def on_install(self, _button):
        dialog = Gtk.AlertDialog()
        dialog.set_message("Instalar atualizações disponíveis?")
        dialog.set_detail(
            "O APT instalará atualizações padrão. O sistema poderá solicitar sua senha "
            "administrativa. Salve seus trabalhos antes de continuar."
        )
        dialog.set_buttons(["Cancelar", "Instalar"])
        dialog.set_cancel_button(0)
        dialog.set_default_button(0)
        dialog.choose(self.window, None, self.on_install_response)

    def on_install_response(self, dialog, result):
        try:
            choice = dialog.choose_finish(result)
        except Exception:
            return
        if choice != 1:
            return
        self.run_task(
            "Instalando atualizações",
            [
                (["pkexec", "/usr/bin/apt-get", "-y", "upgrade"],
                 {"DEBIAN_FRONTEND": "noninteractive"})
            ]
        )


if __name__ == "__main__":
    KelpieUpdate().run()
