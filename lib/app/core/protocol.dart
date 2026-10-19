import 'dart:convert';

/// Wire protocol shared with remote_desktop_app/mouse_server.py.
/// One command per line, space separated; free text and binary data are base64.
class Cmd {
  Cmd._();

  static String b64(String text) => base64Encode(utf8.encode(text));
  static String unb64(String data) => utf8.decode(base64Decode(data));

  static String auth(String password) => 'AUTH ${b64(password)}';
  static const ping = 'PING';

  static String move(int dx, int dy) => 'MOVE $dx $dy';
  static String click(RemoteButton b) => switch (b) {
        RemoteButton.left => 'CLICK_LEFT',
        RemoteButton.right => 'CLICK_RIGHT',
        RemoteButton.middle => 'CLICK_MIDDLE',
      };
  static const doubleClick = 'DOUBLE_CLICK';
  static String mouseDown(RemoteButton b) => 'MOUSE_DOWN ${b.name}';
  static String mouseUp(RemoteButton b) => 'MOUSE_UP ${b.name}';

  /// Wheel notches. Positive dy scrolls up.
  static String scroll(int dx, int dy) => 'SCROLL $dx $dy';

  static String type(String text) => 'TYPE ${b64(text)}';

  /// A key or combo such as `enter`, `cmd+shift+t`, `media_play_pause`. Use `plus` for `+`.
  static String key(String combo) => 'KEY $combo';

  static const appList = 'APP_LIST';
  static String appOpen(String name) => 'APP_OPEN ${b64(name)}';

  static String power(PowerAction a) => 'POWER ${a.name}';

  static String clipSet(String text) => 'CLIP_SET ${b64(text)}';
  static const clipGet = 'CLIP_GET';
  static String clipImageSet(List<int> png) => 'CLIP_IMG_SET ${base64Encode(png)}';
  static const clipImageGet = 'CLIP_IMG_GET';
}

enum RemoteButton { left, right, middle }

enum PowerAction { shutdown, restart, sleep, lock }

/// Desktop layout the shortcuts are built for.
enum HostOs { mac, pc }

/// MOVE/SCROLL only carry integers; this keeps the fractional part so slow
/// finger or gyro motion still adds up instead of being truncated to 0.
class DeltaAccumulator {
  double _x = 0, _y = 0;

  /// Adds a delta and returns the whole part ready to send (or null if still < 1).
  (int, int)? add(double dx, double dy) {
    _x += dx;
    _y += dy;
    final ix = _x.truncate(), iy = _y.truncate();
    if (ix == 0 && iy == 0) return null;
    _x -= ix;
    _y -= iy;
    return (ix, iy);
  }

  void reset() => _x = _y = 0;
}
