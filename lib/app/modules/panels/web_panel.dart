import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_theme.dart';
import '../../core/hotkeys.dart';
import '../../core/protocol.dart';
import '../../services/connection_service.dart';
import '../../services/settings_service.dart';
import '../../widgets/remote_background.dart';
import '../../widgets/remote_buttons.dart';

class WebPanel extends StatefulWidget {
  const WebPanel({super.key});

  @override
  State<WebPanel> createState() => _WebPanelState();
}

class _WebPanelState extends State<WebPanel> {
  final _url = TextEditingController();

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  /// Focus the address bar, type the URL and press Enter.
  Future<void> _open() async {
    final url = _url.text.trim();
    if (url.isEmpty) return;
    final conn = Get.find<ConnectionService>();
    final os = Get.find<SettingsService>().hostOs.value;
    conn.send(Cmd.key(Hotkeys.web.firstWhere((h) => h.label == 'Address bar').comboFor(os)));
    await Future.delayed(const Duration(milliseconds: 150));
    conn.send(Cmd.type(url));
    conn.send(Cmd.key('enter'));
    _url.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return PanelScaffold(
      title: 'Web Remote',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            autocorrect: false,
            onSubmitted: (_) => _open(),
            decoration: InputDecoration(
              labelText: 'Open address or search',
              prefixIcon: const Icon(Icons.public),
              suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryLight), onPressed: _open),
            ),
          ),
          const SizedBox(height: 24),
          const SectionLabel('Browser'),
          const HotkeyGrid(shortcuts: Hotkeys.web),
          const SizedBox(height: 24),
          const SectionLabel('Page'),
          const HotkeyGrid(shortcuts: [
            Hotkey('Page up', 'page_up'),
            Hotkey('Page down', 'page_down'),
            Hotkey('Top', 'cmd+up', 'home'),
            Hotkey('Bottom', 'cmd+down', 'end'),
            Hotkey('Find', 'cmd+f', 'ctrl+f'),
            Hotkey('Dev tools', 'cmd+alt+i', 'f12'),
          ]),
        ],
      ),
    );
  }
}
