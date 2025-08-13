import 'package:flutter/material.dart';

class AdaptiveBreakpoints {
  static const double smallMobileBreakpoint = 350;
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 840;
  static const double desktopBreakpoint = 1200;

  static bool isSmallMobile(double width) => width < smallMobileBreakpoint;
  static bool isMobile(double width) =>
      width >= smallMobileBreakpoint && width < mobileBreakpoint;
  static bool isTablet(double width) =>
      width >= mobileBreakpoint && width < desktopBreakpoint;
  static bool isDesktop(double width) => width >= desktopBreakpoint;

  // Content width constraints - don't gobble up all horizontal space
  static double getContentWidth(double screenWidth) {
    if (isDesktop(screenWidth)) {
      return (screenWidth * 0.7).clamp(600.0, 1200.0);
    } else if (isTablet(screenWidth)) {
      return (screenWidth * 0.85).clamp(400.0, 800.0);
    }
    return screenWidth;
  }

  static EdgeInsets getScreenPadding(double screenWidth) {
    if (isDesktop(screenWidth)) {
      return const EdgeInsets.all(32);
    } else if (isTablet(screenWidth)) {
      return const EdgeInsets.all(24);
    } else if (isSmallMobile(screenWidth)) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 12);
    }
    return const EdgeInsets.all(16);
  }

  static double getSpacing(
    double screenWidth, {
    double smallMobile = 8,
    double mobile = 16,
    double tablet = 24,
    double desktop = 32,
  }) {
    if (isDesktop(screenWidth)) return desktop;
    if (isTablet(screenWidth)) return tablet;
    if (isSmallMobile(screenWidth)) return smallMobile;
    return mobile;
  }
}
