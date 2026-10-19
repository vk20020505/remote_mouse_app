import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/settings_service.dart';

class SettingsController extends GetxController {
  final settings = Get.find<SettingsService>();

  Future<void> pickWallpaper() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 2400);
    if (picked == null) return;
    // Picker files live in a temp/cache dir that the OS may clear, so keep our own copy.
    final dir = await getApplicationDocumentsDirectory();
    final ext = picked.path.split('.').last;
    final dest = '${dir.path}/wallpaper_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await File(picked.path).copy(dest);
    _deleteOld();
    settings.wallpaperPath.value = dest;
  }

  void clearWallpaper() {
    _deleteOld();
    settings.wallpaperPath.value = '';
  }

  void _deleteOld() {
    final old = settings.wallpaperPath.value;
    if (old.isNotEmpty) {
      try {
        File(old).deleteSync();
      } catch (_) {}
    }
  }
}
