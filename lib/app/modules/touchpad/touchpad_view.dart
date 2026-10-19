import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_theme.dart';
import '../../widgets/remote_background.dart';
import '../../widgets/remote_buttons.dart';
import 'touchpad_controller.dart';

class TouchpadView extends GetView<TouchpadController> {
  const TouchpadView({super.key});

  @override
  Widget build(BuildContext context) {
    const hints = [
      (Icons.ads_click, 'Tap to click · 2-finger tap to right click'),
      (Icons.swipe_vertical_outlined, '2 fingers to scroll · pinch to zoom'),
      (Icons.view_carousel_outlined, '3-finger swipe for desktops'),
      (Icons.pan_tool_alt_outlined, 'Long-press then move to drag'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        children: [
          Expanded(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: controller.onDown,
              onPointerMove: controller.onMove,
              onPointerUp: controller.onUp,
              onPointerCancel: (e) => controller.onUp(e, cancelled: true),
              child: Obx(() => TouchSurface(
                    active: controller.dragging.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.12),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(Icons.touch_app_rounded, size: 40, color: AppColors.primaryLight),
                            ),
                            const SizedBox(height: 20),
                            for (final (icon, label) in hints)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(icon, size: 15, color: AppColors.textMuted.withValues(alpha: 0.7)),
                                    const SizedBox(width: 8),
                                    Text(label,
                                        style:
                                            TextStyle(color: AppColors.textMuted.withValues(alpha: 0.8), fontSize: 13)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (controller.hint.value.isNotEmpty)
                          Positioned(
                            top: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 14)],
                              ),
                              child: Text(controller.hint.value,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
                      ],
                    ),
                  )),
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 68, child: MouseButtonRow()),
        ],
      ),
    );
  }
}
