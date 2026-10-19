import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/hotkeys.dart';
import '../../core/protocol.dart';
import '../../services/connection_service.dart';
import '../../widgets/remote_background.dart';
import '../../widgets/remote_buttons.dart';

/// System media keys work in every player (Spotify, Apple Music, VLC, browsers);
/// the player and presentation keys target the focused window.
class MediaPanel extends StatelessWidget {
  const MediaPanel({super.key});

  static const _player = [
    Hotkey('Play / Pause', 'space'),
    Hotkey('Back 5s', 'left'),
    Hotkey('Forward 5s', 'right'),
    Hotkey('Volume up', 'up'),
    Hotkey('Volume down', 'down'),
    Hotkey('Full screen', 'f'),
    Hotkey('Exit full', 'esc'),
    Hotkey('Mute', 'm'),
    Hotkey('Captions', 'c'),
  ];

  static const _youtube = [
    Hotkey('Back 10s', 'j'),
    Hotkey('Forward 10s', 'l'),
    Hotkey('Next video', 'shift+n'),
    Hotkey('Theater', 't'),
    Hotkey('Slower', 'shift+,'),
    Hotkey('Faster', 'shift+.'),
  ];

  static const _slides = [
    Hotkey('Start show', 'cmd+alt+p', 'f5'),
    Hotkey('Previous', 'left'),
    Hotkey('Next', 'right'),
    Hotkey('Black screen', 'b'),
    Hotkey('End show', 'esc'),
  ];

  @override
  Widget build(BuildContext context) {
    final conn = Get.find<ConnectionService>();
    void key(String k) => conn.send(Cmd.key(k));

    return PanelScaffold(
      title: 'Media Remote',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      KeyIconButton(icon: Icons.skip_previous_rounded, onPressed: () => key('media_previous')),
                      KeyIconButton(
                          icon: Icons.play_arrow_rounded,
                          size: 92,
                          primary: true,
                          onPressed: () => key('media_play_pause')),
                      KeyIconButton(icon: Icons.skip_next_rounded, onPressed: () => key('media_next')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(indent: 24, endIndent: 24),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      KeyIconButton(
                          icon: Icons.volume_down_rounded,
                          size: 56,
                          label: 'Vol −',
                          onPressed: () => key('media_volume_down')),
                      KeyIconButton(
                          icon: Icons.volume_off_rounded,
                          size: 56,
                          label: 'Mute',
                          onPressed: () => key('media_volume_mute')),
                      KeyIconButton(
                          icon: Icons.volume_up_rounded,
                          size: 56,
                          label: 'Vol +',
                          onPressed: () => key('media_volume_up')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const SectionLabel('Video player · YouTube, Netflix, VLC…'),
          const HotkeyGrid(shortcuts: _player),
          const SizedBox(height: 24),
          const SectionLabel('YouTube extras'),
          const HotkeyGrid(shortcuts: _youtube),
          const SizedBox(height: 24),
          const SectionLabel('Presentation · Keynote, PowerPoint, Slides'),
          const HotkeyGrid(shortcuts: _slides),
        ],
      ),
    );
  }
}
