import 'package:flutter/material.dart';

class TextStyleClass {
  static const String fontFamily = 'Inter';

  static const TextStyle normalMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    color: Colors.black,
  );
  static const TextStyle normalRegular = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    color: Colors.black,
  );
  static const TextStyle smallMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    color: Colors.black,
  );
  static const TextStyle smallRegular = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    color: Colors.black,
  );
}

class AppConstant {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
