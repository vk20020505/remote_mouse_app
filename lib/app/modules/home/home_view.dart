import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/connection_service.dart';
import '../../widgets/remote_background.dart';
import '../../widgets/remote_buttons.dart';
import '../keyboard/keyboard_view.dart';
import '../mouse/mouse_view.dart';
import '../panels/panels_view.dart';
import '../touchpad/touchpad_view.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return RemoteBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          titleSpacing: 16,
          title: Obx(() {
            final connected = controller.state == ConnState.connected;
            final dot = connected ? AppColors.success : AppColors.danger;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceMid.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dot,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: dot.withValues(alpha: 0.6), blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      controller.address,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }),
          actions: [
            IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Settings',
                onPressed: () => Get.toNamed(Routes.settings)),
            IconButton(
                icon: const Icon(Icons.link_off_rounded), tooltip: 'Disconnect', onPressed: controller.disconnect),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const ConnectionBanner(),
              Expanded(
                child: Obx(() => IndexedStack(
                      index: controller.tab.value.index,
                      children: const [TouchpadView(), MouseView(), KeyboardView(), PanelsView()],
                    )),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Obx(() => DecoratedBox(
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.outlineVariant))),
              child: NavigationBar(
                selectedIndex: controller.tab.value.index,
                onDestinationSelected: (i) => controller.tab.value = HomeTab.values[i],
                destinations: const [
                  NavigationDestination(
                      icon: Icon(Icons.touch_app_outlined), selectedIcon: Icon(Icons.touch_app), label: 'Touchpad'),
                  NavigationDestination(
                      icon: Icon(Icons.mouse_outlined), selectedIcon: Icon(Icons.mouse), label: 'Mouse'),
                  NavigationDestination(
                      icon: Icon(Icons.keyboard_outlined), selectedIcon: Icon(Icons.keyboard), label: 'Keyboard'),
                  NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Panels'),
                ],
              ),
            )),
      ),
    );
  }
}
