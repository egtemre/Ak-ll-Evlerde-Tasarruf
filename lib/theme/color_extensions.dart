import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Color withValues({
    int? alpha,
    int? red,
    int? green,
    int? blue,
  }) {
    // Flutter 3.24.5 için eski Color API
    final a = alpha ?? this.alpha;
    final r = red ?? this.red;
    final g = green ?? this.green;
    final b = blue ?? this.blue;
    return Color.fromARGB(a, r, g, b);
  }
}
