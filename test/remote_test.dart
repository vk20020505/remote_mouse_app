import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:remote_mouse_app/app/core/protocol.dart';
import 'package:remote_mouse_app/app/modules/keyboard/keyboard_controller.dart';
import 'package:remote_mouse_app/app/services/connection_service.dart';
import 'package:remote_mouse_app/app/services/settings_service.dart';

/// Records commands instead of writing to a socket.
class FakeConnection extends ConnectionService {
  final sent = <String>[];
  @override
  void send(String command) => sent.add(command);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // GetStorage uses path_provider; point it at a temp dir.
    final dir = await Directory.systemTemp.createTemp('rm_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'), (_) async => dir.path);
    await GetStorage.init();
  });

  setUp(() {
    Get.reset();
    Get.put(SettingsService());
  });

  test('DeltaAccumulator keeps sub-pixel remainders', () {
    final acc = DeltaAccumulator();
    expect(acc.add(0.4, -0.4), isNull);
    expect(acc.add(0.4, -0.4), isNull);
    expect(acc.add(0.4, -0.4), (1, -1));
    expect(acc.add(0.1, 0), isNull); // 0.2 + 0.1 left over
  });

  group('KeyboardController', () {
    late FakeConnection conn;
    late KeyboardController kb;

    setUp(() {
      conn = Get.put<ConnectionService>(FakeConnection()) as FakeConnection;
      kb = KeyboardController();
    });

    void typeInto(String text, {TextRange composing = TextRange.empty}) {
      kb.field.value = TextEditingValue(text: '​$text', composing: composing);
      kb.onChanged(kb.field.text);
    }

    test('sends typed text, unicode and backspaces as a diff', () {
      typeInto('hé');
      typeInto('hé世界');
      typeInto('hé世');
      expect(conn.sent, [Cmd.type('hé'), Cmd.type('世界'), 'KEY backspace']);
    });

    test('waits for IME composition to finish', () {
      typeInto('ni', composing: const TextRange(start: 1, end: 3));
      expect(conn.sent, isEmpty);
      typeInto('你');
      expect(conn.sent, [Cmd.type('你')]);
    });

    test('backspace on the empty field still reaches the computer', () {
      kb.field.value = const TextEditingValue(text: '');
      kb.onChanged('');
      expect(conn.sent, ['KEY backspace']);
      expect(kb.field.text, '​');
    });

    test('armed modifiers turn the next letter into a shortcut', () {
      kb.toggleModifier('cmd');
      kb.toggleModifier('shift');
      typeInto('T');
      typeInto('Tx');
      expect(conn.sent, ['KEY cmd+shift+t', Cmd.type('x')]);
    });
  });

  group('ConnectionService', () {
    late ServerSocket server;
    final received = <String>[];

    setUp(() async {
      received.clear();
      server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((client) {
        client.cast<List<int>>().transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
          received.add(line);
          if (line.startsWith('AUTH ')) {
            final ok = Cmd.unb64(line.substring(5)) == 'secret';
            client.write(ok ? 'AUTH_OK Windows\n' : 'AUTH_FAIL\n');
          } else if (line == 'CLIP_GET') {
            // Split the reply across writes to exercise line buffering.
            final reply = 'CLIP ${Cmd.b64('from pc')}\n';
            client.write(reply.substring(0, 4));
            Future.delayed(const Duration(milliseconds: 20), () => client.write(reply.substring(4)));
          }
        });
      });
    });

    tearDown(() => server.close());

    test('rejects a wrong password', () async {
      final conn = ConnectionService();
      expect(await conn.connect('127.0.0.1', server.port, password: 'nope'), isFalse);
      expect(conn.lastError.value, 'Wrong password');
      expect(conn.state.value, ConnState.disconnected);
    });

    test('authenticates, detects the host OS and handles request/reply', () async {
      final conn = ConnectionService();
      expect(await conn.connect('127.0.0.1', server.port, password: 'secret'), isTrue);
      expect(conn.state.value, ConnState.connected);
      expect(Get.find<SettingsService>().hostOs.value, HostOs.pc);

      conn.send(Cmd.move(3, -4));
      final reply = await conn.request(Cmd.clipGet, 'CLIP ');
      expect(Cmd.unb64(reply!.substring(5)), 'from pc');
      expect(received, contains('MOVE 3 -4'));
      await conn.disconnect();
    });
  });
}
