import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/weather_service.dart';
import '../models/ml_prediction.dart';
import '../models/weather.dart';
import '../utils/app_localizations.dart';

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  int _currentIndex = 0;

  // Dil ayarı
  String _languageCode = 'tr'; // Varsayılan Türkçe

  // Tema ayarı
  bool _isDarkMode = false;

  // Hava durumu servisi
  final WeatherService _weatherService = WeatherService();
  Weather? _currentWeather;
  List<HourlyWeather> _hourlyWeather = [];
  bool _isLoadingWeather = false;

  // Getters
  String get languageCode => _languageCode;
  bool get isDarkMode => _isDarkMode;
  AppLocalizations get loc => AppLocalizations(_languageCode);
  Weather? get currentWeather => _currentWeather;
  List<HourlyWeather> get hourlyWeather => _hourlyWeather;
  bool get isLoadingWeather => _isLoadingWeather;

  // Cihaz verileri (günlük kW cinsinden - gerçekçi değerler)
  final List<Device> _devices = [
    Device(
      id: '1',
      name: 'Salon Lambası',
      type: DeviceType.light,
      isOn: true,
      consumption: 0.15, // 15W x 8 saat = 0.12 kWh/gün
      scheduledTasks: 2,
    ),
    Device(
      id: '2',
      name: 'Yatak Odası Klima',
      type: DeviceType.airConditioner,
      isOn: false,
      consumption: 12.5, // 1500W x ~8 saat = 12 kWh/gün
      scheduledTasks: 0,
    ),
    Device(
      id: '3',
      name: 'Buzdolabı',
      type: DeviceType.refrigerator,
      isOn: true,
      consumption: 2.8, // Sürekli açık, 120W ortalama = 2.88 kWh/gün
      scheduledTasks: 0,
    ),
    Device(
      id: '4',
      name: 'Televizyon',
      type: DeviceType.tv,
      isOn: false,
      consumption: 0.5, // 100W x 5 saat = 0.5 kWh/gün
      scheduledTasks: 1,
    ),
    Device(
      id: '5',
      name: 'Çamaşır Makinesi',
      type: DeviceType.washingMachine,
      isOn: false,
      consumption: 2.0, // 2000W x 1 saat/gün = 2 kWh/gün
      scheduledTasks: 0,
    ),
  ];

  // Zaman filtresi
  String _selectedTimeFilter = 'Günlük'; // Günlük, Haftalık, Aylık

  // Enerji tüketim verileri - Günlük (3 saatlik dilimler, kWh cinsinden)
  // Gerçek veri setine göre: günlük ortalama 35-45 kWh
  final List<EnergyData> _dailyEnergyData = [
    EnergyData(hour: '00-03', consumption: 3.2), // Gece - düşük tüketim
    EnergyData(hour: '03-06', consumption: 2.8), // Sabah erken - en düşük
    EnergyData(hour: '06-09', consumption: 5.5), // Sabah - artış
    EnergyData(hour: '09-12', consumption: 6.8), // Öğlen - yüksek
    EnergyData(hour: '12-15', consumption: 7.2), // Öğleden sonra - en yüksek
    EnergyData(hour: '15-18', consumption: 6.5), // İkindi - yüksek
    EnergyData(hour: '18-21', consumption: 8.3), // Akşam - pik saat
    EnergyData(hour: '21-24', consumption: 4.2), // Gece - düşüş
  ];

  // Haftalık veriler (günlük toplam kWh)
  // Haftalık ortalama: ~280-300 kWh
  final List<EnergyData> _weeklyEnergyData = [
    EnergyData(hour: 'Pzt', consumption: 38.5), // İş günü
    EnergyData(hour: 'Sal', consumption: 41.2), // İş günü
    EnergyData(hour: 'Çar', consumption: 37.8), // İş günü
    EnergyData(hour: 'Per', consumption: 39.5), // İş günü
    EnergyData(hour: 'Cum', consumption: 42.8), // İş günü
    EnergyData(hour: 'Cmt', consumption: 48.5), // Hafta sonu - yüksek
    EnergyData(hour: 'Paz', consumption: 46.2), // Hafta sonu - yüksek
  ];

  // Aylık veriler (haftalık toplam kWh)
  // Aylık toplam: ~1100-1200 kWh
  final List<EnergyData> _monthlyEnergyData = [
    EnergyData(hour: '1. Hafta', consumption: 285.2),
    EnergyData(hour: '2. Hafta', consumption: 298.5),
    EnergyData(hour: '3. Hafta', consumption: 276.8),
    EnergyData(hour: '4. Hafta', consumption: 305.1),
  ];

  // ML Model servisi
  final ApiService _apiService = ApiService();

  // ML Tahmin verileri
  MLPrediction? _currentPrediction;
  double? _dailyPrediction; // Günlük toplam tahmin (24 saat)
  double? _weeklyPrediction; // Haftalık toplam tahmin
  double? _monthlyPrediction; // Aylık toplam tahmin
  bool _isLoadingPrediction = false;
  String? _predictionError;
  ModelMeta? _modelMeta;

  // Tasarruf önerileri (aylık TL tasarruf - 3.5 TL/kWh üzerinden)
  final List<SavingSuggestion> _suggestions = [
    SavingSuggestion(
      deviceName: 'Oturma Odası Lambası',
      suggestion: 'LED ampullere geçiş yapın ve kullanılmadığında kapatın.',
      monthlySaving: 45.0, // ~13 kWh x 3.5 TL = 45 TL
      isApplied: true,
      icon: Icons.lightbulb,
    ),
    SavingSuggestion(
      deviceName: 'Yatak Odası Kliması',
      suggestion:
          'Klima sıcaklığını 24°C\'de sabit tutun ve inverter klima kullanın.',
      monthlySaving: 180.0, // ~50 kWh x 3.5 TL = 175 TL
      isApplied: false,
      icon: Icons.ac_unit,
    ),
    SavingSuggestion(
      deviceName: 'Buzdolabı',
      suggestion: 'A++ sınıfı buzdolabı kullanın ve kapıyı gereksiz açmayın.',
      monthlySaving: 65.0, // ~18 kWh x 3.5 TL = 63 TL
      isApplied: false,
      icon: Icons.kitchen,
    ),
    SavingSuggestion(
      deviceName: 'Çamaşır Makinesi',
      suggestion: 'Soğuk su programı kullanın ve tam yükte yıkayın.',
      monthlySaving: 85.0, // ~24 kWh x 3.5 TL = 84 TL
      isApplied: true,
      icon: Icons.local_laundry_service,
    ),
    SavingSuggestion(
      deviceName: 'Genel Öneri',
      suggestion:
          'Priz tipi akıllı prizler kullanarak bekleme modundaki cihazları kapatın.',
      monthlySaving: 55.0, // ~15 kWh x 3.5 TL = 52 TL
      isApplied: false,
      icon: Icons.power_settings_new,
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

  // Toplam tüketim hesaplama
  double get totalConsumption {
    final data = energyData;
    return data.fold(0.0, (sum, data) => sum + data.consumption);
  }

  // Tahmini aylık tasarruf - Gerçek tüketimden hesapla
  // Ortalama günlük tüketim * 30 gün * 0.15 (hedef tasarruf) * 3.5 TL/kWh
  double get estimatedMonthlySaving {
    if (totalConsumption == 0) return 0.0;

    // Günlük ortalama tüketimi hesapla
    final avgDailyConsumption = totalConsumption / energyData.length;

    // Aylık tüketim tahmini
    final monthlyConsumption = avgDailyConsumption * 30;

    // %15 tasarruf hedefi * elektrik fiyatı (3.5 TL/kWh)
    final savingKwh = monthlyConsumption * 0.15;
    final savingTL = savingKwh * 3.5;

    return savingTL;
  }

  double get monthlyTarget => estimatedMonthlySaving * 1.5; // Hedef: %50 fazla

  double get currentMonthlySaving {
    // Uygulanan önerilerin tasarrufu
    return _suggestions
        .where((s) => s.isApplied)
        .fold(0.0, (sum, s) => sum + s.monthlySaving);
  }

  String get selectedTimeFilter => _selectedTimeFilter;

  // ML Tahmin getters
  MLPrediction? get currentPrediction => _currentPrediction;
  double? get dailyPrediction => _dailyPrediction;
  double? get weeklyPrediction => _weeklyPrediction;
  double? get monthlyPrediction => _monthlyPrediction;
  bool get isLoadingPrediction => _isLoadingPrediction;
  String? get predictionError => _predictionError;
  ModelMeta? get modelMeta => _modelMeta;

  // Seçili filtreye göre doğru tahmin değerini döndür
  double? get currentFilterPrediction {
    switch (_selectedTimeFilter) {
      case 'Haftalık':
        return _weeklyPrediction;
      case 'Aylık':
        return _monthlyPrediction;
      default:
        return _dailyPrediction; // Günlük toplam tahmin
    }
  }

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

      // Filtre değiştiğinde yeni tahmin yap
      if (filter == 'Haftalık') {
        // Gelecek 7 gün için tahmin yap (günlük toplam)
        predictFutureHours(7 * 24).then((predictions) {
          if (predictions != null && predictions.isNotEmpty) {
            // Her gün için 24 saatlik tahminleri topla
            _weeklyEnergyData.clear();
            double weekTotal = 0;
            final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
            for (int day = 0; day < 7; day++) {
              double dayTotal = 0;
              for (int hour = 0; hour < 24; hour++) {
                final index = day * 24 + hour;
                if (index < predictions.length) {
                  dayTotal += predictions[index];
                }
              }
              weekTotal += dayTotal;
              _weeklyEnergyData.add(EnergyData(
                hour: days[day],
                consumption: dayTotal,
              ));
            }
            // Haftalık toplam tahmini kaydet
            _weeklyPrediction = weekTotal;
            notifyListeners();
          }
        });
      } else if (filter == 'Aylık') {
        // Gelecek 30 gün için tahmin yap (haftalık toplam)
        predictFutureHours(30 * 24).then((predictions) {
          if (predictions != null && predictions.isNotEmpty) {
            _monthlyEnergyData.clear();
            double monthTotal = 0;
            // 30 günü 4 haftaya böl (7-7-8-8)
            final weeks = [7, 7, 8, 8];
            for (int week = 0; week < 4; week++) {
              double weekTotal = 0;
              final startDay =
                  weeks.take(week).fold(0, (sum, days) => sum + days);
              for (int day = 0; day < weeks[week]; day++) {
                for (int hour = 0; hour < 24; hour++) {
                  final index = (startDay + day) * 24 + hour;
                  if (index < predictions.length) {
                    weekTotal += predictions[index];
                  }
                }
              }
              monthTotal += weekTotal;
              _monthlyEnergyData.add(EnergyData(
                hour: '${week + 1}. Hafta',
                consumption: weekTotal,
              ));
            }
            // Aylık toplam tahmini kaydet
            _monthlyPrediction = monthTotal;
            notifyListeners();
          }
        });
      }
    }
  }

  void toggleDevice(String deviceId) {
    final deviceIndex = _devices.indexWhere((d) => d.id == deviceId);
    if (deviceIndex != -1) {
      _devices[deviceIndex] = Device(
        id: _devices[deviceIndex].id,
        name: _devices[deviceIndex].name,
        type: _devices[deviceIndex].type,
        isOn: !_devices[deviceIndex].isOn,
        consumption: _devices[deviceIndex].consumption,
        scheduledTasks: _devices[deviceIndex].scheduledTasks,
        schedules: _devices[deviceIndex].schedules,
        model: _devices[deviceIndex].model,
      );
      notifyListeners();
    }
  }

  void addDevice({
    required String name,
    required DeviceType type,
    required String model,
    required double consumption,
  }) {
    final newDevice = Device(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      isOn: false,
      consumption: consumption,
      scheduledTasks: 0,
      schedules: [],
      model: model,
    );
    _devices.add(newDevice);
    notifyListeners();
  }

  void removeDevice(String deviceId) {
    _devices.removeWhere((d) => d.id == deviceId);
    notifyListeners();
  }

  void addSchedule(String deviceId, DeviceSchedule schedule) {
    final deviceIndex = _devices.indexWhere((d) => d.id == deviceId);
    if (deviceIndex != -1) {
      final device = _devices[deviceIndex];
      final newSchedules = List<DeviceSchedule>.from(device.schedules);
      newSchedules.add(schedule);

      _devices[deviceIndex] = Device(
        id: device.id,
        name: device.name,
        type: device.type,
        isOn: device.isOn,
        consumption: device.consumption,
        scheduledTasks: newSchedules.where((s) => s.isActive).length,
        schedules: newSchedules,
        model: device.model,
      );
      notifyListeners();
    }
  }

  void removeSchedule(String deviceId, String scheduleId) {
    final deviceIndex = _devices.indexWhere((d) => d.id == deviceId);
    if (deviceIndex != -1) {
      final device = _devices[deviceIndex];
      final newSchedules =
          device.schedules.where((s) => s.id != scheduleId).toList();

      _devices[deviceIndex] = Device(
        id: device.id,
        name: device.name,
        type: device.type,
        isOn: device.isOn,
        consumption: device.consumption,
        scheduledTasks: newSchedules.where((s) => s.isActive).length,
        schedules: newSchedules,
        model: device.model,
      );
      notifyListeners();
    }
  }

  void toggleSchedule(String deviceId, String scheduleId) {
    final deviceIndex = _devices.indexWhere((d) => d.id == deviceId);
    if (deviceIndex != -1) {
      final device = _devices[deviceIndex];
      final newSchedules = device.schedules.map((s) {
        if (s.id == scheduleId) {
          return DeviceSchedule(
            id: s.id,
            startTime: s.startTime,
            endTime: s.endTime,
            isActive: !s.isActive,
            weekDays: s.weekDays,
          );
        }
        return s;
      }).toList();

      _devices[deviceIndex] = Device(
        id: device.id,
        name: device.name,
        type: device.type,
        isOn: device.isOn,
        consumption: device.consumption,
        scheduledTasks: newSchedules.where((s) => s.isActive).length,
        schedules: newSchedules,
        model: device.model,
      );
      notifyListeners();
    }
  }

  void applySuggestion(int index) {
    if (index < _suggestions.length) {
      _suggestions[index] = SavingSuggestion(
        deviceName: _suggestions[index].deviceName,
        suggestion: _suggestions[index].suggestion,
        monthlySaving: _suggestions[index].monthlySaving,
        isApplied: !_suggestions[index].isApplied,
        icon: _suggestions[index].icon,
      );
      notifyListeners();
    }
  }

  // ML Model metadata yükle
  Future<void> loadModelMeta() async {
    try {
      _modelMeta = await _apiService.getModelMeta();
      notifyListeners();
    } catch (e) {
      debugPrint('Model meta yüklenemedi: $e');
    }
  }

  // Mevcut saatlik enerji tahmin et
  Future<void> predictCurrentEnergy() async {
    _isLoadingPrediction = true;
    _predictionError = null;
    notifyListeners();

    try {
      // ML API çağrısı devre dışı - şu an için mock veri
      await Future.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();
      // Mock tahmin değeri - gerçek günlük ortalamaya yakın
      _currentPrediction = MLPrediction(
        prediction: 1.8 +
            (now.hour >= 18 && now.hour <= 21
                ? 1.5
                : 0), // Akşam saatleri yüksek
        timestamp: now,
      );

      // Günlük toplam tahmini hesapla (24 saatlik tahmin toplamı)
      final dailyPredictions = await predictFutureHours(24);
      if (dailyPredictions != null && dailyPredictions.isNotEmpty) {
        _dailyPrediction = dailyPredictions.reduce((a, b) => a + b);
      } else {
        // Fallback: Ortalama günlük tüketim (~44.5 kWh)
        _dailyPrediction = 44.5;
      }

      _predictionError = null;
    } catch (e) {
      _predictionError = e.toString();
    } finally {
      _isLoadingPrediction = false;
      notifyListeners();
    }
  }

  // Gelecek N saat için toplu tahmin
  Future<List<double>?> predictFutureHours(int hours) async {
    try {
      // Mock veri döndür - ML API bağımsız çalışma
      await Future.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();
      final List<double> predictions = [];

      // Saatlik tüketim paterni simülasyonu
      for (int i = 0; i < hours; i++) {
        final futureTime = now.add(Duration(hours: i));
        double baseConsumption = 1.5;

        // Saat bazlı tüketim paterni
        if (futureTime.hour >= 6 && futureTime.hour < 9) {
          baseConsumption = 2.5; // Sabah
        } else if (futureTime.hour >= 18 && futureTime.hour <= 21) {
          baseConsumption = 3.5; // Akşam pik
        } else if (futureTime.hour >= 0 && futureTime.hour < 6) {
          baseConsumption = 1.2; // Gece
        }

        // Hafta sonu ek tüketim
        if (futureTime.weekday >= 6) {
          baseConsumption *= 1.15;
        }

        predictions.add(baseConsumption + (i % 3) * 0.1);
      }

      return predictions;
    } catch (e) {
      debugPrint('Future prediction error: $e');
      return null;
    }
  }

  // Dil değiştirme
  Future<void> changeLanguage(String languageCode) async {
    if (_languageCode != languageCode) {
      _languageCode = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      notifyListeners();
    }
  }

  // Dil yükleme
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString('language') ?? 'tr';
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _languageCode = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    notifyListeners();
  }

  // Tema yükleme ve ayarlama
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDark);
    notifyListeners();
  }

  // Hava durumu verilerini yükle (mock data kullanarak)
  Future<void> loadWeatherData() async {
    _isLoadingWeather = true;
    notifyListeners();

    try {
      // Mock data kullan (gerçek API için getCurrentWeather ve getHourlyForecast kullanın)
      _currentWeather = _weatherService.getMockCurrentWeather();
      _hourlyWeather = _weatherService.getMockHourlyForecast();

      // Gerçek API kullanmak için:
      // _currentWeather = await _weatherService.getCurrentWeather();
      // _hourlyWeather = await _weatherService.getHourlyForecast();
    } catch (e) {
      debugPrint('Hava durumu yüklenemedi: $e');
    } finally {
      _isLoadingWeather = false;
      notifyListeners();
    }
  }

  // Hava durumunu yenile
  Future<void> refreshWeather() async {
    await loadWeatherData();
  }
}

