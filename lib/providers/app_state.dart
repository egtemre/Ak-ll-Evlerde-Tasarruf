import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/feature_vector.dart';
import '../models/ml_prediction.dart';

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  int _currentIndex = 0;
  
  // Cihaz verileri
  final List<Device> _devices = [
    Device(
      id: '1',
      name: 'Salon Lambası',
      type: DeviceType.light,
      isOn: true,
      consumption: 0.8,
      scheduledTasks: 2,
    ),
    Device(
      id: '2',
      name: 'Yatak Odası Klima',
      type: DeviceType.airConditioner,
      isOn: false,
      consumption: 1.2,
      scheduledTasks: 0,
    ),
    Device(
      id: '3',
      name: 'Buzdolabı',
      type: DeviceType.refrigerator,
      isOn: true,
      consumption: 2.5,
      scheduledTasks: 0,
    ),
    Device(
      id: '4',
      name: 'Televizyon',
      type: DeviceType.tv,
      isOn: false,
      consumption: 0.5,
      scheduledTasks: 1,
    ),
  ];

  // Zaman filtresi
  String _selectedTimeFilter = 'Günlük'; // Günlük, Haftalık, Aylık

  // Enerji tüketim verileri - Günlük (saatlik)
  final List<EnergyData> _dailyEnergyData = [
    EnergyData(hour: '00', consumption: 2.1),
    EnergyData(hour: '03', consumption: 1.8),
    EnergyData(hour: '06', consumption: 1.2),
    EnergyData(hour: '09', consumption: 3.5),
    EnergyData(hour: '12', consumption: 0.8),
    EnergyData(hour: '15', consumption: 2.8),
    EnergyData(hour: '18', consumption: 0.9),
  ];

  // Haftalık veriler (günlük toplam)
  final List<EnergyData> _weeklyEnergyData = [
    EnergyData(hour: 'Pzt', consumption: 12.5),
    EnergyData(hour: 'Sal', consumption: 14.2),
    EnergyData(hour: 'Çar', consumption: 11.8),
    EnergyData(hour: 'Per', consumption: 13.5),
    EnergyData(hour: 'Cum', consumption: 15.2),
    EnergyData(hour: 'Cmt', consumption: 18.5),
    EnergyData(hour: 'Paz', consumption: 16.8),
  ];

  // Aylık veriler (haftalık toplam)
  final List<EnergyData> _monthlyEnergyData = [
    EnergyData(hour: '1. Hafta', consumption: 85.2),
    EnergyData(hour: '2. Hafta', consumption: 92.5),
    EnergyData(hour: '3. Hafta', consumption: 88.3),
    EnergyData(hour: '4. Hafta', consumption: 95.1),
  ];

  // ML Model servisi
  final ApiService _apiService = ApiService();

  // ML Tahmin verileri
  MLPrediction? _currentPrediction;
  bool _isLoadingPrediction = false;
  String? _predictionError;
  ModelMeta? _modelMeta;

  // Tasarruf önerileri
  final List<SavingSuggestion> _suggestions = [
    SavingSuggestion(
      deviceName: 'Oturma Odası Lambası',
      suggestion: 'Kullanılmadığında ışıkları kapatın.',
      monthlySaving: 15.0,
      isApplied: true,
      icon: Icons.lightbulb,
    ),
    SavingSuggestion(
      deviceName: 'Yatak Odası Kliması',
      suggestion: 'Yaz aylarında sıcaklığı 24°C\'ye ayarlayın.',
      monthlySaving: 45.0,
      isApplied: false,
      icon: Icons.ac_unit,
    ),
    SavingSuggestion(
      deviceName: 'Buzdolabı',
      suggestion: 'Buzdolabı sıcaklığını 4°C\'de tutun.',
      monthlySaving: 25.0,
      isApplied: false,
      icon: Icons.kitchen,
    ),
    SavingSuggestion(
      deviceName: 'Çamaşır Makinesi',
      suggestion: 'Çamaşırları soğuk suyla yıkayın.',
      monthlySaving: 30.0,
      isApplied: true,
      icon: Icons.local_laundry_service,
    ),
  ];

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  int get currentIndex => _currentIndex;
  List<Device> get devices => _devices;
  List<EnergyData> get energyData {
    switch (_selectedTimeFilter) {
      case 'Haftalık':
        return _weeklyEnergyData;
      case 'Aylık':
        return _monthlyEnergyData;
      default:
        return _dailyEnergyData;
    }
  }
  List<SavingSuggestion> get suggestions => _suggestions;
  String get selectedTimeFilter => _selectedTimeFilter;

  double get totalConsumption {
    final data = energyData;
    return data.fold(0.0, (sum, data) => sum + data.consumption);
  }
  double get estimatedMonthlySaving => 120.50;
  double get monthlyTarget => 250.0;
  double get currentMonthlySaving => 112.5;

  // ML Tahmin getters
  MLPrediction? get currentPrediction => _currentPrediction;
  bool get isLoadingPrediction => _isLoadingPrediction;
  String? get predictionError => _predictionError;
  ModelMeta? get modelMeta => _modelMeta;

  // Methods
  void login(String email, String name) {
    _isLoggedIn = true;
    _userEmail = email;
    _userName = name;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userEmail = '';
    _userName = '';
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setTimeFilter(String filter) {
    if (['Günlük', 'Haftalık', 'Aylık'].contains(filter)) {
      _selectedTimeFilter = filter;
      notifyListeners();
    }
  }

  void toggleDevice(String deviceId) {
    final deviceIndex = _devices.indexWhere((device) => device.id == deviceId);
    if (deviceIndex != -1) {
      _devices[deviceIndex] = _devices[deviceIndex].copyWith(
        isOn: !_devices[deviceIndex].isOn,
      );
      notifyListeners();
    }
  }

  void applySuggestion(int index) {
    if (index < _suggestions.length) {
      _suggestions[index] = _suggestions[index].copyWith(isApplied: true);
      notifyListeners();
    }
  }

  // ML Model tahmin metodları

  // Model meta bilgilerini yükle
  Future<void> loadModelMeta() async {
    try {
      _modelMeta = await _apiService.getModelMeta();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading model meta: $e');
    }
  }

  // Mevcut verilerle tahmin yap
  Future<void> predictCurrentEnergy() async {
    _isLoadingPrediction = true;
    _predictionError = null;
    notifyListeners();

    try {
      // Mevcut enerji verilerinden feature vector oluştur
      // Gerçek uygulamada bu veriler sensörlerden veya veritabanından gelecek
      final currentPower = totalConsumption;
      // Günlük verilerden önceki saat tüketimini al
      final dailyData = _dailyEnergyData;
      final prevHourPower = dailyData.isNotEmpty 
          ? dailyData.last.consumption 
          : 2.0;
      final prevDayPower = totalConsumption * 0.8; // Tahmini
      
      // Örnek sensör verileri (gerçek uygulamada sensörlerden gelecek)
      final temperature = 22.0; // °C
      final humidity = 60.0; // %
      final voltage = 240.0; // V
      final globalIntensity = 12.0; // A
      final subMetering1 = 0.5; // kWh
      final subMetering2 = 0.3; // kWh
      final subMetering3 = 1.2; // kWh

      final featureVector = _apiService.createFeatureVectorFromCurrentData(
        currentPower: currentPower,
        prevHourPower: prevHourPower,
        prevDayPower: prevDayPower,
        temperature: temperature,
        humidity: humidity,
        voltage: voltage,
        globalIntensity: globalIntensity,
        subMetering1: subMetering1,
        subMetering2: subMetering2,
        subMetering3: subMetering3,
      );

      final prediction = await _apiService.predict(featureVector);
      
      if (prediction != null) {
        _currentPrediction = prediction;
        _predictionError = null;
      } else {
        _predictionError = 'Tahmin alınamadı. API\'ye bağlanılamadı.';
      }
    } catch (e) {
      _predictionError = 'Tahmin yapılırken hata oluştu: $e';
      debugPrint('Prediction error: $e');
    } finally {
      _isLoadingPrediction = false;
      notifyListeners();
    }
  }

  // Gelecek saatler için tahmin yap (çoklu tahmin)
  Future<List<double>?> predictFutureHours(int hoursAhead) async {
    try {
      final List<FeatureVector> featureVectors = [];
      
      // Her saat için feature vector oluştur
      for (int i = 1; i <= hoursAhead; i++) {
        final futureTime = DateTime.now().add(Duration(hours: i));
        
        // DayOfWeek: Python dayofweek (0=Pazartesi, 6=Pazar) ile uyumlu
        final dayOfWeek = futureTime.weekday - 1; // 0-6 arası
        
        // IsWeekend: Python'da dayofweek >= 5 (Cumartesi=5, Pazar=6)
        final isWeekend = (dayOfWeek >= 5) ? 1 : 0;
        
        // Mevsim hesaplama - ModelHepsi.txt'ye göre:
        // 12,1,2: 0 (Kış), 3,4,5: 1 (İlkbahar), 6,7,8: 2 (Yaz), else: 3 (Sonbahar)
        int season;
        final month = futureTime.month;
        if (month == 12 || month == 1 || month == 2) {
          season = 0;
        } else if (month >= 3 && month <= 5) {
          season = 1;
        } else if (month >= 6 && month <= 8) {
          season = 2;
        } else {
          season = 3;
        }

        // Zaman dilimi - ModelHepsi.txt'ye göre:
        // 6 <= hour < 12: 0, 12 <= hour < 18: 1, 18 <= hour < 23: 2, else: 3
        int timeOfDay;
        final hour = futureTime.hour;
        if (hour >= 6 && hour < 12) {
          timeOfDay = 0;
        } else if (hour >= 12 && hour < 18) {
          timeOfDay = 1;
        } else if (hour >= 18 && hour < 23) {
          timeOfDay = 2;
        } else {
          timeOfDay = 3;
        }

        // Tahmini veriler (gerçek uygulamada daha gelişmiş hesaplamalar yapılabilir)
        final estimatedPower = totalConsumption * (1.0 + (i * 0.05));
        final estimatedTemp = 22.0 + (i * 0.1);
        
        // Sıcaklık kategorisi - ModelHepsi.txt'ye göre:
        // <10: 0, <18: 1, <25: 2, <30: 3, else: 4
        int tempCategory;
        if (estimatedTemp < 10) {
          tempCategory = 0;
        } else if (estimatedTemp < 18) {
          tempCategory = 1;
        } else if (estimatedTemp < 25) {
          tempCategory = 2;
        } else if (estimatedTemp < 30) {
          tempCategory = 3;
        } else {
          tempCategory = 4;
        }

        final featureVector = FeatureVector(
          hour: hour,
          dayOfWeek: dayOfWeek, // 0-6 arası (Python dayofweek ile uyumlu)
          month: month,
          isWeekend: isWeekend,
          season: season,
          timeOfDay: timeOfDay,
          prevHourPower: estimatedPower * 0.95,
          prev2HourPower: estimatedPower * 0.90,
          prevDayPower: totalConsumption * 0.8,
          rollingMean24h: estimatedPower,
          rollingStd24h: estimatedPower * 0.1,
          temperature: estimatedTemp,
          humidity: 60.0,
          tempCategory: tempCategory,
          prevHourTemp: estimatedTemp * 0.98,
          subMetering1: 0.5,
          subMetering2: 0.3,
          subMetering3: 1.2,
          voltage: 240.0,
          globalIntensity: 12.0,
        );

        featureVectors.add(featureVector);
      }

      final predictions = await _apiService.predictMany(featureVectors);
      return predictions?.predictions;
    } catch (e) {
      debugPrint('Error predicting future hours: $e');
      return null;
    }
  }
}

