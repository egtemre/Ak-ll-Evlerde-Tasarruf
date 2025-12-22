import '../repositories/energy_repository.dart';
import '../models/recommendation.dart';

/// Enerji tüketim analiz servisi
/// İstatistikler, anomaliler, trendler ve karşılaştırmalar
class EnergyAnalyticsService {
  final EnergyRepository _repository = EnergyRepository();

  /// Son 7 günün saatlik ortalama tüketimini hesapla
  Future<Map<int, double>> getHourlyAverageConsumption() async {
    final readings = await _repository.getAllReadings();
    final Map<int, List<double>> hourlyData = {};

    for (final reading in readings) {
      final date = DateTime.parse(reading.timestamp);
      final hour = date.hour;

      if (!hourlyData.containsKey(hour)) {
        hourlyData[hour] = [];
      }
      hourlyData[hour]!.add(reading.totalKwh);
    }

    // Ortalamaları hesapla
    final Map<int, double> averages = {};
    hourlyData.forEach((hour, values) {
      averages[hour] = values.reduce((a, b) => a + b) / values.length;
    });

    return averages;
  }

  /// Günlük karşılaştırma - Bugün vs Dün
  Future<Map<String, dynamic>> getDailyComparison() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayReadings = await _repository.getReadingsByDateRange(
      today,
      today.add(const Duration(days: 1)),
    );

    final yesterdayReadings = await _repository.getReadingsByDateRange(
      yesterday,
      today,
    );

    final todayTotal = todayReadings.fold(0.0, (sum, r) => sum + r.totalKwh);
    final yesterdayTotal =
        yesterdayReadings.fold(0.0, (sum, r) => sum + r.totalKwh);

    final change = yesterdayTotal > 0
        ? ((todayTotal - yesterdayTotal) / yesterdayTotal * 100)
        : 0.0;

