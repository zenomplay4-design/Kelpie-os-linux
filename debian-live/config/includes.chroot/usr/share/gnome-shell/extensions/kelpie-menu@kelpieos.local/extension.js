import St from 'gi://St';
import Gio from 'gi://Gio';
import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

export default class KelpieMenuExtension extends Extension {
  enable() {
    this.button = new St.Button({
      style_class: 'panel-button kelpie-menu-button',
      reactive: true,
      can_focus: true,
      track_hover: true,
      accessible_name: 'Kelpie OS — menu principal',
    });
    this.icon = new St.Icon({
      gicon: Gio.icon_new_for_string('/usr/share/pixmaps/kelpie-paw.png'),
      icon_size: 18,
      style_class: 'system-status-icon',
    });
    this.button.set_child(this.icon);
    this.button.connect('clicked', () => Main.overview.toggle());
    Main.panel.addToStatusArea(this.uuid, this.button, 0, 'left');
  }

  disable() {
    this.button?.destroy();
    this.button = null;
    this.icon = null;
  }
}
