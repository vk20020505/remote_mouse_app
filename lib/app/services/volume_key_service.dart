import 'dart:async';

import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:get/get.dart';

import '../core/protocol.dart';
import 'connection_service.dart';
import 'settings_service.dart';

/// Turns the phone's physical volume buttons into computer volume up/down while connected.
///
/// The phone volume is parked at the midpoint; each press moves it away, we forward the
/// direction to the computer and put it back, so presses never hit the min/max limit.
class VolumeKeyService extends GetxService {
  static const _mid = 0.5;

  final _conn = Get.find<ConnectionService>();
  final _settings = Get.find<SettingsService>();

  StreamSubscription<double>? _sub;
  double? _restoreTo;

  @override
  void onInit() {
    super.onInit();
    everAll([_conn.state, _settings.volumeKeys], (_) => _sync());
  }

  Future<void> _sync() async {
    final want = _conn.isConnected && _settings.volumeKeys.value;
    try {
      if (want && _sub == null) {
        await _start();
      } else if (!want && _sub != null) {
        await _stop();
      }
    } catch (_) {
      // Not supported on this platform (e.g. desktop builds); the feature simply stays off.
    }
  }

  Future<void> _start() async {
    _restoreTo = await FlutterVolumeController.getVolume();
    await FlutterVolumeController.updateShowSystemUI(false);
    await FlutterVolumeController.setVolume(_mid);
    _sub = FlutterVolumeController.addListener(_onVolume, emitOnStart: false);
  }

  Future<void> _stop() async {
    FlutterVolumeController.removeListener();
    _sub = null;
    await FlutterVolumeController.updateShowSystemUI(true);
    if (_restoreTo != null) await FlutterVolumeController.setVolume(_restoreTo!);
  }

  void _onVolume(double volume) {
    if ((volume - _mid).abs() < 0.01) return; // our own reset
    _conn.send(Cmd.key(volume > _mid ? 'media_volume_up' : 'media_volume_down'));
    FlutterVolumeController.setVolume(_mid);
  }

  @override
  void onClose() {
    if (_sub != null) _stop();
    super.onClose();
  }
}
