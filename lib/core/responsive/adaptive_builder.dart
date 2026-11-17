import 'package:flutter/material.dart';
import 'screen_breakpoints.dart';

enum DeviceScreenType { mobile, tablet, desktop }

class AdaptiveBuilder extends StatelessWidget {
  const AdaptiveBuilder({super.key, required this.builder});

  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    DeviceScreenType screenType,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = ScreenBreakpoints.isDesktop(constraints.maxWidth)
            ? DeviceScreenType.desktop
            : ScreenBreakpoints.isTablet(constraints.maxWidth)
            ? DeviceScreenType.tablet
            : DeviceScreenType.mobile;

        return builder(context, constraints, screenType);
      },
    );
  }
}
