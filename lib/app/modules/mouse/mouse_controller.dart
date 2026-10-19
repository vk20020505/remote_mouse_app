import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/protocol.dart';
import '../../services/connection_service.dart';
import '../../services/settings_service.dart';
import '../home/home_controller.dart';

class MouseController extends GetxController {
  /// Gyro rate (rad/s) below this is hand tremor and ignored.
  static const _gyroDeadZone = 0.03;
  static const _gyroScale = 18.0;

  final _conn = Get.find<ConnectionService>();
  final _settings = Get.find<SettingsService>();

  final gyro = false.obs;
  final gyroAvailable = true.obs;

  final _move = DeltaAccumulator();
  final _wheel = DeltaAccumulator();
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  @override
  void onInit() {
    super.onInit();
    ever(gyro, (on) => on ? _startGyro() : _stopGyro());
    // Never leave the gyro steering the cursor from a tab the user can't see.
    ever(Get.find<HomeController>().tab, (tab) {
      if (tab != HomeTab.mouse) gyro.value = false;
    });
    ever(_conn.state, (s) {
      if (s != ConnState.connected) gyro.value = false;
    });
  }

  void onPadMove(DragUpdateDetails d) {
    final k = _settings.sensitivity.value;
    final out = _move.add(d.delta.dx * k, d.delta.dy * k);
    if (out != null) _conn.send(Cmd.move(out.$1, out.$2));
  }

  void onPadTap() => _conn.send(Cmd.click(RemoteButton.left));

  /// The wheel strip behaves like a physical wheel: rolling down scrolls down.
  void onWheel(DragUpdateDetails d) {
    final out = _wheel.add(0, -d.delta.dy * _settings.scrollSpeed.value / 12);
    if (out != null) _conn.send(Cmd.scroll(0, out.$2));
  }

  void onWheelTap() => _conn.send(Cmd.click(RemoteButton.middle));

  void _startGyro() {
    _move.reset();
    _gyroSub = gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      (e) {
        // Phone held flat, screen up: yaw (z) moves left/right, pitch (x) moves up/down.
        double filter(double v) => v.abs() < _gyroDeadZone ? 0 : v;
        final k = _settings.gyroSensitivity.value * _gyroScale;
        final out = _move.add(-filter(e.z) * k, -filter(e.x) * k);
        if (out != null) _conn.send(Cmd.move(out.$1, out.$2));
      },
      onError: (_) {
        gyroAvailable.value = false;
        gyro.value = false;
      },
      cancelOnError: true,
    );
  }

  void _stopGyro() {
    _gyroSub?.cancel();
    _gyroSub = null;
  }

  @override
  void onClose() {
    _stopGyro();
    super.onClose();
  }
}
