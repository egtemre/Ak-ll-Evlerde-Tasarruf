import '../services/database_helper.dart';
import '../models/energy_reading.dart';
import '../models/device.dart';
import '../models/recommendation.dart';

/// Veritabanı işlemlerini yöneten repository katmanı
/// Bu katman, UI'dan database'i ayırır (Clean Architecture)
class EnergyRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ============= ENERGY READINGS =============

  /// Tüm enerji okumalarını getir (tarih sıralı)
  Future<List<EnergyReading>> getAllReadings() async {
    return await _db.readAllReadings();
  }

  /// Belirli tarih aralığındaki okumaları getir
  Future<List<EnergyReading>> getReadingsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allReadings = await _db.readAllReadings();
    return allReadings.where((reading) {
      final readingDate = DateTime.parse(reading.timestamp);
      return readingDate.isAfter(startDate) && readingDate.isBefore(endDate);
    }).toList();
  }

  /// Bugünün enerji okumalarını getir
  Future<List<EnergyReading>> getTodayReadings() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return await getReadingsByDateRange(startOfDay, endOfDay);
  }

  /// Yeni enerji okuması ekle
  Future<EnergyReading> addReading(EnergyReading reading) async {
    return await _db.createReading(reading);
  }

  /// Son okumaları al (limit sayısı kadar)
  Future<List<EnergyReading>> getLastReadings(int limit) async {
    final allReadings = await _db.readAllReadings();
    return allReadings.take(limit).toList();
  }

  // ============= DEVICES =============

  /// Tüm cihazları getir
  Future<List<Device>> getAllDevices() async {
    return await _db.readAllDevices();
  }

  /// Yeni cihaz ekle
  Future<Device> addDevice(Device device) async {
    return await _db.createDevice(device);
  }

  /// Cihaz durumunu güncelle (açık/kapalı)
  Future<void> updateDeviceStatus(int deviceId, String status) async {
    await _db.updateDeviceStatus(deviceId, status);
  }

  /// Cihazı sil
  Future<void> deleteDevice(int deviceId) async {
    await _db.deleteDevice(deviceId);
  }

  // ============= RECOMMENDATIONS =============

  /// Tüm önerileri getir
  Future<List<Recommendation>> getAllRecommendations() async {
    return await _db.readAllRecommendations();
  }

  /// Uygulanmamış önerileri getir
  Future<List<Recommendation>> getPendingRecommendations() async {
    final allRecommendations = await _db.readAllRecommendations();
    return allRecommendations.where((r) => r.appliedStatus == 0).toList();
  }

  /// Öneri ekle
  Future<Recommendation> addRecommendation(
      Recommendation recommendation) async {
    return await _db.createRecommendation(recommendation);
  }

  /// Öneriyi uygula olarak işaretle
  Future<void> applyRecommendation(int recommendationId) async {
    await _db.updateRecommendationStatus(recommendationId, 1);
  }

  // ============= İSTATİSTİKLER =============

  /// Toplam tüketimi hesapla (kWh)
  Future<double> getTotalConsumption() async {
    final readings = await _db.readAllReadings();
    return readings.fold<double>(0.0, (sum, reading) => sum + reading.totalKwh);
  }

  /// Günlük ortalama tüketim
  Future<double> getDailyAverageConsumption() async {
    final readings = await _db.readAllReadings();
    if (readings.isEmpty) return 0.0;

    final total = readings.fold<double>(0.0, (sum, r) => sum + r.totalKwh);
    final days = readings.length / 24; // Saatlik veri varsayımı
    return total / days;
  }

  /// En yüksek tüketim
  Future<double> getMaxConsumption() async {
    final readings = await _db.readAllReadings();
    if (readings.isEmpty) return 0.0;
    return readings.map((r) => r.totalKwh).reduce((a, b) => a > b ? a : b);
  }

  /// Veritabanını CSV verisiyle doldur
  Future<void> seedDatabaseFromCSV() async {
    // Bu metod, CSV'den veritabanını doldurmak için kullanılacak
    // Şimdilik boş, CSV okuma işlemi eklenecek
  }
}
