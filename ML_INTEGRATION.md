# Makine Öğrenmesi Model Entegrasyonu

Bu dokümantasyon, Flutter uygulamasına makine öğrenmesi modelinin nasıl entegre edildiğini açıklar.

## 🎯 Genel Bakış

Uygulama, FastAPI backend'inde çalışan bir Random Forest modelinden enerji tüketimi tahminleri alır. Model, mevcut sensör verilerine dayanarak gelecekteki enerji tüketimini tahmin eder.

## 📁 Dosya Yapısı

```
lib/
├── models/
│   ├── feature_vector.dart      # Model için özellik vektörü
│   └── ml_prediction.dart        # Tahmin sonuçları ve model meta bilgileri
├── services/
│   └── api_service.dart         # ML API ile iletişim servisi
└── providers/
    └── app_state.dart           # Model tahminlerini yöneten state
```

## 🔧 Kurulum

### 1. Backend API'yi Başlatın

Python backend'inizi çalıştırın:

```bash
cd server
python app.py
# veya
uvicorn app:app --reload --port 8000
```

API şu endpoint'leri sunar:
- `GET /meta` - Model meta bilgileri
- `POST /predict` - Tek tahmin
- `POST /predict_many` - Çoklu tahmin

### 2. API URL'ini Yapılandırın

`lib/services/api_service.dart` dosyasında API URL'ini platformunuza göre ayarlayın:

```dart
// Android emülatör için
static const String _baseUrl = 'http://10.0.2.2:8000';

// iOS simülatör için
static const String _baseUrl = 'http://localhost:8000';

// Gerçek cihaz için (bilgisayarınızın IP adresi)
static const String _baseUrl = 'http://192.168.1.100:8000';
```

**Gerçek cihazda kullanmak için:**
1. Bilgisayarınızın yerel IP adresini bulun:
   - Windows: `ipconfig` komutunu çalıştırın
   - Mac/Linux: `ifconfig` veya `ip addr` komutunu çalıştırın
2. IP adresini `api_service.dart` dosyasına girin
3. Cihaz ve bilgisayar aynı WiFi ağında olmalı

### 3. Android Internet İzinleri

`android/app/src/main/AndroidManifest.xml` dosyasına internet iznini ekleyin:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## 📱 Kullanım

### Dashboard'da ML Tahminleri

1. Dashboard ekranı açıldığında otomatik olarak tahmin yapılır
2. ML Tahmin kartı görüntülenir:
   - Tahmin edilen tüketim değeri
   - Güven skoru (varsa)
   - Mevcut tüketim ile karşılaştırma
3. Yenile butonu ile manuel tahmin yapabilirsiniz
4. Floating action button ile hızlı tahmin yapabilirsiniz

### Programatik Kullanım

```dart
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

// AppState'e erişim
final appState = Provider.of<AppState>(context, listen: false);

// Model meta bilgilerini yükle
await appState.loadModelMeta();

// Mevcut verilerle tahmin yap
await appState.predictCurrentEnergy();

// Tahmin sonucunu kontrol et
if (appState.currentPrediction != null) {
  print('Tahmin: ${appState.currentPrediction!.prediction} kWh');
}

// Gelecek saatler için tahmin yap
final futurePredictions = await appState.predictFutureHours(24);
if (futurePredictions != null) {
  print('Gelecek 24 saat için tahminler: $futurePredictions');
}
```

## 🔄 Veri Akışı

1. **Sensör Verileri Toplama**
   - Uygulama, cihazlardan ve sensörlerden veri toplar
   - Bu veriler `FeatureVector` modeline dönüştürülür

2. **Feature Vector Oluşturma**
   - `ApiService.createFeatureVectorFromCurrentData()` metodu
   - Mevcut tüketim, sıcaklık, nem, voltaj vb. verileri kullanır
   - Zaman özellikleri (saat, gün, mevsim) otomatik hesaplanır

3. **API İsteği**
   - Feature vector JSON formatında API'ye gönderilir
   - POST `/predict` endpoint'i çağrılır

4. **Tahmin Sonucu**
   - Model tahminini ve güven skorunu döndürür
   - `MLPrediction` modeli ile parse edilir
   - `AppState` içinde saklanır ve UI'da gösterilir

## 🎨 UI Bileşenleri

### ML Tahmin Kartı
- Tahmin edilen tüketim değeri
- Model tipi bilgisi
- Güven skoru (varsa)
- Mevcut tüketim ile karşılaştırma
- Hata mesajları (API bağlantı sorunları)

### Karşılaştırma Widget'ı
- Tahmin ile mevcut değer arasındaki fark
- Yüzdelik değişim
- Görsel gösterge (yukarı/aşağı ok)

## 🐛 Sorun Giderme

### API'ye Bağlanılamıyor

1. **Backend çalışıyor mu?**
   ```bash
   curl http://localhost:8000/meta
   ```

2. **URL doğru mu?**
   - Android emülatör: `10.0.2.2:8000`
   - Gerçek cihaz: Bilgisayar IP adresi

3. **Firewall ayarları**
   - Windows Firewall veya antivirüs API'yi engelliyor olabilir
   - Port 8000'in açık olduğundan emin olun

4. **CORS ayarları**
   - Backend'de CORS middleware'inin aktif olduğundan emin olun
   - `server/app.py` dosyasında CORS ayarları kontrol edin

### Tahmin Sonuçları Gelmiyor

1. **Model yüklü mü?**
   - Backend'de `model.joblib` dosyasının mevcut olduğundan emin olun
   - Model dosyasının doğru yolda olduğunu kontrol edin

2. **Feature vector doğru mu?**
   - Backend loglarını kontrol edin
   - Feature isimlerinin ve formatının doğru olduğundan emin olun

3. **Hata mesajlarını kontrol edin**
   - Flutter debug konsolunda hata mesajlarını okuyun
   - `predictionError` değerini kontrol edin

## 📊 Model Özellikleri

Model şu özellikleri kullanır:
- **Zaman özellikleri**: Saat, gün, ay, hafta sonu, mevsim, zaman dilimi
- **Tüketim özellikleri**: Önceki saat, önceki 2 saat, önceki gün, rolling mean/std
- **Çevresel özellikler**: Sıcaklık, nem, sıcaklık kategorisi
- **Sensör verileri**: Voltaj, akım, sub-metering değerleri

## 🔮 Gelecek Geliştirmeler

- [ ] Offline tahmin desteği (TensorFlow Lite)
- [ ] Tahmin geçmişi grafikleri
- [ ] Tahmin doğruluğu metrikleri
- [ ] Otomatik tahmin güncellemeleri
- [ ] Push notification ile tahmin uyarıları
- [ ] Tahmin tabanlı otomatik cihaz kontrolü

## 📝 Notlar

- Gerçek uygulamada sensör verileri IoT cihazlarından veya veritabanından gelecek
- Şu an için örnek veriler kullanılıyor
- Production ortamında API URL'i environment variable olarak ayarlanmalı
- API anahtarları veya authentication eklenebilir

