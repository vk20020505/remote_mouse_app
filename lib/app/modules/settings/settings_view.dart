import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_theme.dart';
import '../../core/protocol.dart';
import '../../widgets/remote_background.dart';
import '../panels/panels_view.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = controller.settings;

    Widget section(String title, List<Widget> children) => Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(title, padding: const EdgeInsets.only(left: 6, bottom: 8)),
              Card(
                margin: EdgeInsets.zero,
                child: Column(children: children),
              ),
            ],
          ),
        );

    Widget slider(String label, IconData icon, Rx<double> value, double min, double max) => Obx(() => ListTile(
          leading: Icon(icon),
          title: Row(
            children: [
              Text(label),
              const Spacer(),
              Text(
                value.value.toStringAsFixed(1),
                style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          subtitle: Slider(
            value: value.value.clamp(min, max),
            min: min,
            max: max,
            divisions: ((max - min) * 10).round(),
            label: value.value.toStringAsFixed(1),
            onChanged: (v) => value.value = v,
          ),
        ));

    return RemoteBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            section('Pointer', [
              slider('Cursor speed', Icons.speed_rounded, s.sensitivity, 0.3, 5),
              slider('Scroll speed', Icons.swap_vert_rounded, s.scrollSpeed, 0.2, 4),
              slider('Gyro sensitivity', Icons.threesixty, s.gyroSensitivity, 0.2, 4),
              const Divider(indent: 16, endIndent: 16),
              Obx(() => SwitchListTile(
                    secondary: const Icon(Icons.swipe_vertical_outlined, color: AppColors.primaryLight),
                    title: const Text('Natural scrolling'),
                    subtitle: const Text('Content follows your fingers. Turn off if scrolling feels inverted.'),
                    value: s.naturalScroll.value,
                    onChanged: (v) => s.naturalScroll.value = v,
                  )),
              Obx(() => SwitchListTile(
                    secondary: const Icon(Icons.back_hand_outlined, color: AppColors.primaryLight),
                    title: const Text('Left-handed mode'),
                    subtitle: const Text('Swap the left and right mouse buttons'),
                    value: s.leftHanded.value,
                    onChanged: (v) => s.leftHanded.value = v,
                  )),
            ]),
            section('Keyboard', [
              Obx(() => ListTile(
                    leading: const Icon(Icons.computer_rounded),
                    title: const Text('Computer layout'),
                    subtitle: const Text('Detected automatically when you connect'),
                    trailing: SegmentedButton<HostOs>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: HostOs.mac, label: Text('Mac')),
                        ButtonSegment(value: HostOs.pc, label: Text('PC')),
                      ],
                      selected: {s.hostOs.value},
                      onSelectionChanged: (v) => s.hostOs.value = v.first,
                    ),
                  )),
              Obx(() => SwitchListTile(
                    secondary: const Icon(Icons.volume_up_outlined, color: AppColors.primaryLight),
                    title: const Text('Volume buttons control computer'),
                    subtitle: const Text('Phone volume keys change the computer volume while connected'),
                    value: s.volumeKeys.value,
                    onChanged: (v) => s.volumeKeys.value = v,
                  )),
            ]),
            section('Panels', [
              Obx(() => ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    onReorder: s.movePanel,
                    children: [
                      for (final (i, panel) in s.panelOrder.indexed)
                        ListTile(
                          key: ValueKey(panel),
                          leading: GradientIcon(panel.icon, size: 34),
                          title: Text(panel.title),
                          trailing: ReorderableDragStartListener(
                            index: i,
                            child: const Icon(Icons.drag_indicator_rounded, color: AppColors.textMuted),
                          ),
                        ),
                    ],
                  )),
            ]),
            section('Appearance', [
              Obx(() => ListTile(
                    leading: const Icon(Icons.wallpaper_rounded),
                    title: const Text('Wallpaper'),
                    subtitle: Text(s.wallpaperPath.value.isEmpty ? 'Default' : 'Custom image'),
                    onTap: controller.pickWallpaper,
                    trailing: s.wallpaperPath.value.isEmpty
                        ? const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted)
                        : IconButton(icon: const Icon(Icons.close_rounded), onPressed: controller.clearWallpaper),
                  )),
            ]),
            section('Security', const [
              ListTile(
                leading: Icon(Icons.lock_outline_rounded),
                title: Text('Connection password'),
                subtitle: Text('Set a password in the desktop app, then enter it on the connect screen.'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
