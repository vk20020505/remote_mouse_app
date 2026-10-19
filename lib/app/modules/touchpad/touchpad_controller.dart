import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/protocol.dart';
import '../../core/hotkeys.dart';
import '../../services/connection_service.dart';
import '../../services/settings_service.dart';

enum _TwoFingerMode { undecided, scroll, pinch }

/// Magic-Trackpad-style gestures from raw pointer events:
///
/// * 1 finger: move · tap = left click · long-press then drag = click-and-drag
/// * 2 fingers: scroll (both axes) · pinch = zoom · tap = right click
/// * 3 fingers: swipe left/right = switch desktop · up = Mission Control · down = app windows ·
///   tap = middle click
class TouchpadController extends GetxController {
  static const _tapSlop = 12.0;
  static const _tapMaxDuration = Duration(milliseconds: 250);
  static const _longPress = Duration(milliseconds: 450);
  static const _swipeDistance = 60.0;
  static const _pinchStep = 40.0;

  final _conn = Get.find<ConnectionService>();
  final _settings = Get.find<SettingsService>();

  /// Shown in the pad so the user can see what was recognised.
  final hint = ''.obs;
  final dragging = false.obs;

  final _pointers = <int, Offset>{};
  final _starts = <int, Offset>{};
  final _move = DeltaAccumulator();
  final _scroll = DeltaAccumulator();

  int _maxPointers = 0;
  DateTime _downAt = DateTime.now();
  double _travel = 0;
  bool _swipeFired = false;
  Timer? _longPressTimer;
  Timer? _hintTimer;

  _TwoFingerMode _twoMode = _TwoFingerMode.undecided;
  double _pinchBase = 0;
  double _twoFingerPan = 0;
  Offset? _threeStart;

  void onDown(PointerDownEvent e) {
    if (_pointers.isEmpty) {
      _maxPointers = 0;
      _downAt = DateTime.now();
      _travel = 0;
      _swipeFired = false;
      _move.reset();
      _scroll.reset();
    }
    _pointers[e.pointer] = e.localPosition;
    _starts[e.pointer] = e.localPosition;
    _maxPointers = max(_maxPointers, _pointers.length);
    _onFingerCountChanged();

    _longPressTimer?.cancel();
    if (_pointers.length == 1) {
      _longPressTimer = Timer(_longPress, _startDrag);
    }
  }

  void onMove(PointerMoveEvent e) {
    final prev = _pointers[e.pointer];
    if (prev == null) return;
    _pointers[e.pointer] = e.localPosition;
    _travel = max(_travel, (e.localPosition - _starts[e.pointer]!).distance);
    if (_travel > _tapSlop) _longPressTimer?.cancel();

    final delta = e.localPosition - prev;
    switch (_pointers.length) {
      case 1:
        // After a multi-finger gesture, the last finger lifting shouldn't jerk the cursor.
        if (_maxPointers == 1 || dragging.value) _moveCursor(delta);
      case 2:
        _twoFingers(delta);
      default:
        _threeFingers();
    }
  }

  void onUp(PointerEvent e, {bool cancelled = false}) {
    if (_pointers.remove(e.pointer) == null) return;
    _starts.remove(e.pointer);
    _longPressTimer?.cancel();
    _onFingerCountChanged();
    if (_pointers.isNotEmpty) return;

    if (dragging.value) {
      _conn.send(Cmd.mouseUp(RemoteButton.left));
      dragging.value = false;
      return;
    }
    final quick = DateTime.now().difference(_downAt) < _tapMaxDuration;
    if (!cancelled && quick && _travel < _tapSlop && !_swipeFired) {
      switch (_maxPointers) {
        case 1:
          _click(RemoteButton.left, 'Left click');
        case 2:
          _click(RemoteButton.right, 'Right click');
        default:
          _click(RemoteButton.middle, 'Middle click');
      }
    }
  }

