

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remote_mouse_app/mouse_remote_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Mouse',
      theme: ThemeData.dark(),
      home: MouseRemotePage()
      // RemoteMouseScreen(),
    );
  }
}
