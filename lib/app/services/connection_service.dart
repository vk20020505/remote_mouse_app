import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';

import '../core/protocol.dart';
import 'settings_service.dart';

enum ConnState { disconnected, connecting, connected }

/// A computer that answered the LAN discovery broadcast.
class DiscoveredHost {
  const DiscoveredHost(this.name, this.address, this.port, this.os);

  final String name;
  final String address;
  final int port;
  final String os;
}

/// Owns the TCP connection to the desktop server. Every screen sends through here.
class ConnectionService extends GetxService {
  static const discoveryPort = 12346;
  static const _pingEvery = Duration(seconds: 5);
  static const _deadAfter = Duration(seconds: 15);

  final state = ConnState.disconnected.obs;
  final lastError = RxnString();

  /// Address of the current (or last) connection.
  final address = ''.obs;

  Socket? _socket;
  final _incoming = StreamController<String>.broadcast();
  List<int> _buffer = [];
  Timer? _pingTimer;
  DateTime _lastPong = DateTime.now();
  bool _serverAnswersPing = false;

  bool get isConnected => state.value == ConnState.connected;

  /// Lines received from the server, without the trailing newline.
  Stream<String> get lines => _incoming.stream;

  SettingsService get _settings => Get.find();

  Future<bool> connect(String host, int port, {String password = ''}) async {
    await disconnect();
    state.value = ConnState.connecting;
    lastError.value = null;
    address.value = '$host:$port';

    try {
      final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
      socket.setOption(SocketOption.tcpNoDelay, true);
      _socket = socket;
      _buffer = [];
      socket.listen(_onData, onDone: _onClosed, onError: (_) => _onClosed(), cancelOnError: true);

      final reply = await request(Cmd.auth(password), 'AUTH_', timeout: const Duration(seconds: 3));
      if (reply == 'AUTH_FAIL') {
        await disconnect();
        lastError.value = 'Wrong password';
        return false;
      }
      // Servers before the AUTH command never reply; treat silence as "no password".
      _serverAnswersPing = reply != null;
      if (reply != null && reply.startsWith('AUTH_OK')) {
        final os = reply.split(' ').skip(1).firstOrNull;
        if (os != null) _settings.hostOs.value = os == 'Darwin' ? HostOs.mac : HostOs.pc;
      }

      state.value = ConnState.connected;
      _settings
        ..host.value = host
        ..port.value = port
        ..password.value = password;
      _startPing();
      return true;
    } catch (e) {
      await disconnect();
      lastError.value = 'Could not connect: ${e is SocketException ? e.message : e}';
      return false;
    }
  }

  Future<bool> reconnect() => connect(_settings.host.value, _settings.port.value, password: _settings.password.value);

  Future<void> disconnect() async {
    _pingTimer?.cancel();
    _pingTimer = null;
    final socket = _socket;
    _socket = null;
    state.value = ConnState.disconnected;
    socket?.destroy();
  }

  /// Fire-and-forget. Silently dropped when not connected, so gesture code doesn't need to check.
  void send(String command) {
    final socket = _socket;
    if (socket == null) return;
    try {
      socket.write('$command\n');
    } catch (_) {
      _onClosed();
    }
  }

  /// Sends [command] and waits for the first line starting with [replyPrefix].
  /// Returns null on timeout.
  Future<String?> request(String command, String replyPrefix, {Duration timeout = const Duration(seconds: 10)}) async {
    final reply = lines.firstWhere((l) => l.startsWith(replyPrefix)).timeout(timeout);
    send(command);
    try {
      return await reply;
    } on TimeoutException {
      return null;
    } on StateError {
      return null;
    }
  }

  /// Broadcasts on the LAN and collects servers that answer within [wait].
  Future<List<DiscoveredHost>> discover({Duration wait = const Duration(milliseconds: 1500)}) async {
    final found = <String, DiscoveredHost>{};
    final udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    try {
      udp.broadcastEnabled = true;
      udp.listen((event) {
        if (event != RawSocketEvent.read) return;
        final dg = udp.receive();
        if (dg == null) return;
        final parts = utf8.decode(dg.data, allowMalformed: true).trim().split(' ');
        if (parts.length >= 3 && parts[0] == 'REMOTE_MOUSE') {
          final ip = dg.address.address;
          found[ip] = DiscoveredHost(parts[1], ip, int.tryParse(parts[2]) ?? 12345, parts.length > 3 ? parts[3] : '');
        }
      });
      udp.send(utf8.encode('REMOTE_MOUSE_DISCOVER'), InternetAddress('255.255.255.255'), discoveryPort);
      await Future.delayed(wait);
    } finally {
      udp.close();
    }
    return found.values.toList();
  }

  void _onData(List<int> data) {
    _buffer.addAll(data);
    var newline = _buffer.indexOf(10);
    while (newline != -1) {
      final line = utf8.decode(_buffer.sublist(0, newline), allowMalformed: true).trim();
      _buffer = _buffer.sublist(newline + 1);
      if (line == 'PONG') _lastPong = DateTime.now();
      if (line.isNotEmpty) _incoming.add(line);
      newline = _buffer.indexOf(10);
    }
  }

  void _onClosed() {
    if (_socket == null) return;
    final wasConnected = isConnected;
    disconnect();
    if (wasConnected) lastError.value = 'Connection lost';
  }

  void _startPing() {
    _lastPong = DateTime.now();
    _pingTimer = Timer.periodic(_pingEvery, (_) {
      if (_serverAnswersPing && DateTime.now().difference(_lastPong) > _deadAfter) {
        _onClosed();
        return;
      }
      send(Cmd.ping);
    });
  }

  @override
  void onClose() {
    disconnect();
    _incoming.close();
    super.onClose();
  }
}
