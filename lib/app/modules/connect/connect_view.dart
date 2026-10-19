import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_theme.dart';
import '../../services/connection_service.dart';
import '../../widgets/remote_background.dart';
import 'connect_controller.dart';

class ConnectView extends GetView<ConnectController> {
  const ConnectView({super.key});

  static const _steps = [
    'Run the Mouselink desktop app and press Start Server.',
    'Make sure this phone is on the same Wi-Fi.',
    'Pick your computer below or type the IP shown in the desktop app.',
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return RemoteBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              Row(
                children: [
                  const GradientIcon(Icons.mouse_rounded, size: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mouselink', style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('Connect to your computer', style: text.bodyMedium?.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (final (i, step) in _steps.indexed)
                        Padding(
                          padding: EdgeInsets.only(bottom: i == _steps.length - 1 ? 0 : 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Text('${i + 1}',
                                    style: const TextStyle(
                                        color: AppColors.primaryLight, fontWeight: FontWeight.w700, fontSize: 12)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(step, style: text.bodyMedium?.copyWith(height: 1.4))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const SectionLabel('On this network', padding: EdgeInsets.only(left: 2)),
                  const Spacer(),
                  Obx(() => controller.scanning.value
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : IconButton(
                          icon: const Icon(Icons.refresh_rounded), onPressed: controller.scan, tooltip: 'Scan')),
                ],
              ),
              Obx(() {
                if (controller.found.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(controller.scanning.value ? Icons.radar : Icons.devices_other, color: AppColors.textMuted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.scanning.value ? 'Searching…' : 'No computers found. Enter the IP manually.',
                            style: text.bodyMedium?.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final host in controller.found)
                      Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          leading:
                              GradientIcon(host.os == 'Darwin' ? Icons.laptop_mac : Icons.desktop_windows, size: 40),
                          title: Text(host.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${host.address}:${host.port}'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => controller.pick(host),
                        ),
                      ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              const SectionLabel('Manual'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.hostField,
                      decoration: const InputDecoration(labelText: 'IP address', prefixIcon: Icon(Icons.lan_outlined)),
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 96,
                    child: TextField(
                      controller: controller.portField,
                      decoration: const InputDecoration(labelText: 'Port'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.passwordField,
                decoration: const InputDecoration(
                  labelText: 'Password (if set on the computer)',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                onSubmitted: (_) => controller.connect(),
              ),
              const SizedBox(height: 20),
              Obx(() {
                final connecting = controller.state == ConnState.connecting;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: FilledButton.icon(
                    onPressed: connecting ? null : controller.connect,
                    icon: connecting
                        ? const SizedBox.square(
                            dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.link_rounded),
                    label: Text(connecting ? 'Connecting…' : 'Connect'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  ),
                );
              }),
              Obx(() {
                final error = controller.error;
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(error, style: const TextStyle(color: AppColors.danger))),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
