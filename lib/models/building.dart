class Building {
  final int? buildingId;
  final int userId;
  final String name;
  final String address;

  Building({
    this.buildingId,
    required this.userId,
    required this.name,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'building_id': buildingId,
      'user_id': userId,
      'name': name,
      'address': address,
    };
  }

  factory Building.fromMap(Map<String, dynamic> map) {
    return Building(
      buildingId: map['building_id'],
      userId: map['user_id'],
      name: map['name'],
      address: map['address'],
    );
  }
}
