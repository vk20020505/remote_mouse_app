import 'package:get/get.dart';

import '../keyboard/keyboard_controller.dart';
import '../mouse/mouse_controller.dart';
import '../touchpad/touchpad_controller.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
    Get.put(MouseController());
    Get.put(TouchpadController());
    Get.put(KeyboardController());
  }
}
