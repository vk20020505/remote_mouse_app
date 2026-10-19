import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../core/app_theme.dart';
import '../../services/settings_service.dart';
import '../../widgets/remote_background.dart';

extension PanelInfo on PanelType {
  String get title => switch (this) {
        PanelType.media => 'Media Remote',
        PanelType.web => 'Web Remote',
        PanelType.apps => 'App Switcher',
        PanelType.power => 'Power Options',
        PanelType.clipboard => 'Clipboard Sync',
      };

  String get subtitle => switch (this) {
        PanelType.media => 'YouTube, Netflix, Spotify, VLC, slides…',
        PanelType.web => 'Chrome, Firefox, Opera',
        PanelType.apps => 'Launch and switch between apps',
        PanelType.power => 'Shut down, restart, sleep, lock',
        PanelType.clipboard => 'Copy text and images across devices',
      };

  IconData get icon => switch (this) {
        PanelType.media => Icons.play_circle_outline,
        PanelType.web => Icons.public,
        PanelType.apps => Icons.apps,
        PanelType.power => Icons.power_settings_new,
        PanelType.clipboard => Icons.content_paste,
      };

  String get route => switch (this) {
        PanelType.media => Routes.mediaPanel,
        PanelType.web => Routes.webPanel,
        PanelType.apps => Routes.appsPanel,
        PanelType.power => Routes.powerPanel,
        PanelType.clipboard => Routes.clipboardPanel,
      };
}

/// Specialty panels in the user's order. Long-press and drag to reorder.
class PanelsView extends StatelessWidget {
  const PanelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();
    return Obx(() => ReorderableListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          onReorder: settings.movePanel,
          header: Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 2),
            child: Text('Long-press and drag to reorder',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
          ),
          children: [
            for (final panel in settings.panelOrder)
              Card(
                key: ValueKey(panel),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  leading: GradientIcon(panel.icon, size: 48),
                  title: Text(panel.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(panel.subtitle, style: const TextStyle(color: AppColors.textMuted)),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  onTap: () => Get.toNamed(panel.route),
                ),
              ),
          ],
        ));
  }
}
