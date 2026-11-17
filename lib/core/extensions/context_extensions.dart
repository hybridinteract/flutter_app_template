import 'package:flutter/material.dart';
import '../responsive/screen_breakpoints.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isMobile => ScreenBreakpoints.isMobile(screenWidth);
  bool get isTablet => ScreenBreakpoints.isTablet(screenWidth);
  bool get isDesktop => ScreenBreakpoints.isDesktop(screenWidth);

  /// False while another route is pushed on top of this one. Screens that
  /// stay mounted under a pushed route still receive BLoC states; listeners
  /// use this so only the visible screen navigates or shows a snackbar.
  bool get isCurrentRoute => ModalRoute.of(this)?.isCurrent ?? true;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
