import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../services/connection_service.dart';
import '../../services/settings_service.dart';

class ConnectController extends GetxController {
  final _conn = Get.find<ConnectionService>();
  final _settings = Get.find<SettingsService>();

  late final hostField = TextEditingController(text: _settings.host.value);
  late final portField = TextEditingController(text: '${_settings.port.value}');
  late final passwordField = TextEditingController(text: _settings.password.value);

  final scanning = false.obs;
  final found = <DiscoveredHost>[].obs;

  ConnState get state => _conn.state.value;
  String? get error => _conn.lastError.value;

  @override
  void onReady() {
    super.onReady();
    // Jump straight back to the last computer; otherwise look for one on the network.
    if (_settings.host.value.isNotEmpty) {
      connect();
    } else {
      scan();
    }
  }

  Future<void> scan() async {
    if (scanning.value) return;
    scanning.value = true;
    try {
      found.assignAll(await _conn.discover());
    } catch (_) {
      found.clear();
    } finally {
      scanning.value = false;
    }
  }

  void pick(DiscoveredHost host) {
    hostField.text = host.address;
    portField.text = '${host.port}';
    connect();
  }

  Future<void> connect() async {
    final host = hostField.text.trim();
    final port = int.tryParse(portField.text.trim());
    if (host.isEmpty || port == null) {
      _conn.lastError.value = 'Enter the IP address and port shown in the desktop app';
      return;
    }
    if (await _conn.connect(host, port, password: passwordField.text)) {
      Get.offAllNamed(Routes.home);
    }
  }

  @override
  void onClose() {
    hostField.dispose();
    portField.dispose();
    passwordField.dispose();
    super.onClose();
  }
}
