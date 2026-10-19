import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_theme.dart';
import '../../widgets/remote_background.dart';
import '../../widgets/remote_buttons.dart';
import 'mouse_controller.dart';

/// Phone as a PC mouse: hold-able buttons and wheel on top, move area below, optional gyro.
class MouseView extends GetView<MouseController> {
  const MouseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: MouseButtonRow(
              middle: SizedBox(
                width: 56,
                child: GestureDetector(
                  onVerticalDragUpdate: controller.onWheel,
                  onTap: controller.onWheelTap,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.surfaceHigh.withValues(alpha: 0.9),
                          AppColors.surfaceLow.withValues(alpha: 0.9)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.keyboard_arrow_up_rounded, color: AppColors.primaryLight),
                        for (var i = 0; i < 5; i++)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            width: 22,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.outline.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryLight),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            flex: 5,
            child: Obx(() {
              final gyroOn = controller.gyro.value;
              return GestureDetector(
                onPanUpdate: gyroOn ? null : controller.onPadMove,
                onTap: controller.onPadTap,
                child: TouchSurface(
                  active: gyroOn,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.12),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Icon(gyroOn ? Icons.screen_rotation_alt : Icons.mouse_rounded,
                              size: 40, color: AppColors.primaryLight),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          gyroOn ? 'Tilt and turn the phone to move' : 'Drag to move · Hold a button + drag to select',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.85), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Obx(() => Card(
                margin: EdgeInsets.zero,
                child: SwitchListTile(
                  secondary: const GradientIcon(Icons.threesixty, size: 36),
                  title: const Text('Gyro mouse', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: controller.gyroAvailable.value ? null : const Text('No gyroscope on this device'),
                  value: controller.gyro.value,
                  onChanged: controller.gyroAvailable.value ? (v) => controller.gyro.value = v : null,
                ),
              )),
        ],
      ),
    );
  }
}
