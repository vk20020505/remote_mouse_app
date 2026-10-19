import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core/app_theme.dart';
import '../core/protocol.dart';
import '../core/hotkeys.dart';
import '../services/connection_service.dart';
import '../services/settings_service.dart';

/// A mouse button that presses on touch-down and releases on lift, so it can be held to drag.
class HoldMouseButton extends StatefulWidget {
  const HoldMouseButton({super.key, required this.button, this.label, this.radius});

  final RemoteButton button;
  final String? label;
  final BorderRadius? radius;

  @override
  State<HoldMouseButton> createState() => _HoldMouseButtonState();
}

class _HoldMouseButtonState extends State<HoldMouseButton> {
  final _conn = Get.find<ConnectionService>();
  bool _down = false;

  void _press() {
    HapticFeedback.lightImpact();
    _conn.send(Cmd.mouseDown(widget.button));
    setState(() => _down = true);
  }

  void _release() {
    if (!_down) return;
    _conn.send(Cmd.mouseUp(widget.button));
    setState(() => _down = false);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _press(),
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        decoration: BoxDecoration(
          gradient: _down
              ? AppColors.primaryGradient
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.surfaceHighest.withValues(alpha: 0.85),
                    AppColors.surfaceMid.withValues(alpha: 0.85)
                  ],
                ),
          borderRadius: widget.radius ?? BorderRadius.circular(16),
          border: Border.all(color: _down ? AppColors.primaryLight : AppColors.outlineVariant),
          boxShadow: [
            if (_down) BoxShadow(color: AppColors.primary.withValues(alpha: 0.45), blurRadius: 18),
          ],
        ),
        alignment: Alignment.center,
        child: widget.label == null
            ? null
            : Text(
                widget.label!,
                style: TextStyle(
                  color: _down ? Colors.white : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
      ),
    );
  }
}

/// Left and right buttons, swapped in left-handed mode.
class MouseButtonRow extends StatelessWidget {
  const MouseButtonRow({super.key, this.middle, this.labels = true});

  final Widget? middle;
  final bool labels;

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();
    return Obx(() {
      // A left-handed mouse puts the primary button under the right-hand side.
      final lefty = settings.leftHanded.value;
      final first = lefty ? RemoteButton.right : RemoteButton.left;
      final second = lefty ? RemoteButton.left : RemoteButton.right;
      String? label(RemoteButton b) => labels ? (b == RemoteButton.left ? 'Left' : 'Right') : null;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: HoldMouseButton(
              key: ValueKey(first),
              button: first,
              label: label(first),
              radius: const BorderRadius.only(topLeft: Radius.circular(28), bottomLeft: Radius.circular(8)),
            ),
          ),
          const SizedBox(width: 8),
          if (middle != null) ...[middle!, const SizedBox(width: 8)],
          Expanded(
            child: HoldMouseButton(
              key: ValueKey(second),
              button: second,
              label: label(second),
              radius: const BorderRadius.only(topRight: Radius.circular(28), bottomRight: Radius.circular(8)),
            ),
          ),
        ],
      );
    });
  }
}

/// Grid of shortcut buttons that sends the combo for the current Mac/PC layout.
class HotkeyGrid extends StatelessWidget {
  const HotkeyGrid({super.key, required this.shortcuts, this.minTileWidth = 100});

  final List<Hotkey> shortcuts;
  final double minTileWidth;

  @override
  Widget build(BuildContext context) {
    final conn = Get.find<ConnectionService>();
    final settings = Get.find<SettingsService>();
    return LayoutBuilder(builder: (context, constraints) {
      final columns = (constraints.maxWidth / minTileWidth).floor().clamp(2, 8);
      final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final s in shortcuts)
            SizedBox(
              width: width,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  conn.send(Cmd.key(s.comboFor(settings.hostOs.value)));
                },
                child: Text(s.label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
        ],
      );
    });
  }
}

/// Round icon button that sends a key combo — used by the media and power panels.
class KeyIconButton extends StatelessWidget {
  const KeyIconButton(
      {super.key, required this.icon, required this.onPressed, this.label, this.size = 64, this.primary = false});

  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final double size;

  /// Filled with the brand gradient — for the main action in a group.
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: size,
          child: Material(
            shape: const CircleBorder(side: BorderSide(color: AppColors.outlineVariant)),
            color: primary ? null : AppColors.surfaceHigh.withValues(alpha: 0.85),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: primary
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 24)],
                    )
                  : null,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onPressed();
                },
                child: Icon(icon, size: size * 0.45, color: primary ? Colors.white : AppColors.primaryLight),
              ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 6),
          Text(label!, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
        ],
      ],
    );
  }
}

/// Shown at the top of the remote when the connection drops.
class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final conn = Get.find<ConnectionService>();
    return Obx(() {
      if (conn.state.value == ConnState.connected) return const SizedBox.shrink();
      final connecting = conn.state.value == ConnState.connecting;
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(connecting ? Icons.sync : Icons.wifi_off_rounded, color: AppColors.danger, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(connecting ? 'Reconnecting…' : (conn.lastError.value ?? 'Disconnected'))),
            TextButton(onPressed: connecting ? null : conn.reconnect, child: const Text('Reconnect')),
          ],
        ),
      );
    });
  }
}
