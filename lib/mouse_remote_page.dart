import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class MouseRemotePage extends StatefulWidget {
  const MouseRemotePage({super.key});

  @override
  State<MouseRemotePage> createState() => _MouseRemotePageState();
}

class _MouseRemotePageState extends State<MouseRemotePage> {
  Socket? _socket;
  final TextEditingController _ipController = TextEditingController(text: '192.168.1.87'); // Replace with your laptop's default IP
  final TextEditingController _portController = TextEditingController(text: '12345');
  String _connectionStatus = 'Disconnected';
  Offset? _lastPanPosition;
  double sensitivity = 0.5; // smaller = more sensitive

  @override
  void dispose() {
    _socket?.close();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final ip = _ipController.text;
    final port = int.tryParse(_portController.text);

    if (ip.isEmpty || port == null) {
      _showSnackBar('Please enter valid IP and Port', Colors.red);
      return;
    }

    setState(() {
      _connectionStatus = 'Connecting...';
    });

    try {
      _socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
      setState(() {
        _connectionStatus = 'Connected to $ip:$port';
      });
      _showSnackBar('Connected successfully!', Colors.green);

      // Listen for data from the server (optional, but good practice for full duplex)
      _socket?.listen(
        (List<int> data) {
          // If server sends any response, handle it here
          final response = utf8.decode(data);
          print('Server response: $response');
        },
        onDone: () {
          setState(() {
            _connectionStatus = 'Disconnected';
            _socket = null;
          });
          _showSnackBar('Disconnected from server.', Colors.orange);
        },
        onError: (e) {
          setState(() {
            _connectionStatus = 'Error: ${e.toString()}';
            _socket = null;
          });
          _showSnackBar('Connection error: ${e.toString()}', Colors.red);
        },
        cancelOnError: true,
      );
    } catch (e) {
      setState(() {
        _connectionStatus = 'Failed to connect: ${e.toString()}';
        _socket = null;
      });
      _showSnackBar('Failed to connect: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _disconnect() async {
    if (_socket != null) {
      await _socket!.close();
      setState(() {
        _connectionStatus = 'Disconnected';
        _socket = null;
      });
      _showSnackBar('Disconnected manually.', Colors.orange);
    }
  }

  void _sendCommand(String command) {
    if (_socket != null && _connectionStatus.startsWith('Connected')) {
      _socket!.write(command + '\n'); // Add newline for clear message separation
      // print('Sent: $command'); // Uncomment for debugging
    } else {
      _showSnackBar('Not connected to server.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mouse Remote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_socket == null) {
                _connect();
              } else {
                _disconnect();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                      labelText: 'Server IP',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text, // Often people have letters in hostnames
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _socket == null ? _connect : _disconnect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _socket == null ? Colors.green : Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(_socket == null ? 'Connect' : 'Disconnect'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Status: $_connectionStatus',
              style: TextStyle(
                color: _connectionStatus.startsWith('Connected') ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // 🖥️ New Desktop/App Control Buttons
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     ElevatedButton.icon(
            //       onPressed: () => _sendCommand("DESKTOP_LEFT"),
            //       icon: const Icon(Icons.arrow_left),
            //       label: const Text("Desktop Left"),
            //     ),
            //     ElevatedButton.icon(
            //       onPressed: () => _sendCommand("DESKTOP_RIGHT"),
            //       icon: const Icon(Icons.arrow_right),
            //       label: const Text("Desktop Right"),
            //     ),
            //   ],
            // ),
            // ElevatedButton.icon(
            //   onPressed: () => _sendCommand("NEXT_APP"),
            //   icon: const Icon(Icons.apps),
            //   label: const Text("Next App"),
            // ),
            Slider(
              value: sensitivity,
              min: 0.5, // very sensitive
              max: 10.0, // less sensitive
              divisions: 20,
              label: sensitivity.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  sensitivity = value;
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GestureDetector(
                onScaleStart: (details) {
                  _lastPanPosition = details.focalPoint;
                },
                onScaleUpdate: (details) {
                  if (details.pointerCount == 1) {
                    // Single finger = Move mouse
                    if (_lastPanPosition != null) {
                      final dx = details.focalPoint.dx - _lastPanPosition!.dx;
                      final dy = details.focalPoint.dy - _lastPanPosition!.dy;
                      _sendCommand('MOVE ${(dx * sensitivity).toInt()} ${(dy * sensitivity).toInt()}');
                      _lastPanPosition = details.focalPoint;
                    }
                  } else if (details.pointerCount == 2) {
                    // Two-finger drag = Scroll
                    if (_lastPanPosition != null) {
                      final dy = details.focalPoint.dy - _lastPanPosition!.dy;

                      if (dy.abs() > 2) {
                        // threshold to avoid noise
                        final scrollAmount = (dy * (sensitivity * 1)).toInt();
                        _sendCommand('SCROLL $scrollAmount');

                        // _sendCommand('SCROLL ${dy > 0 ? -1 : 1}');
                        _lastPanPosition = details.focalPoint;
                      }
                    }
                  }
                },
                onScaleEnd: (details) {
                  _lastPanPosition = null;
                },
                onTap: () {
                  _sendCommand('CLICK_LEFT');
                },
                onDoubleTap: () {
                  _sendCommand('CLICK_RIGHT');
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueGrey, width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app, size: 80, color: Colors.blueGrey[200]),
                        const SizedBox(height: 8),
                        Text(
                          'Touchpad Area',
                          style: TextStyle(color: Colors.blueGrey[100], fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap for Left Click',
                          style: TextStyle(color: Colors.blueGrey[300], fontSize: 14),
                        ),
                        Text(
                          'Long Press for Right Click',
                          style: TextStyle(color: Colors.blueGrey[300], fontSize: 14),
                        ),
                        Text(
                          'Drag to Move Mouse',
                          style: TextStyle(color: Colors.blueGrey[300], fontSize: 14),
                        ),
                        Text(
                          'Two-finger Pinch to Scroll',
                          style: TextStyle(color: Colors.blueGrey[300], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
