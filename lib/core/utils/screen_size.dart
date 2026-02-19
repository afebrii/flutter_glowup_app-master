import 'package:flutter/material.dart';

enum DeviceType { phone, tablet, desktop }

class ScreenSize {
  ScreenSize._();

  // Breakpoints
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 1024;

  /// Check if device is phone
  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < phoneMaxWidth;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= phoneMaxWidth && width < tabletMaxWidth;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }

  /// Check if device is tablet or larger
  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= phoneMaxWidth;
  }

  /// Get device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < phoneMaxWidth) return DeviceType.phone;
    if (width < tabletMaxWidth) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Responsive value helper - returns different values based on device type
  static T responsive<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.phone:
        return phone;
    }
  }

  /// Get grid columns for services/products
  static int gridColumns(BuildContext context) {
    return responsive(context, phone: 2, tablet: 3, desktop: 4);
  }

  /// Get grid columns for service selection (POS)
  static int serviceGridColumns(BuildContext context) {
    return responsive(context, phone: 2, tablet: 4, desktop: 5);
  }

  /// Get grid columns for stats cards
  static int statsGridColumns(BuildContext context) {
    return responsive(context, phone: 2, tablet: 4, desktop: 4);
  }

  /// Responsive padding
  static double responsivePadding(BuildContext context) {
    return responsive(context, phone: 16.0, tablet: 24.0, desktop: 32.0);
  }

  /// Responsive horizontal padding
  static EdgeInsets responsiveHorizontalPadding(BuildContext context) {
    final padding = responsivePadding(context);
    return EdgeInsets.symmetric(horizontal: padding);
  }

  /// Responsive all padding
  static EdgeInsets responsiveAllPadding(BuildContext context) {
    final padding = responsivePadding(context);
    return EdgeInsets.all(padding);
  }

  /// Responsive font size
  static double fontSize(BuildContext context, {double base = 14}) {
    return responsive(
      context,
      phone: base,
      tablet: base * 1.1,
      desktop: base * 1.2,
    );
  }

  /// Responsive spacing
  static double spacing(BuildContext context, {double base = 16}) {
    return responsive(
      context,
      phone: base,
      tablet: base * 1.25,
      desktop: base * 1.5,
    );
  }

  /// Responsive icon size
  static double iconSize(BuildContext context, {double base = 24}) {
    return responsive(
      context,
      phone: base,
      tablet: base * 1.2,
      desktop: base * 1.3,
    );
  }

  /// Get screen width
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
}
