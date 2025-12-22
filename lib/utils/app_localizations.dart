class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations of(String languageCode) {
    return AppLocalizations(languageCode);
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      // Ana Navigasyon
      'dashboard': 'Panel',
      'devices': 'Cihazlarım',
      'suggestions': 'Öneriler',
      'settings': 'Ayarlar',

      // Dashboard
      'todayConsumption': 'Bugün',
      'weeklyConsumption': 'Haftalık',
      'monthlyConsumption': 'Aylık',
      'energyChart': 'Enerji Grafiği',
      'savingsGoal': 'Tasarruf Hedefi',
      'activeDevices': 'Aktif Cihazlar',
      'energyDashboard': 'Enerji Panosu',
      'energyConsumptionPanel': 'Enerji Tüketimi Paneli',
      'daily': 'Günlük',
      'weekly': 'Haftalık',
      'monthly': 'Aylık',
      'mlPrediction': 'ML Tahmin',
      'mlPredictionMake': 'ML Tahmin Yap',
      'aiModelPrediction': 'Yapay zeka modelinizin anlık tüketim tahmini',
      'modelLabel': 'Model',
      'next24Hours': 'Gelecek 24 Saat Tahmini',
      'next24HoursDesc':
          'Yapay zeka ile önümüzdeki 24 saatlik tüketim tahmini (3 saatlik dilimler)',
      'next7Days': 'Gelecek 7 Gün Tahmini',
      'next7DaysDesc': 'Yapay zeka ile önümüzdeki 7 günlük tüketim tahmini',
      'next4Weeks': 'Gelecek 4 Hafta Tahmini',
      'next4WeeksDesc': 'Yapay zeka ile önümüzdeki 4 haftalık tüketim tahmini',
      'today': 'Bugün',
      'thisWeek': 'Bu Hafta',
      'thisMonth': 'Bu Ay',
      '24HourTotal': '24 saatlik toplam tüketim',
      '7DayTotal': '7 günlük toplam tüketim',
      '30DayTotal': '30 günlük toplam tüketim',
      'analyzingPattern':
          'Sistemimiz 24 saatlik tüketim deseninizi analiz ediyor. Lütfen biraz bekleyin.',
      'hourly': 'Saatlik',

      // Devices
      'myDevices': 'Cihazlarım',
      'addDevice': 'Cihaz Ekle',
      'deviceName': 'Cihaz Adı',
      'deviceType': 'Cihaz Tipi',
      'model': 'Model/Marka',
      'lighting': 'Aydınlatma',
      'airConditioner': 'Klima',
      'refrigerator': 'Buzdolabı',
      'tv': 'Televizyon',
      'washingMachine': 'Çamaşır Makinesi',
      'other': 'Diğer',
      'cancel': 'İptal',
      'add': 'Ekle',
      'save': 'Kaydet',

      // Suggestions
      'savingSuggestions': 'Tasarruf Önerileri',
      'estimatedSaving': 'Tahmini Tasarruf',
      'apply': 'Uygula',
      'applied': 'Uygulandı',
      'perMonth': '/ay',
      'deviceBasedSuggestions': 'Cihaz Bazlı Öneriler',
      'suggestionApplied': 'önerisi uygulandı!',
      'suggestionRemoved': 'önerisi geri alındı',

      // Settings
      'profile': 'Profil',
      'notifications': 'Bildirimler',
      'notificationDesc': 'Enerji tasarrufu önerileri ve uyarılar',
      'preferences': 'Tercihler',
      'detailedAnalysis': 'Detaylı Analiz',
      'dataManagement': 'Veri Yönetimi',
      'language': 'Dil',
      'turkish': 'Türkçe',
      'english': 'English',
      'darkMode': 'Koyu Tema',
      'deviceConnection': 'Cihaz Bağlantı Tercihleri',
      'help': 'Yardım',
      'faq': 'Sıkça Sorulan Sorular',
      'energyTips': 'Enerji Tasarrufu İpuçları',
      'showIntro': 'Tanıtımı Tekrar Göster',
      'showIntroDesc': 'Uygulama özelliklerini yeniden öğren',
      'logout': 'Çıkış Yap',
      'developer': 'Geliştirici',

      // Common
      'monday': 'Pazartesi',
      'tuesday': 'Salı',
      'wednesday': 'Çarşamba',
      'thursday': 'Perşembe',
      'friday': 'Cuma',
      'saturday': 'Cumartesi',
      'sunday': 'Pazar',
      'hour': 'saat',
      'minute': 'dakika',
      'minutes': 'dakika',
      'hours': 'saat',
      'day': 'gün',
      'week': 'hafta',
      'month': 'ay',

      // Schedule
      'schedule': 'Zamanlama',
      'addSchedule': 'Zamanlama Ekle',
      'startTime': 'Açılış Saati',
      'endTime': 'Kapanış Saati',
      'days': 'Günler',
      'everyday': 'Her gün',
      'weekdays': 'Hafta içi',
      'weekend': 'Hafta sonu',
      'deleteSchedule': 'Zamanlamayı Sil',
      'deleteConfirm': 'zamanlamasını silmek istediğinize emin misiniz?',

      // Weather
      'clear': 'Açık',
      'cloudy': 'Bulutlu',
      'rainy': 'Yağmurlu',
      'snowy': 'Karlı',
      'hourlyForecast': 'Bugün Saatlik Hava Durumu',
      'humidity': 'Nem',
    },
    'en': {
      // Main Navigation
      'dashboard': 'Dashboard',
      'devices': 'My Devices',
      'suggestions': 'Suggestions',
      'settings': 'Settings',

      // Dashboard
      'todayConsumption': 'Today',
      'weeklyConsumption': 'Weekly',
      'monthlyConsumption': 'Monthly',
      'energyChart': 'Energy Chart',
      'savingsGoal': 'Savings Goal',
      'activeDevices': 'Active Devices',
      'energyDashboard': 'Energy Dashboard',
      'energyConsumptionPanel': 'Energy Consumption Panel',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'mlPrediction': 'ML Prediction',
      'mlPredictionMake': 'Make ML Prediction',
      'aiModelPrediction': 'Your AI model\'s real-time consumption prediction',
      'modelLabel': 'Model',
      'next24Hours': 'Next 24 Hours Forecast',
      'next24HoursDesc':
          'AI-powered prediction for the next 24 hours (3-hour intervals)',
      'next7Days': 'Next 7 Days Forecast',
      'next7DaysDesc': 'AI-powered prediction for the next 7 days',
      'next4Weeks': 'Next 4 Weeks Forecast',
      'next4WeeksDesc': 'AI-powered prediction for the next 4 weeks',
      'today': 'Today',
      'thisWeek': 'This Week',
      'thisMonth': 'This Month',
      '24HourTotal': '24-hour total consumption',
      '7DayTotal': '7-day total consumption',
      '30DayTotal': '30-day total consumption',
      'analyzingPattern':
          'Our system is analyzing your 24-hour consumption pattern. Please wait.',
      'hourly': 'Hourly',

      // Devices
      'myDevices': 'My Devices',
      'addDevice': 'Add Device',
      'deviceName': 'Device Name',
      'deviceType': 'Device Type',
      'model': 'Model/Brand',
      'lighting': 'Lighting',
      'airConditioner': 'Air Conditioner',
      'refrigerator': 'Refrigerator',
      'tv': 'Television',
      'washingMachine': 'Washing Machine',
      'other': 'Other',
      'cancel': 'Cancel',
      'add': 'Add',
      'save': 'Save',

      // Suggestions
      'savingSuggestions': 'Saving Suggestions',
      'estimatedSaving': 'Estimated Saving',
      'apply': 'Apply',
      'applied': 'Applied',
      'perMonth': '/mo',
      'deviceBasedSuggestions': 'Device-Based Suggestions',
      'suggestionApplied': 'suggestion applied!',
      'suggestionRemoved': 'suggestion removed',

      // Settings
      'profile': 'Profile',
      'notifications': 'Notifications',
      'notificationDesc': 'Energy saving tips and alerts',
      'preferences': 'Preferences',
      'detailedAnalysis': 'Detailed Analysis',
      'dataManagement': 'Data Management',
      'language': 'Language',
      'turkish': 'Türkçe',
      'english': 'English',
      'darkMode': 'Dark Mode',
      'deviceConnection': 'Device Connection Settings',
      'help': 'Help',
      'faq': 'FAQ',
      'energyTips': 'Energy Saving Tips',
      'showIntro': 'Show Introduction Again',
      'showIntroDesc': 'Learn app features again',
      'logout': 'Logout',
      'developer': 'Developer',

      // Common
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
      'hour': 'hour',
      'minute': 'minute',
      'minutes': 'minutes',
      'hours': 'hours',
      'day': 'day',
      'week': 'week',
      'month': 'month',

      // Schedule
      'schedule': 'Schedule',
      'addSchedule': 'Add Schedule',
      'startTime': 'Start Time',
      'endTime': 'End Time',
      'days': 'Days',
      'everyday': 'Everyday',
      'weekdays': 'Weekdays',
      'weekend': 'Weekend',
      'deleteSchedule': 'Delete Schedule',
      'deleteConfirm': 'Are you sure you want to delete this schedule?',

      // Weather
      'clear': 'Clear',
      'cloudy': 'Cloudy',
      'rainy': 'Rainy',
      'snowy': 'Snowy',
      'hourlyForecast': 'Today\'s Hourly Forecast',
      'humidity': 'Humidity',
    },
  };

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ?? key;
  }

  String get dashboard => translate('dashboard');
  String get devices => translate('devices');
  String get suggestions => translate('suggestions');
  String get settings => translate('settings');
  String get myDevices => translate('myDevices');
  String get savingSuggestions => translate('savingSuggestions');
  String get profile => translate('profile');
  String get notifications => translate('notifications');
  String get notificationDesc => translate('notificationDesc');
  String get preferences => translate('preferences');
  String get language => translate('language');
  String get turkish => translate('turkish');
  String get english => translate('english');
  String get darkMode => translate('darkMode');
  String get apply => translate('apply');
  String get applied => translate('applied');
  String get help => translate('help');

  // Dashboard getters
  String get energyDashboard => translate('energyDashboard');
  String get energyConsumptionPanel => translate('energyConsumptionPanel');
  String get daily => translate('daily');
  String get weekly => translate('weekly');
  String get monthly => translate('monthly');
  String get mlPrediction => translate('mlPrediction');
  String get mlPredictionMake => translate('mlPredictionMake');
  String get aiModelPrediction => translate('aiModelPrediction');
  String get modelLabel => translate('modelLabel');
  String get next24Hours => translate('next24Hours');
  String get next24HoursDesc => translate('next24HoursDesc');
  String get next7Days => translate('next7Days');
  String get next7DaysDesc => translate('next7DaysDesc');
  String get next4Weeks => translate('next4Weeks');
  String get next4WeeksDesc => translate('next4WeeksDesc');
  String get today => translate('today');
  String get thisWeek => translate('thisWeek');
  String get thisMonth => translate('thisMonth');
  String get total24Hour => translate('24HourTotal');
  String get total7Day => translate('7DayTotal');
  String get total30Day => translate('30DayTotal');
  String get analyzingPattern => translate('analyzingPattern');
  String get hourly => translate('hourly');
  String get logout => translate('logout');
  String get detailedAnalysis => translate('detailedAnalysis');
  String get dataManagement => translate('dataManagement');
  String get deviceConnection => translate('deviceConnection');
  String get faq => translate('faq');
  String get energyTips => translate('energyTips');
  String get showIntro => translate('showIntro');
  String get showIntroDesc => translate('showIntroDesc');
  String get deviceBasedSuggestions => translate('deviceBasedSuggestions');
  String get suggestionApplied => translate('suggestionApplied');
  String get suggestionRemoved => translate('suggestionRemoved');
  String get developer => translate('developer');
  String get estimatedSaving => translate('estimatedSaving');
  String get perMonth => translate('perMonth');
  String get humidity => translate('humidity');
  String get hourlyForecast => translate('hourlyForecast');
}