    return {
      'today': todayTotal,
      'yesterday': yesterdayTotal,
      'changePercent': change,
      'isIncrease': change > 0,
      'message': _getComparisonMessage(change),
    };
  }

  /// Haftalık trend analizi
  Future<Map<String, dynamic>> getWeeklyTrend() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final readings = await _repository.getReadingsByDateRange(weekAgo, now);

    // Günlük toplamları hesapla
    final Map<DateTime, double> dailyTotals = {};

    for (final reading in readings) {
      final date = DateTime.parse(reading.timestamp);
      final dayKey = DateTime(date.year, date.month, date.day);

      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0.0) + reading.totalKwh;
    }

    // Trend hesapla (lineer regresyon benzeri basit yaklaşım)
    final values = dailyTotals.values.toList();
    if (values.length < 2) {
      return {
        'trend': 'stable',
        'message': 'Yeterli veri yok',
        'dailyTotals': dailyTotals,
      };
    }

    final firstHalf = values.take(values.length ~/ 2).toList();
    final secondHalf = values.skip(values.length ~/ 2).toList();

    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

    String trend;
    String message;

    if (secondAvg > firstAvg * 1.05) {
      trend = 'increasing';
      message = 'Tüketiminiz artış trendinde 📈';
    } else if (secondAvg < firstAvg * 0.95) {
      trend = 'decreasing';
      message = 'Tüketiminiz azalış trendinde 📉 Harika!';
    } else {
      trend = 'stable';
      message = 'Tüketiminiz stabil 📊';
    }

    return {
      'trend': trend,
      'message': message,
      'firstHalfAvg': firstAvg,
      'secondHalfAvg': secondAvg,
      'dailyTotals': dailyTotals,
    };
  }

  /// Anomali tespiti - Normalin dışında tüketimler
  Future<List<Map<String, dynamic>>> detectAnomalies() async {
    final readings = await _repository.getLastReadings(168); // Son 7 gün

    if (readings.length < 24) {
      return [];
    }

    // Ortalama ve standart sapma hesapla
    final values = readings.map((r) => r.totalKwh).toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) /
            values.length;
    final stdDev = variance > 0 ? variance : 0.0;

    // Z-score > 2 olanları anomali say
    final anomalies = <Map<String, dynamic>>[];

    for (final reading in readings) {
      final zScore = stdDev > 0 ? (reading.totalKwh - mean).abs() / stdDev : 0;

      if (zScore > 2.0) {
        anomalies.add({
          'reading': reading,
          'zScore': zScore,
          'deviation':
              ((reading.totalKwh - mean) / mean * 100).toStringAsFixed(1),
          'message': reading.totalKwh > mean
              ? '⚠️ Yüksek tüketim tespit edildi'
              : '✅ Normalden düşük tüketim',
        });
      }
    }

    return anomalies;
  }

  /// Akıllı öneriler oluştur
  Future<List<Recommendation>> generateSmartRecommendations() async {
    final recommendations = <Recommendation>[];
    final now = DateTime.now();

    // Günlük karşılaştırma yap
    final comparison = await getDailyComparison();

    if (comparison['changePercent'] > 20) {
      recommendations.add(Recommendation(
        buildingId: 1,
        generatedAt: now.toIso8601String(),
        description:
            'Bugün normalden %${comparison['changePercent'].toStringAsFixed(0)} '
            'daha fazla enerji kullandınız. Klima veya ısıtıcı ayarlarınızı kontrol edin.',
        estimatedSavingsKwh: comparison['today'] * 0.15,
        appliedStatus: 0,
      ));
    }

    // Saatlik analiz yap
    final hourlyAvg = await getHourlyAverageConsumption();
    final peakHour =
        hourlyAvg.entries.reduce((a, b) => a.value > b.value ? a : b);

    if (peakHour.value > 3.0) {
      recommendations.add(Recommendation(
        buildingId: 1,
        generatedAt: now.toIso8601String(),
        description:
            'Saat ${peakHour.key}:00\'da pik tüketim yaşanıyor (${peakHour.value.toStringAsFixed(1)} kWh). '
            'Bu saatlerde ağır cihazları kullanmaktan kaçının.',
        estimatedSavingsKwh: peakHour.value * 0.2,
        appliedStatus: 0,
      ));
    }

    // Anomali kontrolü
    final anomalies = await detectAnomalies();
    if (anomalies.length > 3) {
      recommendations.add(Recommendation(
        buildingId: 1,
        generatedAt: now.toIso8601String(),
        description:
            'Son 7 günde ${anomalies.length} anormal tüketim tespit edildi. '
            'Cihazlarınızın enerji verimliliğini kontrol ettirin.',
        estimatedSavingsKwh: 50.0,
        appliedStatus: 0,
      ));
    }

    return recommendations;
  }

  /// Tasarruf potansiyeli hesapla
  Future<Map<String, dynamic>> calculateSavingsPotential() async {
    final readings = await _repository.getLastReadings(168); // 7 gün

    if (readings.isEmpty) {
      return {
        'potential': 0.0,
        'percentage': 0.0,
        'message': 'Veri yetersiz',
      };
    }

    final totalConsumption = readings.fold(0.0, (sum, r) => sum + r.totalKwh);

    // %15-20 tasarruf potansiyeli (literatür ortalaması)
    final savingsPotential = totalConsumption * 0.17;
    const percentage = 17.0;

    return {
      'potential': savingsPotential,
      'percentage': percentage,
      'message':
          'Optimizasyonlarla haftada ${savingsPotential.toStringAsFixed(1)} kWh tasarruf edebilirsiniz',
      'monthlySavings': (savingsPotential * 4.3).toStringAsFixed(0), // Aylık
      'costSavings':
          (savingsPotential * 4.3 * 3.5).toStringAsFixed(0), // TL (3.5 TL/kWh)
    };
  }

  String _getComparisonMessage(double changePercent) {
    if (changePercent > 20) {
      return 'Dikkat! Dünden çok daha fazla tüketim var 🔴';
    } else if (changePercent > 10) {
      return 'Dünden biraz daha fazla tüketim ⚠️';
    } else if (changePercent > -10) {
      return 'Düne benzer bir tüketim 📊';
    } else if (changePercent > -20) {
      return 'Dünden biraz daha az tüketim ✅';
    } else {
      return 'Harika! Dünden çok daha az tüketim 🎉';
    }
  }

  /// Maliyet hesapla (TL)
  double calculateCost(double kWh, {double pricePerKwh = 3.5}) {
    return kWh * pricePerKwh;
  }

  /// CO2 emisyonu hesapla (kg)
  double calculateCO2Emission(double kWh) {
    // Türkiye elektrik üretimi ortalama: 0.45 kg CO2/kWh
    return kWh * 0.45;
  }
}