// Models
enum DeviceType { light, airConditioner, refrigerator, tv, washingMachine }

class Device {
  final String id;
  final String name;
  final DeviceType type;
  final bool isOn;
  final double consumption;
  final int scheduledTasks;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.isOn,
    required this.consumption,
    required this.scheduledTasks,
  });

  Device copyWith({
    String? id,
    String? name,
    DeviceType? type,
    bool? isOn,
    double? consumption,
    int? scheduledTasks,
  }) {
    return Device(
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

class EnergyData {
  final String hour;
  final double consumption;

  EnergyData({required this.hour, required this.consumption});
}

class SavingSuggestion {
  final String deviceName;
  final String suggestion;
  final double monthlySaving;
  final bool isApplied;
  final IconData icon;

  SavingSuggestion({
    required this.deviceName,
    required this.suggestion,
    required this.monthlySaving,
    required this.isApplied,
    required this.icon,
  });

  SavingSuggestion copyWith({
    String? deviceName,
    String? suggestion,
    double? monthlySaving,
    bool? isApplied,
    IconData? icon,
  }) {
    return SavingSuggestion(
      deviceName: deviceName ?? this.deviceName,
      suggestion: suggestion ?? this.suggestion,
      monthlySaving: monthlySaving ?? this.monthlySaving,
      isApplied: isApplied ?? this.isApplied,
      icon: icon ?? this.icon,
    );
  }
}
