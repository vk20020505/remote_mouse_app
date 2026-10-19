import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/protocol.dart';

/// Specialty panels, in their default order.
enum PanelType { media, web, apps, power, clipboard }

/// User preferences, persisted with GetStorage. Call `GetStorage.init()` before creating it.
class SettingsService extends GetxService {
  final _box = GetStorage();

  late final host = _persisted('host', '');
  late final port = _persisted('port', 12345);
  late final password = _persisted('password', '');

  late final sensitivity = _persisted('sensitivity', 1.5);
  late final scrollSpeed = _persisted('scrollSpeed', 1.0);
  late final gyroSensitivity = _persisted('gyroSensitivity', 1.0);
  late final naturalScroll = _persisted('naturalScroll', true);
  late final leftHanded = _persisted('leftHanded', false);
  late final volumeKeys = _persisted('volumeKeys', true);
  late final wallpaperPath = _persisted('wallpaperPath', '');

  late final hostOs = _persistedEnum('hostOs', HostOs.values, HostOs.mac);

  late final RxList<PanelType> panelOrder = _loadPanelOrder();

  Rx<T> _persisted<T>(String key, T fallback) {
    final rx = (_box.read<T>(key) ?? fallback).obs;
    ever<T>(rx, (v) => _box.write(key, v));
    return rx;
  }

  Rx<T> _persistedEnum<T extends Enum>(String key, List<T> values, T fallback) {
    final name = _box.read<String>(key);
    final rx = values.firstWhere((v) => v.name == name, orElse: () => fallback).obs;
    ever<T>(rx, (v) => _box.write(key, v.name));
    return rx;
  }

  RxList<PanelType> _loadPanelOrder() {
    final saved = (_box.read<List>('panelOrder') ?? const []).cast<String>();
    final order = [
      for (final name in saved) ...PanelType.values.where((p) => p.name == name),
    ];
    // Panels added in a later version go at the end.
    order.addAll(PanelType.values.where((p) => !order.contains(p)));
    final rx = order.obs;
    ever<List<PanelType>>(rx, (v) => _box.write('panelOrder', v.map((p) => p.name).toList()));
    return rx;
  }

  void movePanel(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final panel = panelOrder.removeAt(oldIndex);
    panelOrder.insert(newIndex, panel);
  }
}