  void _onFingerCountChanged() {
    _twoMode = _TwoFingerMode.undecided;
    _twoFingerPan = 0;
    _pinchBase = _pointers.length == 2 ? _fingerSpread() : 0;
    _threeStart = _pointers.length >= 3 ? _centroid() : null;
  }

  void _startDrag() {
    if (_pointers.length != 1 || _travel > _tapSlop) return;
    HapticFeedback.mediumImpact();
    _conn.send(Cmd.mouseDown(RemoteButton.left));
    dragging.value = true;
    _flash('Dragging');
  }

  void _moveCursor(Offset delta) {
    // Light acceleration: slow movements stay precise, fast flicks cover the screen.
    final speed = delta.distance;
    final k = _settings.sensitivity.value * (1 + min(speed / 10, 2.0));
    final out = _move.add(delta.dx * k, delta.dy * k);
    if (out != null) _conn.send(Cmd.move(out.$1, out.$2));
  }

  void _twoFingers(Offset delta) {
    if (_twoMode == _TwoFingerMode.undecided) {
      _twoFingerPan += delta.distance / 2;
      final spreadChange = (_fingerSpread() - _pinchBase).abs();
      if (spreadChange > 24 && spreadChange > _twoFingerPan * 1.5) {
        _twoMode = _TwoFingerMode.pinch;
      } else if (_twoFingerPan > 8) {
        _twoMode = _TwoFingerMode.scroll;
      } else {
        return;
      }
    }

    if (_twoMode == _TwoFingerMode.pinch) {
      final spread = _fingerSpread();
      if ((spread - _pinchBase).abs() >= _pinchStep) {
        final zoomIn = spread > _pinchBase;
        _key(zoomIn ? Hotkeys.zoomIn : Hotkeys.zoomOut);
        _flash(zoomIn ? 'Zoom in' : 'Zoom out');
        _pinchBase = spread;
      }
      return;
    }

    // Each finger's move event shifts the centroid by half its delta.
    final natural = _settings.naturalScroll.value ? 1.0 : -1.0;
    final k = _settings.scrollSpeed.value / 12 * natural;
    // macOS treats positive horizontal wheel as "left", Windows as "right".
    final xSign = _settings.hostOs.value == HostOs.mac ? 1.0 : -1.0;
    final out = _scroll.add(delta.dx / 2 * k * xSign, delta.dy / 2 * k);
    if (out != null) _conn.send(Cmd.scroll(out.$1, out.$2));
  }

  void _threeFingers() {
    final start = _threeStart;
    if (_swipeFired || start == null) return;
    final d = _centroid() - start;
    if (d.distance < _swipeDistance) return;
    _swipeFired = true;
    HapticFeedback.selectionClick();
    if (d.dx.abs() > d.dy.abs()) {
      // Swiping left reveals the desktop on the right, as on a Mac trackpad.
      _key(d.dx < 0 ? Hotkeys.desktopRight : Hotkeys.desktopLeft);
      _flash(d.dx < 0 ? 'Next desktop' : 'Previous desktop');
    } else {
      _key(d.dy < 0 ? Hotkeys.missionControl : Hotkeys.appExpose);
      _flash(d.dy < 0 ? 'Mission Control' : 'App windows');
    }
  }

  void _click(RemoteButton button, String label) {
    _conn.send(Cmd.click(button));
    _flash(label);
  }

  void _key(Hotkey s) => _conn.send(Cmd.key(s.comboFor(_settings.hostOs.value)));

  Offset _centroid() {
    var sum = Offset.zero;
    for (final p in _pointers.values) {
      sum += p;
    }
    return sum / _pointers.length.toDouble();
  }

  double _fingerSpread() {
    final pts = _pointers.values.toList();
    return pts.length < 2 ? 0 : (pts[0] - pts[1]).distance;
  }

  void _flash(String text) {
    hint.value = text;
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(milliseconds: 700), () => hint.value = '');
  }

  @override
  void onClose() {
    _longPressTimer?.cancel();
    _hintTimer?.cancel();
    if (dragging.value) _conn.send(Cmd.mouseUp(RemoteButton.left));
    super.onClose();
  }
}
