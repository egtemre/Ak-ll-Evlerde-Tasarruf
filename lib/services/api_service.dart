import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/feature_vector.dart';
import '../models/ml_prediction.dart';

class ApiService {
  // ML Model API base URL
  // Android emülatör için: 10.0.2.2:8000
  // iOS simülatör için: localhost:8000
  // Gerçek cihaz için: Bilgisayarınızın IP adresi (örn: 192.168.1.100:8000)
  // Production için: Gerçek sunucu URL'i
  static const String _baseUrl = 'http://10.0.2.2:8000'; // Android emülatör için
  // static const String _baseUrl = 'http://localhost:8000'; // iOS simülatör için
  // static const String _baseUrl = 'http://192.168.1.100:8000'; // Gerçek cihaz için (IP'yi değiştirin)

  // Model meta bilgilerini getir
  Future<ModelMeta?> getModelMeta() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/meta'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ModelMeta.fromJson(data);
      } else {
        debugPrint('Failed to get model meta. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting model meta: $e');
      return null;
    }
  }

  // Tek tahmin yap
  Future<MLPrediction?> predict(FeatureVector features) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'x': features.toJson()}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MLPrediction.fromJson(data);
      } else {
        debugPrint('Failed to get prediction. Status code: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting prediction: $e');
      return null;
    }
  }

  // Çoklu tahmin yap
  Future<MLPredictionMany?> predictMany(List<FeatureVector> features) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict_many'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'rows': features.map((f) => f.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MLPredictionMany.fromJson(data);
      } else {
        debugPrint('Failed to get predictions. Status code: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting predictions: $e');
      return null;
    }
  }

  // Mevcut enerji verilerinden tahmin için özellik vektörü oluştur
  // ModelHepsi.txt'deki spesifikasyonlara göre tam uyumlu
  // (Gerçek uygulamada bu veriler sensörlerden veya veritabanından gelecek)
  FeatureVector createFeatureVectorFromCurrentData({
    required double currentPower,
    required double prevHourPower,
    required double prevDayPower,
    required double temperature,
    required double humidity,
    required double voltage,
    required double globalIntensity,
    required double subMetering1,
    required double subMetering2,
    required double subMetering3,
  }) {
    final now = DateTime.now();
    
    // DayOfWeek: Python dayofweek (0=Pazartesi, 6=Pazar) 
    // Flutter weekday (1=Pazartesi, 7=Pazar) -> 1 çıkararak uyumlu hale getir
    final dayOfWeek = now.weekday - 1; // 0-6 arası
    
    // IsWeekend: Python'da dayofweek >= 5 (Cumartesi=5, Pazar=6)
    final isWeekend = (dayOfWeek >= 5) ? 1 : 0;
    
    // Mevsim hesaplama - ModelHepsi.txt'ye göre:
    // 12,1,2: 0 (Kış), 3,4,5: 1 (İlkbahar), 6,7,8: 2 (Yaz), else: 3 (Sonbahar)
    int season;
    final month = now.month;
    if (month == 12 || month == 1 || month == 2) {
      season = 0; // Kış
    } else if (month >= 3 && month <= 5) {
      season = 1; // İlkbahar
    } else if (month >= 6 && month <= 8) {
      season = 2; // Yaz
    } else {
      season = 3; // Sonbahar
    }

    // Zaman dilimi - ModelHepsi.txt'ye göre:
    // 6 <= hour < 12: 0, 12 <= hour < 18: 1, 18 <= hour < 23: 2, else: 3
    int timeOfDay;
    final hour = now.hour;
    if (hour >= 6 && hour < 12) {
      timeOfDay = 0;
    } else if (hour >= 12 && hour < 18) {
      timeOfDay = 1;
    } else if (hour >= 18 && hour < 23) {
      timeOfDay = 2;
    } else {
      timeOfDay = 3;
    }

    // Sıcaklık kategorisi - ModelHepsi.txt'ye göre:
    // <10: 0, <18: 1, <25: 2, <30: 3, else: 4
    int tempCategory;
    if (temperature < 10) {
      tempCategory = 0;
    } else if (temperature < 18) {
      tempCategory = 1;
    } else if (temperature < 25) {
      tempCategory = 2;
    } else if (temperature < 30) {
      tempCategory = 3;
    } else {
      tempCategory = 4;
    }

    // Basit rolling mean ve std hesaplama (gerçek uygulamada daha karmaşık olabilir)
    final rollingMean24h = (currentPower + prevHourPower) / 2;
    final rollingStd24h = (currentPower - prevHourPower).abs();

    return FeatureVector(
      hour: hour,
      dayOfWeek: dayOfWeek, // 0-6 arası (Python dayofweek ile uyumlu)
      month: month,
      isWeekend: isWeekend,
      season: season,
      timeOfDay: timeOfDay,
      prevHourPower: prevHourPower,
      prev2HourPower: prevHourPower * 0.95, // Tahmini (gerçek uygulamada shift(2) olacak)
      prevDayPower: prevDayPower,
      rollingMean24h: rollingMean24h,
      rollingStd24h: rollingStd24h,
      temperature: temperature,
      humidity: humidity,
      tempCategory: tempCategory,
      prevHourTemp: temperature * 0.98, // Tahmini (gerçek uygulamada shift(1) olacak)
      subMetering1: subMetering1,
      subMetering2: subMetering2,
      subMetering3: subMetering3,
      voltage: voltage,
      globalIntensity: globalIntensity,
    );
  }
}