// Model sınıfları
class Device {
  final String id;
  final String name;
  final DeviceType type;
  final bool isOn;
  final double consumption; // Günlük kWh
  final int scheduledTasks;
  final List<DeviceSchedule> schedules;
  final String? model; // Cihaz modeli/markası

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.isOn,
    required this.consumption,
    required this.scheduledTasks,
    List<DeviceSchedule>? schedules,
    this.model,
  }) : schedules = schedules ?? [];

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
      case DeviceType.other:
        return Icons.device_unknown;
    }
  }
}

enum DeviceType {
  light,
  airConditioner,
  refrigerator,
  tv,
  washingMachine,
  other,
}

class EnergyData {
  final String hour;
  final double consumption;

  EnergyData({
    required this.hour,
    required this.consumption,
  });
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
}

class DeviceSchedule {
  final String id;
  final TimeOfDay startTime; // Açılış saati
  final TimeOfDay endTime; // Kapanış saati
  final bool isActive;
  final List<int> weekDays; // 1=Pzt, 2=Sal, ..., 7=Pzr

  DeviceSchedule({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
    List<int>? weekDays,
  }) : weekDays = weekDays ?? [1, 2, 3, 4, 5, 6, 7]; // Varsayılan: her gün

  String get startTimeString {
    final hour = startTime.hour.toString().padLeft(2, '0');
    final minute = startTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get endTimeString {
    final hour = endTime.hour.toString().padLeft(2, '0');
    final minute = endTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get timeString => '$startTimeString - $endTimeString';

  int get durationMinutes {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (endMinutes > startMinutes) {
      return endMinutes - startMinutes;
    } else {
      // Gece yarısını geçen durumlar için (örn: 23:00 - 01:00)
      return (24 * 60 - startMinutes) + endMinutes;
    }
  }

  String get durationText {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '$hours saat $minutes dakika';
    } else if (hours > 0) {
      return '$hours saat';
    } else {
      return '$minutes dakika';
    }
  }

  String get daysText {
    if (weekDays.length == 7) return 'Her gün';
    if (weekDays.length == 5 &&
        !weekDays.contains(6) &&
        !weekDays.contains(7)) {
      return 'Hafta içi';
    }
    if (weekDays.length == 2 && weekDays.contains(6) && weekDays.contains(7)) {
      return 'Hafta sonu';
    }
    const dayNames = ['', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return weekDays.map((d) => dayNames[d]).join(', ');
  }
}
