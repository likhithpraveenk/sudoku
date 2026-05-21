import 'package:flutter/material.dart';

class ThemeConfig {
  const ThemeConfig({required this.seedColor, this.brightness = .dark});

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      seedColor: Color(json['seedColor'] as int),
      brightness: json['brightness'] == 'light' ? .light : .dark,
    );
  }

  final Color seedColor;

  final Brightness brightness;

  static const builtIn = [
    // Lavender Dusk
    ThemeConfig(seedColor: Color(0xFF7C5CBF)),

    // Sage Mist
    ThemeConfig(seedColor: Color(0xFF5A8A6A)),

    // Dusty Rose
    ThemeConfig(seedColor: Color(0xFFA8606B), brightness: .light),

    // Slate Blue
    ThemeConfig(seedColor: Color(0xFF4A6FA5)),

    // Warm Amber
    ThemeConfig(seedColor: Color(0xFFB07840), brightness: .light),

    // Seafoam
    ThemeConfig(seedColor: Color(0xFF4A8A80)),

    // Mauve
    ThemeConfig(seedColor: Color(0xFF8A5A7C)),

    // Steel Teal
    ThemeConfig(seedColor: Color(0xFF4A7A8A)),

    // Terracotta
    ThemeConfig(seedColor: Color(0xFF9A5A45), brightness: .light),

    // Periwinkle
    ThemeConfig(seedColor: Color(0xFF5A6AAF)),
  ];

  Map<String, dynamic> toJson() => {
    'seedColor': seedColor.toARGB32(),
    'brightness': brightness.name,
  };
}
