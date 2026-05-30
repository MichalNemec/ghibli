import 'package:flutter/material.dart';

/// Extension for [Color]
extension EColor on Color {
  /// Calculates contrast color for texts.
  Color get contrastColor {
    final hsl = HSLColor.fromColor(this);
    final isDark = hsl.lightness < 0.5;
    return HSLColor.fromAHSL(
      1,
      (hsl.hue + 180) % 360,
      isDark ? hsl.saturation.clamp(0.2, 0.5) : 0.15,
      isDark ? 0.88 : 0.08,
    ).toColor();
  }

  /// Calculates color based on hash
  static Color hashColor(String id) {
    final hash = id.hashCode;
    return Colors.primaries[hash.abs() % Colors.primaries.length];
  }
}
