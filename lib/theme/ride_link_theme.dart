import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

class RideLinkTheme {
  static const FColors lightColors = FColors(
    brightness: Brightness.light,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    barrier: Color(0x33000000),
    background: Color(0xFFF7FAF3),
    foreground: Color(0xFF181D18),
    primary: Color(0xFF005127),
    primaryForeground: Color(0xFFFFFFFF),
    secondary: Color(0xFF835500),
    secondaryForeground: Color(0xFFFFFFFF),
    muted: Color(0xFFE0E4DD),
    mutedForeground: Color(0xFF404940),
    destructive: Color(0xFFBA1A1A),
    destructiveForeground: Color(0xFFFFFFFF),
    error: Color(0xFFBA1A1A),
    errorForeground: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFBFC9BD),
  );

  static final FTypography lightTypography =
      FThemes.neutral.light.touch.typography;

  static final FThemeData light = FThemeData(
    colors: lightColors,
    typography: lightTypography,
    touch: true,
  );

  static final FThemeData dark = FThemeData(
    colors: FThemes.neutral.dark.touch.colors,
    typography: FThemes.neutral.dark.touch.typography,
    touch: true,
  );
}
