import 'package:flutter/material.dart';

const builtInThemes = [
  ThemeConfig(seedColor: Color(0xFF7C5CBF)),
  ThemeConfig(seedColor: Color(0xFF5A8A6A)),
  ThemeConfig(seedColor: Color(0xFF4A6FA5)),
  ThemeConfig(seedColor: Color(0xFF4A8A80)),
  ThemeConfig(seedColor: Color(0xFF8A5A7C)),
  ThemeConfig(seedColor: Color(0xFF4A7A8A)),
  ThemeConfig(seedColor: Color(0xFF5A6AAF)),
  ThemeConfig(seedColor: Color(0xFFA8606B), brightness: .light),
  ThemeConfig(seedColor: Color(0xFFB07840), brightness: .light),
  ThemeConfig(seedColor: Color(0xFF9A5A45), brightness: .light),
];

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

  Map<String, dynamic> toJson() => {
    'seedColor': seedColor.toARGB32(),
    'brightness': brightness.name,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeConfig &&
          seedColor == other.seedColor &&
          brightness == other.brightness;

  @override
  int get hashCode => Object.hash(seedColor, brightness);
}
