# 🏠 Akıllı Evlerde Enerji Tasarrufu - Smart Home Energy Management

Akıllı evlerde enerji tüketimini izlemek, optimize etmek ve tasarruf önerileri sunmak için geliştirilmiş Flutter tabanlı mobil uygulama.

## 📱 Özellikler

### Kullanıcı Özellikleri
- 📊 **Gerçek Zamanlı Enerji İzleme**: Anlık enerji tüketimi takibi
- 🤖 **ML Tahmin Sistemi**: Machine Learning ile gelecek tüketim tahmini
- 💡 **Akıllı Cihaz Yönetimi**: Ev cihazlarını uzaktan kontrol ve zamanlama
- 📈 **Detaylı Raporlar**: Günlük, haftalık, aylık tüketim grafikleri
- 💰 **Tasarruf Önerileri**: Kişiselleştirilmiş enerji tasarrufu tavsiyeleri
- 🌤️ **Hava Durumu Entegrasyonu**: Hava koşullarına göre enerji optimizasyonu
- 📅 **Cihaz Zamanlama**: Otomatik açma/kapama programları

### Admin Özellikleri
- 👥 **Kullanıcı Yönetimi**: Kullanıcıları görüntüleme ve yönetme
- 📊 **Sistem Analizi**: Genel sistem istatistikleri
- ⚙️ **Sistem Ayarları**: Platform yapılandırması

## 🛠️ Teknolojiler

- **Framework**: Flutter 3.x
- **Dil**: Dart
- **Backend**: Python Flask API
- **ML Model**: Random Forest (scikit-learn)
- **Veritabanı**: SQLite (local), Firebase (cloud - opsiyonel)
- **State Management**: Provider
- **Grafikler**: FL Chart
- **API**: RESTful

## 📋 Gereksinimler

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio / VS Code
- Python 3.8+ (Backend için)
- Android 6.0+ / iOS 12.0+

## 🚀 Kurulum

### 1. Flutter Projesi

```bash
# Repository'yi klonlayın
git clone https://github.com/egtemre/Ak-ll-Evlerde-Tasarruf.git
cd flutter_application_1

# Bağımlılıkları yükleyin
flutter pub get

# Uygulamayı çalıştırın
flutter run
```

### 2. Python Backend (ML API)

```bash
cd server

# Virtual environment oluşturun
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Bağımlılıkları yükleyin
pip install -r requirements.txt

# API'yi başlatın
python app.py
```

API varsayılan olarak `http://localhost:8000` adresinde çalışacaktır.

### 3. Firebase Yapılandırması (Opsiyonel)

Firebase özelliklerini kullanmak istiyorsanız:

1. [Firebase Console](https://console.firebase.google.com)'a gidin
2. Yeni proje oluşturun
3. `lib/config/firebase_config.example.dart` dosyasını kopyalayın:
   ```bash
   cp lib/config/firebase_config.example.dart lib/config/firebase_config.dart
   ```
4. `firebase_config.dart` içindeki değerleri kendi Firebase bilgilerinizle değiştirin

⚠️ **ÖNEMLİ**: `firebase_config.dart` dosyası `.gitignore`'da olduğu için GitHub'a yüklenmez.

## 📱 Uygulama Ekranları

- **Splash & Onboarding**: İlk kullanım karşılama ekranları
- **Login/Register**: Kullanıcı girişi ve kayıt
- **Dashboard**: Ana enerji izleme paneli
- **Devices**: Cihaz yönetimi ve kontrol
- **Reports**: Detaylı tüketim raporları
- **Analytics**: Gelişmiş analiz ve karşılaştırmalar
- **Suggestions**: Kişiselleştirilmiş tasarruf önerileri
- **Settings**: Uygulama ayarları (tema, dil, vb.)
- **Admin Panel**: Sistem yönetimi

## 🔐 Test Hesapları

### Normal Kullanıcı
```
Email: herhangi bir email
Şifre: herhangi bir şifre
```

### Admin Kullanıcı
```
Email: root
Şifre: admin123
```

⚠️ **Güvenlik Notu**: Production'da admin bilgileri environment variable veya güvenli bir yöntemle saklanmalıdır.

## 🎨 Özelleştirme

### Tema
`lib/theme/app_theme.dart` dosyasından renk ve tema ayarlarını değiştirebilirsiniz.

### Dil Desteği
Şu anda Türkçe ve İngilizce dil desteği mevcuttur. `lib/utils/app_localizations.dart` dosyasından yeni diller eklenebilir.

## 📊 ML Model Entegrasyonu

Uygulama, enerji tüketim tahminleri için Random Forest modelini kullanır:

1. **Model Eğitimi**: `makine_öğrenmesi/` klasöründeki Python scriptleri
2. **API Entegrasyonu**: `lib/services/api_service.dart`
3. **Model Meta Bilgileri**: Model accuracy, feature importance vb.

### API Endpoints
```
POST /predict          - Tek tahmin
POST /predict_many     - Çoklu tahmin
GET  /model_meta       - Model bilgileri
GET  /health           - API durumu
```

## 📱 Platform Desteği

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🐛 Bilinen Sorunlar

- Firebase Authentication şu anda devre dışı (google-services.json gerekli)
- Hava durumu API'si için kendi API key'inizi eklemeniz gerekiyor

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'feat: Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📄 Lisans

Bu proje eğitim amaçlı geliştirilmiştir.

## 👨‍💻 Geliştirici

**Egemen Temre**
- GitHub: [@egtemre](https://github.com/egtemre)

## 📞 İletişim

Sorularınız için issue açabilir veya Pull Request gönderebilirsiniz.

---

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!
