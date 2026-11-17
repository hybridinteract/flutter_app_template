import 'package:flutter/material.dart';
import 'screen_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ScreenBreakpoints.isDesktop(constraints.maxWidth)) {
          return desktop ?? tablet ?? mobile;
        } else if (ScreenBreakpoints.isTablet(constraints.maxWidth)) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
