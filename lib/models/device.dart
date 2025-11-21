class Device {
  final int? deviceId;
  final int buildingId;
  final String name;
  final String type;
  final String? installedAt;
  final String? status;

  Device({
    this.deviceId,
    required this.buildingId,
    required this.name,
    required this.type,
    this.installedAt,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'device_id': deviceId,
      'building_id': buildingId,
      'name': name,
      'type': type,
      'installed_at': installedAt,
      'status': status,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      deviceId: map['device_id'],
      buildingId: map['building_id'],
      name: map['name'],
      type: map['type'],
      installedAt: map['installed_at'],
      status: map['status'],
    );
  }
}
