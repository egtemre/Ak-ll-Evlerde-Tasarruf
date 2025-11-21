class Recommendation {
  final int? id;
  final int buildingId;
  final String generatedAt;
  final String description;
  final double? estimatedSavingsKwh;
  final int? appliedStatus;

  Recommendation({
    this.id,
    required this.buildingId,
    required this.generatedAt,
    required this.description,
    this.estimatedSavingsKwh,
    this.appliedStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'building_id': buildingId,
      'generated_at': generatedAt,
      'description': description,
      'estimated_savings_kwh': estimatedSavingsKwh,
      'applied_status': appliedStatus,
    };
  }

  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      id: map['id'],
      buildingId: map['building_id'],
      generatedAt: map['generated_at'],
      description: map['description'],
      estimatedSavingsKwh: map['estimated_savings_kwh'],
      appliedStatus: map['applied_status'],
    );
  }
}
