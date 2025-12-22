class EnergyReading {
  final int? id;
  final int buildingId; // FK
  final String timestamp;
  final double totalKwh;
  final double? subM3Hvac;
  final double? outdoorTemp;
  final double? compYesterdayPct;
  final double? mlPredictionKwh;

  EnergyReading({
    this.id,
    required this.buildingId,
    required this.timestamp,
    required this.totalKwh,
    this.subM3Hvac,
    this.outdoorTemp,
    this.compYesterdayPct,
    this.mlPredictionKwh,
  });

  // Nesneden Map'e (Veritabanına Kayıt için)
  Map<String, dynamic> toMap() {
    return {
      'building_id': buildingId,
      'timestamp': timestamp,
      'total_kwh': totalKwh,
      'sub_m3_hvac': subM3Hvac,
      'outdoor_temp': outdoorTemp,
      'comp_yesterday_pct': compYesterdayPct,
      'ml_prediction_kwh': mlPredictionKwh,
    };
  }

  // Map'ten Nesneye (Veritabanından Okuma için)
  static EnergyReading fromMap(Map<String, dynamic> map) {
    return EnergyReading(
      id: map['id'] as int?,
      buildingId: map['building_id'] as int? ?? 0,
      timestamp:
          map['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      totalKwh: map['total_kwh'] as double? ?? 0.0,
      subM3Hvac: map['sub_m3_hvac'] as double?,
      outdoorTemp: map['outdoor_temp'] as double?,
      compYesterdayPct: map['comp_yesterday_pct'] as double?,
      mlPredictionKwh: map['ml_prediction_kwh'] as double?,
    );
  }
}
