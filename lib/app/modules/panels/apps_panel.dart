import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/hotkeys.dart';
import '../../core/protocol.dart';
import '../../services/connection_service.dart';
import '../../widgets/remote_background.dart';
import '../../widgets/remote_buttons.dart';

class AppsController extends GetxController {
  final _conn = Get.find<ConnectionService>();

  final apps = <String>[].obs;
  final loading = false.obs;
  final launchField = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    refreshApps();
  }

  Future<void> refreshApps() async {
    loading.value = true;
    final reply = await _conn.request(Cmd.appList, 'APPS ', timeout: const Duration(seconds: 20));
    loading.value = false;
    if (reply == null) return;
    apps.assignAll((jsonDecode(Cmd.unb64(reply.substring(5))) as List).cast<String>());
  }

  void open(String name) {
    if (name.trim().isEmpty) return;
    _conn.send(Cmd.appOpen(name.trim()));
  }

  @override
  void onClose() {
    launchField.dispose();
    super.onClose();
  }
}

class AppsPanel extends GetView<AppsController> {
  const AppsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return PanelScaffold(
      title: 'App Switcher',
      actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: controller.refreshApps)],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionLabel('Switch'),
          const HotkeyGrid(shortcuts: [
            Hotkey('Next app', 'cmd+tab', 'alt+tab'),
            Hotkey('Previous app', 'cmd+shift+tab', 'alt+shift+tab'),
            Hotkey('Next window', 'cmd+`', 'alt+esc'),
            Hotkeys.missionControl,
            Hotkey('Minimize', 'cmd+m', 'cmd+down'),
            Hotkey('Quit app', 'cmd+q', 'alt+f4'),
          ]),
          const SizedBox(height: 24),
          const SectionLabel('Launch'),
          TextField(
            controller: controller.launchField,
            textInputAction: TextInputAction.go,
            onSubmitted: (v) {
              controller.open(v);
              controller.launchField.clear();
            },
            decoration: const InputDecoration(
              labelText: 'Launch app by name (e.g. Safari, notepad)',
              prefixIcon: Icon(Icons.rocket_launch_outlined),
            ),
          ),
          const SizedBox(height: 24),
          const SectionLabel('Open apps — tap to switch'),
          Obx(() {
            if (controller.loading.value) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (controller.apps.isEmpty) {
              return const Text(
                'No apps reported. On a Mac, allow the desktop app to control "System Events" '
                '(System Settings › Privacy & Security › Automation), then refresh.',
              );
            }
            return Column(
              children: [
                for (final app in controller.apps)
                  Card(
                    child: ListTile(
                      leading: const GradientIcon(Icons.window_rounded, size: 36),
                      title: Text(app, style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => controller.open(app),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
