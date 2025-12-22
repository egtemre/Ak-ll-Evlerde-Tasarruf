import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/energy_reading.dart';
import '../repositories/energy_repository.dart';

/// CSV dosyasından veri okuma ve veritabanına aktarma servisi
/// Bu servis, SmartHome_Energy_Weather_Combined.csv dosyasını okur
class CSVImportService {
  final EnergyRepository _repository = EnergyRepository();

  /// CSV dosyasını oku ve veritabanına aktar
  /// [assetPath] CSV dosyasının asset yolu
  /// [maxRows] Maksimum okunacak satır sayısı (performans için)
  Future<int> importFromAsset(String assetPath, {int maxRows = 1000}) async {
    try {
      // CSV dosyasını oku
      final csvString = await rootBundle.loadString(assetPath);
      final lines = const LineSplitter().convert(csvString);

      if (lines.isEmpty) return 0;

      // Header'ı atla
      final dataLines = lines.skip(1).take(maxRows).toList();
      int importedCount = 0;

      for (final line in dataLines) {
        try {
          final reading = _parseCSVLine(line);
          if (reading != null) {
            await _repository.addReading(reading);
            importedCount++;
          }
        } catch (e) {
          // Hatalı satırı atla, devam et
          continue;
        }
      }

      return importedCount;
    } catch (e) {
      throw Exception('CSV import hatası: $e');
    }
  }

  /// CSV satırını EnergyReading nesnesine çevir
  EnergyReading? _parseCSVLine(String line) {
    try {
      final parts = line.split(',');

      if (parts.length < 19) return null;

      // CSV formatı:
      // DateTime,Global_active_power,Global_reactive_power,Voltage,Global_intensity,
      // Sub_metering_1,Sub_metering_2,Sub_metering_3,Hour,Day,Month,DayOfWeek,
      // IsWeekend,Quarter,Season,Total_Sub_metering,Temperature,Humidity,Precipitation

      return EnergyReading(
        buildingId: 1,
        timestamp: parts[0], // DateTime
        totalKwh: double.parse(parts[1]), // Global_active_power
        subM3Hvac: double.parse(parts[2]), // Global_reactive_power
        outdoorTemp: double.parse(parts[16]), // Temperature
        compYesterdayPct: 0.0, // Hesaplanacak
        mlPredictionKwh: null, // ML tahmini sonra eklenecek
      );
    } catch (e) {
      return null;
    }
  }

  /// Son 7 günlük veriyi al (simüle et)
  Future<List<EnergyReading>> getSimulatedWeekData() async {
    final readings = <EnergyReading>[];
    final now = DateTime.now();

    // Her gün için 24 saat veri oluştur
    for (int day = 6; day >= 0; day--) {
      for (int hour = 0; hour < 24; hour++) {
        final timestamp = now.subtract(Duration(days: day, hours: 24 - hour));

        // Saate göre gerçekçi tüketim değerleri
        double consumption = _getRealisticConsumption(hour);

        readings.add(EnergyReading(
          buildingId: 1,
          timestamp: timestamp.toIso8601String(),
          totalKwh: consumption,
          subM3Hvac: consumption * 0.3, // HVAC yaklaşık %30
          outdoorTemp: 20.0 + (hour * 0.5) - 5.0, // Sıcaklık simülasyonu
          compYesterdayPct: 0.0,
          mlPredictionKwh: null,
        ));
      }
    }

    return readings;
  }

  /// Saate göre gerçekçi tüketim değeri
  double _getRealisticConsumption(int hour) {
    // Gece (00-06): Düşük tüketim
    if (hour >= 0 && hour < 6) {
      return 0.8 + (hour * 0.1);
    }
    // Sabah (06-09): Artış
    else if (hour >= 6 && hour < 9) {
      return 1.5 + (hour - 6) * 0.5;
    }
    // Gündüz (09-18): Orta-Yüksek
    else if (hour >= 9 && hour < 18) {
      return 2.5 + (hour % 2) * 0.3;
    }
    // Akşam (18-21): Pik saat
    else if (hour >= 18 && hour < 21) {
      return 3.5 + (hour - 18) * 0.2;
    }
    // Gece (21-24): Düşüş
    else {
      return 2.0 - (hour - 21) * 0.3;
    }
  }

  /// Veritabanını gerçekçi verilerle doldur
  Future<void> seedRealisticData() async {
    // Tüm evler için veri oluştur (building_id 1-5)
    for (int buildingId = 1; buildingId <= 5; buildingId++) {
      final readings = await getSimulatedWeekDataForBuilding(buildingId);

      for (final reading in readings) {
        await _repository.addReading(reading);
      }
    }
  }

  /// Belirli bir ev için son 7 günlük veri oluştur
  Future<List<EnergyReading>> getSimulatedWeekDataForBuilding(
      int buildingId) async {
    final readings = <EnergyReading>[];
    final now = DateTime.now();

    // Her ev için farklı tüketim çarpanı
    final consumptionMultiplier = _getBuildingMultiplier(buildingId);

    // Her gün için 24 saat veri oluştur
    for (int day = 6; day >= 0; day--) {
      for (int hour = 0; hour < 24; hour++) {
        final timestamp = now.subtract(Duration(days: day, hours: 24 - hour));

        // Saate göre gerçekçi tüketim değerleri
        double consumption =
            _getRealisticConsumption(hour) * consumptionMultiplier;

        readings.add(EnergyReading(
          buildingId: buildingId,
          timestamp: timestamp.toIso8601String(),
          totalKwh: consumption,
          subM3Hvac: consumption * 0.3, // HVAC yaklaşık %30
          outdoorTemp: 20.0 + (hour * 0.5) - 5.0, // Sıcaklık simülasyonu
          compYesterdayPct: 0.0,
          mlPredictionKwh: null,
        ));
      }
    }

    return readings;
  }

  /// Ev bazlı tüketim çarpanı
  double _getBuildingMultiplier(int buildingId) {
    switch (buildingId) {
      case 1:
        return 1.0; // Emre'nin Evi - Normal
      case 2:
        return 0.8; // Ayşe'nin Evi - Düşük
      case 3:
        return 1.2; // Mehmet'in Evi - Yüksek
      case 4:
        return 0.5; // Mehmet'in Yazlık Evi - Çok düşük (boş)
      case 5:
        return 0.9; // Zeynep'in Dairesi - Normal-Düşük
      default:
        return 1.0;
    }
  }
}
