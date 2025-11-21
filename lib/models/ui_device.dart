import 'package:flutter/material.dart';

enum DeviceType { light, airConditioner, refrigerator, tv, washingMachine }

class UIDevice {
  final String id;
  final String name;
  final DeviceType type;
  final bool isOn;
  final double consumption;
  final int scheduledTasks;

  UIDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.isOn,
    required this.consumption,
    required this.scheduledTasks,
  });

  UIDevice copyWith({
    String? id,
    String? name,
    DeviceType? type,
    bool? isOn,
    double? consumption,
    int? scheduledTasks,
  }) {
    return UIDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isOn: isOn ?? this.isOn,
      consumption: consumption ?? this.consumption,
      scheduledTasks: scheduledTasks ?? this.scheduledTasks,
    );
  }

  IconData get icon {
    switch (type) {
      case DeviceType.light:
        return Icons.lightbulb;
      case DeviceType.airConditioner:
        return Icons.ac_unit;
      case DeviceType.refrigerator:
        return Icons.kitchen;
      case DeviceType.tv:
        return Icons.tv;
      case DeviceType.washingMachine:
        return Icons.local_laundry_service;
    }
  }

  Color get iconColor {
    switch (type) {
      case DeviceType.light:
        return Colors.yellow;
      case DeviceType.airConditioner:
        return Colors.blue;
      case DeviceType.refrigerator:
        return Colors.grey;
      case DeviceType.tv:
        return Colors.purple;
      case DeviceType.washingMachine:
        return Colors.green;
    }
  }
}
