import 'protocol.dart';

/// A named shortcut with a combo per desktop layout.
class Hotkey {
  const Hotkey(this.label, this.mac, [String? pc]) : pc = pc ?? mac;

  final String label;
  final String mac;
  final String pc;

  String comboFor(HostOs os) => os == HostOs.mac ? mac : pc;
}

/// Hotkeys grouped for the keyboard and panel screens. `cmd` is the Windows key on a PC.
class Hotkeys {
  Hotkeys._();

  static const system = [
    Hotkey('Copy', 'cmd+c', 'ctrl+c'),
    Hotkey('Paste', 'cmd+v', 'ctrl+v'),
    Hotkey('Cut', 'cmd+x', 'ctrl+x'),
    Hotkey('Undo', 'cmd+z', 'ctrl+z'),
    Hotkey('Redo', 'cmd+shift+z', 'ctrl+y'),
    Hotkey('Select all', 'cmd+a', 'ctrl+a'),
    Hotkey('Save', 'cmd+s', 'ctrl+s'),
    Hotkey('Find', 'cmd+f', 'ctrl+f'),
    Hotkey('Close window', 'cmd+w', 'ctrl+w'),
    Hotkey('Quit app', 'cmd+q', 'alt+f4'),
    Hotkey('Switch app', 'cmd+tab', 'alt+tab'),
    Hotkey('Search', 'cmd+space', 'cmd+s'),
    Hotkey('Screenshot', 'cmd+shift+4', 'cmd+shift+s'),
    Hotkey('Show desktop', 'f11', 'cmd+d'),
    Hotkey('Mission control', 'ctrl+up', 'cmd+tab'),
    Hotkey('Lock screen', 'ctrl+cmd+q', 'cmd+l'),
  ];

  static const keys = [
    Hotkey('Esc', 'esc'),
    Hotkey('Tab', 'tab'),
    Hotkey('Enter', 'enter'),
    Hotkey('⌫', 'backspace'),
    Hotkey('Del', 'delete'),
    Hotkey('Home', 'home'),
    Hotkey('End', 'end'),
    Hotkey('PgUp', 'page_up'),
    Hotkey('PgDn', 'page_down'),
    Hotkey('←', 'left'),
    Hotkey('↑', 'up'),
    Hotkey('↓', 'down'),
    Hotkey('→', 'right'),
  ];

  static final functionKeys = [for (var i = 1; i <= 12; i++) Hotkey('F$i', 'f$i')];

  // Browser shortcuts work the same in Chrome, Firefox and Opera.
  static const web = [
    Hotkey('Back', 'cmd+[', 'alt+left'),
    Hotkey('Forward', 'cmd+]', 'alt+right'),
    Hotkey('Reload', 'cmd+r', 'f5'),
    Hotkey('New tab', 'cmd+t', 'ctrl+t'),
    Hotkey('Close tab', 'cmd+w', 'ctrl+w'),
    Hotkey('Reopen tab', 'cmd+shift+t', 'ctrl+shift+t'),
    Hotkey('Prev tab', 'ctrl+shift+tab'),
    Hotkey('Next tab', 'ctrl+tab'),
    Hotkey('Address bar', 'cmd+l', 'ctrl+l'),
    Hotkey('Zoom in', 'cmd+=', 'ctrl+='),
    Hotkey('Zoom out', 'cmd+-', 'ctrl+-'),
    Hotkey('Full screen', 'ctrl+cmd+f', 'f11'),
    Hotkey('New window', 'cmd+n', 'ctrl+n'),
    Hotkey('Incognito', 'cmd+shift+n', 'ctrl+shift+n'),
    Hotkey('Bookmark', 'cmd+d', 'ctrl+d'),
    Hotkey('History', 'cmd+y', 'ctrl+h'),
  ];

  // Trackpad gestures.
  static const desktopLeft = Hotkey('Desktop left', 'ctrl+left', 'ctrl+cmd+left');
  static const desktopRight = Hotkey('Desktop right', 'ctrl+right', 'ctrl+cmd+right');
  static const missionControl = Hotkey('Mission control', 'ctrl+up', 'cmd+tab');
  static const appExpose = Hotkey('App windows', 'ctrl+down', 'cmd+d');
  static const zoomIn = Hotkey('Zoom in', 'cmd+=', 'ctrl+=');
  static const zoomOut = Hotkey('Zoom out', 'cmd+-', 'ctrl+-');
}
