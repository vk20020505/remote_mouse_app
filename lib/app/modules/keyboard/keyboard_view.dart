import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/protocol.dart';
import '../../core/hotkeys.dart';
import '../../services/settings_service.dart';
import '../../core/app_theme.dart';
import '../../widgets/remote_background.dart';
import '../../widgets/remote_buttons.dart';
import 'keyboard_controller.dart';

class KeyboardView extends GetView<KeyboardController> {
  const KeyboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        TextField(
          controller: controller.field,
          focusNode: controller.focus,
          onChanged: controller.onChanged,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          maxLines: 3,
          minLines: 1,
          autocorrect: false,
          enableSuggestions: true,
          decoration: InputDecoration(
            hintText: 'Tap here and type — goes straight to the computer',
            prefixIcon: const Icon(Icons.keyboard_rounded),
            suffixIcon: IconButton(icon: const Icon(Icons.close_rounded), onPressed: controller.clear),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const SectionLabel('Layout', padding: EdgeInsets.only(left: 2)),
            const Spacer(),
            Obx(() => SegmentedButton<HostOs>(
                  segments: const [
                    ButtonSegment(value: HostOs.mac, label: Text('Mac'), icon: Icon(Icons.laptop_mac)),
                    ButtonSegment(value: HostOs.pc, label: Text('PC'), icon: Icon(Icons.desktop_windows)),
                  ],
                  selected: {settings.hostOs.value},
                  onSelectionChanged: (s) => settings.hostOs.value = s.first,
                )),
          ],
        ),
        const SizedBox(height: 16),
        const SectionLabel('Modifiers'),
        Obx(() {
          final mac = settings.hostOs.value == HostOs.mac;
          final labels = {
            'ctrl': mac ? '⌃ Control' : 'Ctrl',
            'alt': mac ? '⌥ Option' : 'Alt',
            'shift': '⇧ Shift',
            'cmd': mac ? '⌘ Command' : '⊞ Win',
          };
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in labels.entries)
                FilterChip(
                  label: Text(e.value),
                  selected: controller.modifiers.contains(e.key),
                  onSelected: (_) => controller.toggleModifier(e.key),
                ),
            ],
          );
        }),
        const SizedBox(height: 8),
        Text('Pick modifiers, then type a letter or tap a key below.',
            style: text.bodySmall?.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 20),
        const SectionLabel('Keys'),
        _KeyGrid(shortcuts: Hotkeys.keys, onTap: controller.sendHotkey),
        const SizedBox(height: 8),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text('Function keys', style: TextStyle(fontWeight: FontWeight.w600)),
          children: [_KeyGrid(shortcuts: Hotkeys.functionKeys, onTap: controller.sendHotkey)],
        ),
        const SizedBox(height: 8),
        const SectionLabel('Hotkeys'),
        const HotkeyGrid(shortcuts: Hotkeys.system),
      ],
    );
  }
}

class _KeyGrid extends StatelessWidget {
  const _KeyGrid({required this.shortcuts, required this.onTap});

  final List<Hotkey> shortcuts;
  final void Function(Hotkey) onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final s in shortcuts)
          SizedBox(
            width: 64,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () => onTap(s),
              child: Text(s.label, maxLines: 1),
            ),
          ),
      ],
    );
  }
}
