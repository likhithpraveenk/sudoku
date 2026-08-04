import 'package:flutter/material.dart';

const builtInThemes = [
  ThemeConfig(seedColor: Color(0xFF1C0420)),
  ThemeConfig(seedColor: Color(0xFF7C5CBF)),
  ThemeConfig(seedColor: Color(0xFF5A8A6A)),
  ThemeConfig(seedColor: Color(0xFFB07840), brightness: .light),
  ThemeConfig(seedColor: Color(0xFF4A6FA5)),
  ThemeConfig(seedColor: Color(0xFFA8606B), brightness: .light),
  ThemeConfig(seedColor: Color(0xFF4A8A80)),
  ThemeConfig(seedColor: Color(0xFF8A5A7C)),
  ThemeConfig(seedColor: Color(0xFF4A7A8A)),
  ThemeConfig(seedColor: Color(0xFF9A5A45), brightness: .light),
  ThemeConfig(seedColor: Color(0xFF5A6AAF)),
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

  @override
  String toString() {
    return 'ThemeConfig(${seedColor.toHex()}, ${brightness.name})';
  }
}

extension ColorExtensions on Color {
  String toHex() {
    final argb = toARGB32();
    return '#${argb.toRadixString(16).padLeft(8, '0')}'.toUpperCase();
  }

  String toHexNoAlpha({bool addHash = false}) {
    final argb = toARGB32();
    final result = (argb & 0xFFFFFF)
        .toRadixString(16)
        .padLeft(6, '0')
        .toUpperCase();
    return addHash ? '#$result' : result;
  }

  static Color fromHex(String hex) {
    final string = hex.replaceFirst('#', '');
    return switch (string.length) {
      3 => Color.fromARGB(
        255,
        int.parse(string[0] + string[0], radix: 16),
        int.parse(string[1] + string[1], radix: 16),
        int.parse(string[2] + string[2], radix: 16),
      ),
      6 => Color.fromARGB(
        255,
        int.parse(string.substring(0, 2), radix: 16),
        int.parse(string.substring(2, 4), radix: 16),
        int.parse(string.substring(4, 6), radix: 16),
      ),
      8 => Color.fromARGB(
        int.parse(string.substring(0, 2), radix: 16),
        int.parse(string.substring(2, 4), radix: 16),
        int.parse(string.substring(4, 6), radix: 16),
        int.parse(string.substring(6, 8), radix: 16),
      ),
      _ => throw FormatException('Invalid hex color: $hex'),
    };
  }
}
