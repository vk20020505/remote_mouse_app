import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_theme.dart';
import '../../core/protocol.dart';
import '../../services/connection_service.dart';
import '../../widgets/remote_background.dart';

class PowerPanel extends StatelessWidget {
  const PowerPanel({super.key});

  static const _actions = [
    (PowerAction.lock, Icons.lock_outline, 'Lock', false),
    (PowerAction.sleep, Icons.bedtime_outlined, 'Sleep', false),
    (PowerAction.restart, Icons.restart_alt, 'Restart', true),
    (PowerAction.shutdown, Icons.power_settings_new, 'Shut down', true),
  ];

  Future<void> _run(PowerAction action, String label, bool confirm) async {
    if (confirm) {
      final ok = await Get.dialog<bool>(AlertDialog(
        title: Text('$label computer?'),
        content: const Text('Unsaved work on the computer may be lost.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Get.back(result: true),
            child: Text(label),
          ),
        ],
      ));
      if (ok != true) return;
    }
    Get.find<ConnectionService>().send(Cmd.power(action));
    Get.snackbar(label, 'Sent to computer', snackPosition: SnackPosition.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    return PanelScaffold(
      title: 'Power Options',
      child: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        children: [
          for (final (action, icon, label, confirm) in _actions)
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: confirm ? AppColors.danger.withValues(alpha: 0.35) : AppColors.outlineVariant),
              ),
              child: InkWell(
                onTap: () => _run(action, label, confirm),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (confirm)
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(icon, size: 34, color: AppColors.danger),
                      )
                    else
                      GradientIcon(icon, size: 64),
                    const SizedBox(height: 14),
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
