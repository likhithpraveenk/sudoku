import 'package:flutter/material.dart';

/// [ThemeConfig] definition.
class ThemeConfig {
  /// Constructor for [ThemeConfig].
  const ThemeConfig({required this.seedColor, this.surfaceColor});

  /// Creates an instance of [ThemeConfig] from a JSON map.
  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      seedColor: Color(json['seed'] as int),
      surfaceColor: json['surface'] != null
          ? Color(json['surface'] as int)
          : null,
    );
  }

  /// The [seedColor] field.
  final Color seedColor;

  /// The [surfaceColor] field.
  final Color? surfaceColor;

  /// The [builtIn] field.
  static const builtIn = [
    ThemeConfig(seedColor: Color(0xFF2196F3)),
    ThemeConfig(seedColor: Color(0xFF4CAF50)),
    ThemeConfig(seedColor: Color(0xFFFF9800)),
    ThemeConfig(seedColor: Color(0xFFE91E63)),
    ThemeConfig(seedColor: Color(0xFF9C27B0)),
    ThemeConfig(seedColor: Color(0xFF00BCD4)),
    ThemeConfig(seedColor: Color(0xFF795548), surfaceColor: Color(0xFFF5F0EB)),
    ThemeConfig(seedColor: Color(0xFF607D8B), surfaceColor: Color(0xFFECEFF1)),
  ];

  /// A public member.
  Map<String, dynamic> toJson() => {
    'seed': seedColor.toARGB32(),
    'surface': surfaceColor?.toARGB32(),
  };
}
