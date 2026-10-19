import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/protocol.dart';
import '../../core/hotkeys.dart';
import '../../services/connection_service.dart';
import '../../services/settings_service.dart';

/// Live remote typing through the phone's own soft keyboard, so every language,
/// IME and voice input the phone supports works on the computer too.
class KeyboardController extends GetxController {
  /// Invisible first character: lets us notice backspace even when the field looks empty.
  static const _sentinel = '\u200B';
  static const _maxBuffered = 400;

  final _conn = Get.find<ConnectionService>();
  final _settings = Get.find<SettingsService>();

  final field = TextEditingController(text: _sentinel);
  final focus = FocusNode();

  /// One-shot modifiers (`ctrl`, `alt`, `shift`, `cmd`) applied to the next key.
  final modifiers = <String>{}.obs;

  String _sent = _sentinel;

  void onChanged(String _) {
    final value = field.value;
    // Wait until an IME (pinyin, kana, …) commits the word.
    if (value.composing.isValid && !value.composing.isCollapsed) return;

    final before = _sent.characters.toList();
    final after = value.text.characters.toList();
    var common = 0;
    while (common < before.length && common < after.length && before[common] == after[common]) {
      common++;
    }
    final deletions = before.length - common;
    final inserted = after.sublist(common).join().replaceAll(_sentinel, '');

    for (var i = 0; i < deletions; i++) {
      _conn.send(Cmd.key('backspace'));
    }
    if (inserted.isNotEmpty) _typeText(inserted);

    _sent = value.text;
    if (!_sent.startsWith(_sentinel) || _sent.length > _maxBuffered) clear();
  }

  void _typeText(String text) {
    if (modifiers.isNotEmpty && text.characters.length == 1) {
      // Ctrl + typed letter etc. Hotkey keys are lower-case; shift is its own modifier.
      sendKey(text == '+' ? 'plus' : text.toLowerCase());
    } else {
      _conn.send(Cmd.type(text));
    }
  }

  /// Sends [key] with any armed modifiers, then disarms them.
  void sendKey(String key) {
    final combo = [...modifiers, key].join('+');
    modifiers.clear();
    _conn.send(Cmd.key(combo));
  }

  void sendHotkey(Hotkey s) => sendKey(s.comboFor(_settings.hostOs.value));

  void toggleModifier(String m) => modifiers.contains(m) ? modifiers.remove(m) : modifiers.add(m);

  void clear() {
    field.value = const TextEditingValue(text: _sentinel, selection: TextSelection.collapsed(offset: 1));
    _sent = _sentinel;
  }

  @override
  void onClose() {
    field.dispose();
    focus.dispose();
    super.onClose();
  }
}
