import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/protocol.dart';
import '../../services/connection_service.dart';
import '../../widgets/remote_background.dart';

class ClipboardController extends GetxController {
  final _conn = Get.find<ConnectionService>();

  final textField = TextEditingController();
  final busy = false.obs;
  final pcImage = Rxn<Uint8List>();

  @override
  void onReady() {
    super.onReady();
    pasteFromPhone();
  }

  Future<void> pasteFromPhone() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) textField.text = data!.text!;
  }

  void sendText() {
    _conn.send(Cmd.clipSet(textField.text));
    _done('Copied to the computer clipboard');
  }

  Future<void> fetchText() async {
    busy.value = true;
    final reply = await _conn.request(Cmd.clipGet, 'CLIP ');
    busy.value = false;
    if (reply == null) return _done('Computer did not answer');
    final text = Cmd.unb64(reply.substring(5));
    textField.text = text;
    await Clipboard.setData(ClipboardData(text: text));
    _done('Copied to this phone');
  }

  Future<void> sendImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 2560, maxHeight: 2560);
    if (picked == null) return;
    busy.value = true;
    try {
      // The desktop clipboard expects PNG; gallery photos are usually JPEG/HEIC.
      final codec = await ui.instantiateImageCodec(await picked.readAsBytes());
      final frame = await codec.getNextFrame();
      final png = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      _conn.send(Cmd.clipImageSet(png!.buffer.asUint8List()));
      _done('Image copied to the computer clipboard');
    } catch (e) {
      _done('Could not read that image');
    } finally {
      busy.value = false;
    }
  }

  Future<void> fetchImage() async {
    busy.value = true;
    final reply = await _conn.request(Cmd.clipImageGet, 'CLIP_IMG', timeout: const Duration(seconds: 20));
    busy.value = false;
    if (reply == null) return _done('Computer did not answer');
    if (reply == 'CLIP_IMG_NONE') return _done('No image on the computer clipboard');
    pcImage.value = base64Decode(reply.substring('CLIP_IMG '.length));
  }

  void _done(String message) => Get.snackbar('Clipboard', message, snackPosition: SnackPosition.BOTTOM);

  @override
  void onClose() {
    textField.dispose();
    super.onClose();
  }
}

class ClipboardPanel extends GetView<ClipboardController> {
  const ClipboardPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return PanelScaffold(
      title: 'Clipboard Sync',
      child: Obx(() => AbsorbPointer(
            absorbing: controller.busy.value,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (controller.busy.value) ...[
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: const LinearProgressIndicator()),
                  const SizedBox(height: 12),
                ],
                const SectionLabel('Text'),
                TextField(
                  controller: controller.textField,
                  minLines: 4,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'Text to share',
                    suffixIcon: IconButton(
                      tooltip: 'Paste from phone',
                      icon: const Icon(Icons.content_paste_go),
                      onPressed: controller.pasteFromPhone,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: controller.sendText,
                        icon: const Icon(Icons.upload),
                        label: const Text('Phone → PC'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: controller.fetchText,
                        icon: const Icon(Icons.download),
                        label: const Text('PC → Phone'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const SectionLabel('Images'),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: controller.sendImage,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('Send photo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: controller.fetchImage,
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Get PC image'),
                      ),
                    ),
                  ],
                ),
                if (controller.pcImage.value != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(controller.pcImage.value!),
                  ),
                ],
              ],
            ),
          )),
    );
  }
}
