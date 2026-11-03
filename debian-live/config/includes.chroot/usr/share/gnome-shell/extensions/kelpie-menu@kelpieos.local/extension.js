import St from 'gi://St';
import Gio from 'gi://Gio';
import Shell from 'gi://Shell';
import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';

export default class KelpieMenuExtension extends Extension {
  enable() {
    this.loadStylesheet();
    this.button = new St.Button({
      style_class: 'panel-button kelpie-menu-button',
      reactive: true,
      can_focus: true,
      track_hover: true,
      accessible_name: 'Menu principal Kelpie OS',
    });

    this.icon = new St.Icon({
      gicon: Gio.icon_new_for_string('/usr/share/pixmaps/kelpie-paw.png'),
      icon_size: 18,
      style_class: 'system-status-icon',
    });
    this.button.set_child(this.icon);

    this.menu = new PopupMenu.PopupMenu(this.button, 0.0, St.Side.TOP);
    Main.uiGroup.add_child(this.menu.actor);
    this.menuManager = new PopupMenu.PopupMenuManager(this);
    this.menuManager.addMenu(this.menu);

    this._addAction('Abrir visão geral', () => Main.overview.show());
    this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
    this._addApp('Arquivos', 'org.gnome.Nautilus.desktop');
    this._addApp('Navegador', 'firefox-esr.desktop');
    this._addApp('Central de aplicativos', 'org.gnome.Software.desktop');
    this._addApp('Monitor do sistema', 'org.gnome.SystemMonitor.desktop');
    this._addApp('Discos', 'org.gnome.DiskUtility.desktop');
    this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
    this._addApp('Configurações', 'org.gnome.Settings.desktop');
    this._addAction('Bloquear sessão', () => Main.screenShield.lock(true));

    this.button.connect('clicked', () => this.menu.toggle());
    Main.panel.addToStatusArea(this.uuid, this.button, 0, 'left');
  }

  _addAction(label, callback) {
    const item = new PopupMenu.PopupMenuItem(label);
    item.connect('activate', callback);
    this.menu.addMenuItem(item);
  }

  _addApp(label, desktopId) {
    const item = new PopupMenu.PopupMenuItem(label);
    item.connect('activate', () => {
      const app = Shell.AppSystem.get_default().lookup_app(desktopId);
      if (app)
        app.activate();
      else
        Main.notify('Kelpie OS', `Aplicativo não encontrado: ${label}`);
    });
    this.menu.addMenuItem(item);
  }

  disable() {
    this.menu?.destroy();
    this.menu = null;
    this.menuManager = null;
    this.button?.destroy();
    this.button = null;
    this.icon = null;
    this.unloadStylesheet();
  }
}
