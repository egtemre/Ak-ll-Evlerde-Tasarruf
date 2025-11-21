import 'package:flutter/material.dart';

class UISavingSuggestion {
  final String deviceName;
  final String suggestion;
  final double monthlySaving;
  final bool isApplied;
  final IconData icon;

  UISavingSuggestion({
    required this.deviceName,
    required this.suggestion,
    required this.monthlySaving,
    required this.isApplied,
    required this.icon,
  });

  UISavingSuggestion copyWith({
    String? deviceName,
    String? suggestion,
    double? monthlySaving,
    bool? isApplied,
    IconData? icon,
  }) {
    return UISavingSuggestion(
      deviceName: deviceName ?? this.deviceName,
      suggestion: suggestion ?? this.suggestion,
      monthlySaving: monthlySaving ?? this.monthlySaving,
      isApplied: isApplied ?? this.isApplied,
      icon: icon ?? this.icon,
    );
  }
}
