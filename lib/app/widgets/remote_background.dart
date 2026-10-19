import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/app_theme.dart';
import '../services/settings_service.dart';

/// Paints the brand backdrop, or the user's wallpaper (dimmed so controls stay readable), behind [child].
class RemoteBackground extends StatelessWidget {
  const RemoteBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();
    return Obx(() {
      final path = settings.wallpaperPath.value;
      final hasWallpaper = path.isNotEmpty && File(path).existsSync();
      return Stack(
        fit: StackFit.expand,
        children: [
          if (hasWallpaper) ...[
            Image.file(File(path), fit: BoxFit.cover),
            ColoredBox(color: AppColors.background.withValues(alpha: 0.6)),
          ] else
            const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.backdrop)),
          child,
        ],
      );
    });
  }
}

/// Scaffold for specialty panels: backdrop, transparent app bar, connection banner.
class PanelScaffold extends StatelessWidget {
  const PanelScaffold({super.key, required this.title, required this.child, this.actions});

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return RemoteBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(title), actions: actions),
        body: SafeArea(child: child),
      ),
    );
  }
}

/// Small uppercase heading used between groups of controls.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.padding = const EdgeInsets.only(bottom: 10, left: 2)});

  final String text;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

/// Rounded square with the brand gradient and a white icon.
class GradientIcon extends StatelessWidget {
  const GradientIcon(this.icon, {super.key, this.size = 44});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.52),
    );
  }
}

/// Large touch surface used by the touchpad and the mouse move area.
class TouchSurface extends StatelessWidget {
  const TouchSurface({super.key, required this.child, this.active = false});

  final Widget child;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceHigh.withValues(alpha: 0.75),
            AppColors.surfaceLow.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.outlineVariant,
          width: active ? 2 : 1,
        ),
        boxShadow: [
          if (active) BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 24),
        ],
      ),
      child: child,
    );
  }
}
