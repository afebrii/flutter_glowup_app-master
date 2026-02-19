import 'package:flutter/material.dart';
import '../utils/screen_size.dart';

/// Widget yang menampilkan layout berbeda berdasarkan ukuran layar
class ResponsiveWidget extends StatelessWidget {
  final Widget phone;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.phone,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ScreenSize.isDesktop(context)) {
          return desktop ?? tablet ?? phone;
        }
        if (ScreenSize.isTablet(context)) {
          return tablet ?? phone;
        }
        return phone;
      },
    );
  }
}

/// Builder widget yang memberikan device type ke child
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ScreenSize.getDeviceType(context);
        return builder(context, deviceType);
      },
    );
  }
}

/// Widget untuk split layout (master-detail) pada tablet
class SplitLayout extends StatelessWidget {
  final Widget master;
  final Widget? detail;
  final Widget? detailPlaceholder;
  final int masterFlex;
  final int detailFlex;
  final bool showDivider;

  const SplitLayout({
    super.key,
    required this.master,
    this.detail,
    this.detailPlaceholder,
    this.masterFlex = 40,
    this.detailFlex = 60,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Master panel
        Expanded(
          flex: masterFlex,
          child: master,
        ),
        // Divider
        if (showDivider) const VerticalDivider(width: 1),
        // Detail panel
        Expanded(
          flex: detailFlex,
          child: detail ??
              detailPlaceholder ??
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Pilih item untuk melihat detail',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
        ),
      ],
    );
  }
}
