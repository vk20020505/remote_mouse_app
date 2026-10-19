import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../services/connection_service.dart';

enum HomeTab { touchpad, mouse, keyboard, panels }

class HomeController extends GetxController {
  final _conn = Get.find<ConnectionService>();

  final tab = HomeTab.touchpad.obs;

  ConnState get state => _conn.state.value;
  String get address => _conn.address.value;

  Future<void> disconnect() async {
    await _conn.disconnect();
    Get.offAllNamed(Routes.connect);
  }
}
