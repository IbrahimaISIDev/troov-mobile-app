import 'package:flutter/material.dart';

class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }

  // Get percentage of screen width
  static double w(double percentage) {
    return blockSizeHorizontal * percentage;
  }

  // Get percentage of screen height
  static double h(double percentage) {
    return blockSizeVertical * percentage;
  }

  // Get safe area percentage of screen width
  static double sw(double percentage) {
    return safeBlockHorizontal * percentage;
  }

  // Get safe area percentage of screen height
  static double sh(double percentage) {
    return safeBlockVertical * percentage;
  }

  // Get adaptive font size
  static double sp(double fontSize) {
    return blockSizeHorizontal *
        (fontSize / 3.75); // 3.75 is based on a standard 375px width
  }

  // Helper for safe top padding
  static double get paddingTop => _mediaQueryData.padding.top;

  // Detect small screens
  static bool get isSmallScreen => screenWidth < 360;
}

extension ResponsiveExtension on num {
  double h() => Responsive.h(this.toDouble());
  double w() => Responsive.w(this.toDouble());
  double sp() => Responsive.sp(this.toDouble());
}
