#!/usr/bin/env python3
"""Kelpie Tweaks — ajustes GNOME reversíveis para aparência e acessibilidade."""
import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, Gio

APP_ID = "local.kelpie.Tweaks"


class KelpieTweaks(Gtk.Application):
    def __init__(self):
        super().__init__(application_id=APP_ID)
        self.settings = Gio.Settings.new("org.gnome.desktop.interface")
        self.a11y = Gio.Settings.new("org.gnome.desktop.a11y.interface")

    def do_activate(self):
        window = Gtk.ApplicationWindow(application=self, title="Kelpie Tweaks")
        window.set_default_size(560, 500)
        window.set_resizable(False)

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        root.set_margin_top(22)
        root.set_margin_bottom(22)
        root.set_margin_start(22)
        root.set_margin_end(22)
        window.set_child(root)

        heading = Gtk.Label(label="Personalização do Kelpie")
        heading.add_css_class("title-1")
        heading.set_xalign(0)
        root.append(heading)

        subtitle = Gtk.Label(label="Ajustes seguros da sessão GNOME. As alterações são aplicadas ao usuário atual.")
        subtitle.set_xalign(0)
        subtitle.set_wrap(True)
        subtitle.add_css_class("dim-label")
        root.append(subtitle)

        self.theme = Gtk.DropDown.new_from_strings(["Padrão do sistema", "Escuro", "Claro"])
        self.add_row(root, "Aparência", "Escolha o esquema de cores.", self.theme)
        color = self.settings.get_string("color-scheme")
        self.theme.set_selected({"default": 0, "prefer-dark": 1, "prefer-light": 2}.get(color, 0))
        self.theme.connect("notify::selected", self.on_theme_changed)

        self.animations = Gtk.Switch(active=self.settings.get_boolean("enable-animations"))
        self.animations.set_valign(Gtk.Align.CENTER)
        self.add_row(root, "Animações", "Desative para reduzir movimento e efeitos.", self.animations)
        self.animations.connect("notify::active", self.on_animations_changed)

        self.contrast = Gtk.Switch(active=self.a11y.get_boolean("high-contrast"))
        self.contrast.set_valign(Gtk.Align.CENTER)
        self.add_row(root, "Alto contraste", "Aumenta a distinção visual dos elementos.", self.contrast)
        self.contrast.connect("notify::active", self.on_contrast_changed)

        scale_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        self.scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0.8, 1.5, 0.05)
        self.scale.set_hexpand(True)
        self.scale.set_digits(2)
        self.scale.set_value(self.settings.get_double("text-scaling-factor"))
        scale_box.append(self.scale)
        self.scale_value = Gtk.Label(label=f'{self.scale.get_value():.2f}×')
        scale_box.append(self.scale_value)
        self.add_row(root, "Tamanho do texto", "Ajuste a escala das fontes da interface.", scale_box)
        self.scale.connect("value-changed", self.on_scale_changed)

        root.append(Gtk.Separator(orientation=Gtk.Orientation.HORIZONTAL))
        reset = Gtk.Button(label="Restaurar padrões")
        reset.connect("clicked", self.on_reset)
        root.append(reset)

        self.status = Gtk.Label(label="As alterações são salvas automaticamente.")
        self.status.set_xalign(0)
        self.status.add_css_class("dim-label")
        root.append(self.status)
        window.present()

    def add_row(self, parent, title, description, control):
        row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=16)
        row.set_margin_top(4)
        row.set_margin_bottom(4)
        labels = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        labels.set_hexpand(True)
        name = Gtk.Label(label=title)
        name.set_xalign(0)
        name.add_css_class("heading")
        detail = Gtk.Label(label=description)
        detail.set_xalign(0)
        detail.set_wrap(True)
        detail.add_css_class("dim-label")
        labels.append(name)
        labels.append(detail)
        row.append(labels)
        row.append(control)
        parent.append(row)

    def notify_saved(self, message):
        self.status.set_text(message)

    def on_theme_changed(self, *_):
        values = ["default", "prefer-dark", "prefer-light"]
        self.settings.set_string("color-scheme", values[self.theme.get_selected()])
        self.notify_saved("Aparência atualizada.")

    def on_animations_changed(self, *_):
        self.settings.set_boolean("enable-animations", self.animations.get_active())
        self.notify_saved("Preferência de animações atualizada.")

    def on_contrast_changed(self, *_):
        self.a11y.set_boolean("high-contrast", self.contrast.get_active())
        self.notify_saved("Preferência de contraste atualizada.")

    def on_scale_changed(self, *_):
        value = round(self.scale.get_value() * 20) / 20
        self.scale_value.set_text(f"{value:.2f}×")
        self.settings.set_double("text-scaling-factor", value)
        self.notify_saved("Escala do texto atualizada.")

    def on_reset(self, *_):
        self.settings.set_string("color-scheme", "default")
        self.settings.set_boolean("enable-animations", True)
        self.settings.set_double("text-scaling-factor", 1.0)
        self.a11y.set_boolean("high-contrast", False)
        self.theme.set_selected(0)
        self.animations.set_active(True)
        self.contrast.set_active(False)
        self.scale.set_value(1.0)
        self.notify_saved("Padrões restaurados.")


if __name__ == "__main__":
    KelpieTweaks().run()
