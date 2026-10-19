import 'package:get/get.dart';

import '../modules/connect/connect_controller.dart';
import '../modules/connect/connect_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/panels/apps_panel.dart';
import '../modules/panels/clipboard_panel.dart';
import '../modules/panels/media_panel.dart';
import '../modules/panels/power_panel.dart';
import '../modules/panels/web_panel.dart';
import '../modules/settings/settings_controller.dart';
import '../modules/settings/settings_view.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
      name: Routes.connect,
      page: () => const ConnectView(),
      binding: BindingsBuilder.put(() => ConnectController()),
    ),
    GetPage(name: Routes.home, page: () => const HomeView(), binding: HomeBinding()),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder.put(() => SettingsController()),
    ),
    GetPage(name: Routes.mediaPanel, page: () => const MediaPanel()),
    GetPage(name: Routes.webPanel, page: () => const WebPanel()),
    GetPage(
      name: Routes.appsPanel,
      page: () => const AppsPanel(),
      binding: BindingsBuilder.put(() => AppsController()),
    ),
    GetPage(name: Routes.powerPanel, page: () => const PowerPanel()),
    GetPage(
      name: Routes.clipboardPanel,
      page: () => const ClipboardPanel(),
      binding: BindingsBuilder.put(() => ClipboardController()),
    ),
  ];
}
