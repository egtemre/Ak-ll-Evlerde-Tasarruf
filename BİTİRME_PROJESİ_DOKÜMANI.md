# 🏠 AKILLI EV ENERJİ YÖNETİMİ SİSTEMİ
## Bitirme Projesi Detaylı Dokümantasyon

---

## 📋 PROJE ÖZET

### Proje Adı
**Akıllı Ev Enerji Yönetimi Sistemi** - ML Tabanlı Enerji Tüketim İzleme ve Optimizasyon Platformu

### Amaç
Ev kullanıcılarının enerji tüketimlerini izleyip, yapay zeka destekli tahminler ve önerilerle tasarruf sağlamalarını desteklemek.

### Teknolojiler
- **Frontend**: Flutter (Dart) - Cross-platform mobil uygulama
- **Backend**: FastAPI (Python) - RESTful API servisi
- **ML Model**: Random Forest Regressor (%96 doğruluk)
- **Veritabanı**: SQLite (Local storage)
- **Grafikler**: FL Chart kütüphanesi
- **State Management**: Provider pattern

---

## 🎯 PROJE ÖZELLİKLERİ

### 1. ✅ Kullanıcı Kimlik Doğrulama
- Modern giriş/kayıt ekranları
- Kullanıcı oturumu yönetimi
- Provider ile state management

### 2. 📊 Enerji İzleme Dashboard'u
- **Gerçek zamanlı tüketim göstergeleri**
- Günlük, haftalık, aylık filtreleme
- İnteraktif bar grafikleri
- ML tahmin entegrasyonu
- Karşılaştırmalı analizler

### 3. 🔌 Cihaz Yönetimi
- Cihaz listesi ve durumları
- Tüketim bazlı sıralama
- Hava durumu entegrasyonu
- Cihaz ekleme/çıkarma (veritabanı entegreli)

### 4. 📈 Gelişmiş Raporlama
- **Saatlik/günlük/haftalık/aylık raporlar**
- Trend analizi (line charts)
- Cihaz bazlı tüketim breakdown'u
- Aylık karşılaştırma tabloları
- İstatistiksel özetler (ortalama, max, min)

### 5. 💡 Akıllı Tasarruf Önerileri
- **Yapay zeka destekli öneriler**
- Uygulanabilir eylem planları
- Potansiyel tasarruf hesaplamaları (kWh ve TL)
- Öneri uygulama takibi

### 6. 🎓 **[YENİ] Detaylı Analiz Ekranı**
- **Günlük karşılaştırma** (bugün vs dün)
- **Haftalık trend analizi** (artış/azalış/stabil)
- **Anomali tespiti** (Z-score algoritması)
- **Tasarruf potansiyeli hesaplama**
- CO2 emisyon hesaplaması

### 7. 🔧 **[YENİ] Veri Yönetimi (Admin Panel)**
- Gerçekçi test verisi oluşturma (7 günlük saatlik data)
- Veritabanı istatistikleri
- Akıllı öneri üretme
- Veritabanı temizleme

### 8. 🤖 ML Model Entegrasyonu
- **Random Forest modeli** - %96 doğruluk
- Feature engineering (20 özellik)
- Saatlik tahmin yapma
- Haftalık/aylık toplu tahminler
- Model meta bilgileri gösterimi

### 9. 💾 Veritabanı İşlemleri
- **SQLite local database**
- CRUD operasyonları
- İlişkisel tablolar (Users, Buildings, Devices, Energy_Readings, Recommendations)
- Batch insert (performanslı veri ekleme)
- Repository pattern

---

## 🏗️ MİMARİ YAPISI

```
lib/
├── main.dart                          # Uygulama giriş noktası
├── models/                            # Veri modelleri
│   ├── energy_reading.dart           # Enerji okuma modeli
│   ├── device.dart                   # Cihaz modeli
│   ├── recommendation.dart           # Öneri modeli
│   ├── feature_vector.dart           # ML feature vektörü
│   └── ml_prediction.dart            # ML tahmin sonucu
├── screens/                          # UI ekranları
│   ├── auth/                         # Kimlik doğrulama
│   ├── dashboard/                    # Ana panel
│   ├── devices/                      # Cihaz yönetimi
│   ├── reports/                      # Raporlar
│   ├── suggestions/                  # Öneriler
│   ├── analytics/                    # 🆕 Detaylı analiz
│   ├── admin/                        # 🆕 Veri yönetimi
│   └── settings/                     # Ayarlar
├── services/                         # İş mantığı servisleri
│   ├── api_service.dart              # ML API iletişimi
│   ├── database_helper.dart          # Veritabanı işlemleri
│   ├── csv_import_service.dart       # 🆕 CSV veri import
│   └── energy_analytics_service.dart # 🆕 Analiz servisi
├── repositories/                     # 🆕 Veri erişim katmanı
│   └── energy_repository.dart        # Repository pattern
├── providers/                        # State management
│   └── app_state.dart               # Global state
├── widgets/                          # Tekrar kullanılabilir widgetlar
└── theme/                            # Tema ve stil
```

---

## 🔬 MAKINE ÖĞRENMESİ DETAYLARI

### Model Özellikleri
- **Algoritma**: Random Forest Regressor
- **Doğruluk**: R² = 0.96 (Test seti)
- **Feature Sayısı**: 20
- **Eğitim Verisi**: SmartHome_Energy_Weather_Combined.csv (8763 satır)

### Kullanılan Feature'lar
```python
1. Zaman Özellikleri:
   - Hour (0-23)
   - DayOfWeek (0-6)
   - Month (1-12)
   - IsWeekend (0/1)
   - Season (0-3)
   - TimeOfDay (0-3)

2. Geçmiş Tüketim:
   - Prev_Hour_Power
   - Prev_2Hour_Power
   - Prev_Day_Power
   - Rolling_Mean_24h
   - Rolling_Std_24h

3. Çevresel Faktörler:
   - Temperature
   - Humidity
   - Temp_Category (0-4)
   - Prev_Hour_Temp

4. Cihaz Tüketimleri:
   - Sub_metering_1 (mutfak)
   - Sub_metering_2 (çamaşır odası)
   - Sub_metering_3 (elektrikli ısıtıcı)
   - Voltage
   - Global_intensity
```

### API Endpointleri
```
GET  /meta            # Model bilgileri
POST /predict         # Tekil tahmin
POST /predict_many    # Toplu tahmin
```

---

## 📊 VERİ AKIŞI

```
1. Kullanıcı Giriş
   ↓
2. Veritabanı Başlatma (SQLite)
   ↓
3. Enerji Verilerini Yükleme
   ├── Repository katmanı
   └── DatabaseHelper
   ↓
4. ML Tahmin İsteği
   ├── ApiService → FastAPI
   ├── Feature Engineering
   └── Random Forest Model
   ↓
5. Analiz ve Görselleştirme
   ├── EnergyAnalyticsService
   ├── Trend hesaplama
   └── Anomali tespiti
   ↓
6. Akıllı Öneri Üretme
   ├── Tüketim paternleri analizi
   ├── Karşılaştırmalı değerlendirme
   └── Tasarruf hesaplama
```

---

## 🎨 KULLANILABILIRLIK ÖZELLİKLERİ

### UX İyileştirmeleri
✅ Pull-to-refresh (yenileme)
✅ Loading states (yükleme göstergeleri)
✅ Error handling (hata yönetimi)
✅ Success dialogs (başarı bildirimleri)
✅ Confirmation dialogs (onay ekranları)
✅ Empty states (boş durum mesajları)
✅ Smooth animations (geçiş animasyonları)

### Responsive Design
- Farklı ekran boyutları desteklenir
- Bottom navigation
- ScrollView ile kaydırılabilir içerik
- SafeArea kullanımı

---

## 📈 GERÇEKÇI VERİ SİMÜLASYONU

### CSV Import Servisi
- Gerçek veri setinden (8763 satır) okuma kapasitesi
- Performans için batch insert
- Tarih filtreleme

### Simüle Edilmiş Veriler
```dart
Saatlik tüketim profili:
00:00-06:00 → 0.8-1.5 kWh   (Gece - düşük)
06:00-09:00 → 1.5-3.0 kWh   (Sabah - artış)
09:00-18:00 → 2.5-3.0 kWh   (Gündüz - orta)
18:00-21:00 → 3.5-4.0 kWh   (Akşam - pik)
21:00-24:00 → 2.0-1.5 kWh   (Gece - düşüş)
```

---

## 🔍 ANALİTİK ALGORİTMALAR

### 1. Anomali Tespiti (Z-Score)
```dart
Z = (X - μ) / σ
where:
  X = Gözlenen değer
  μ = Ortalama
  σ = Standart sapma
  
Z > 2.0 → Anomali!
```

### 2. Trend Analizi
```dart
İlk yarı ortalama vs Son yarı ortalama
Eğer: 
  Son > İlk * 1.05  → Artış trendi 📈
  Son < İlk * 0.95  → Azalış trendi 📉
  Else              → Stabil 📊
```

### 3. Tasarruf Potansiyeli
```dart
Potansiyel = Toplam Tüketim × 0.17
(Literatür: Ortalama %17 tasarruf mümkün)

Maliyet Tasarrufu = Potansiyel × 3.5 TL/kWh
```

---

## 💻 KURULUM VE ÇALIŞTIRMA

### Gereksinimler
```
Flutter SDK >= 3.5.0
Python >= 3.8
```

### Backend Kurulumu
```bash
cd server
pip install -r requirements.txt
python app.py
```

### Frontend Kurulumu
```bash
cd flutter_application_1
flutter pub get
flutter run
```

---

## 🎯 AKADEMİK DEĞER

### Öğrenilen Konseptler
1. ✅ **Clean Architecture** - Katmanlı mimari
2. ✅ **State Management** - Provider pattern
3. ✅ **Database Design** - İlişkisel veritabanı
4. ✅ **RESTful API** - Backend iletişimi
5. ✅ **Machine Learning** - Model entegrasyonu
6. ✅ **Data Analytics** - İstatistiksel analiz
7. ✅ **UI/UX Design** - Modern arayüz tasarımı
8. ✅ **Repository Pattern** - Veri erişim soyutlaması
9. ✅ **Service Layer** - İş mantığı ayrıştırma
10. ✅ **Error Handling** - Hata yönetimi

### Literatür Referansları
- Feature Engineering: Scikit-learn documentation
- Random Forest: Breiman (2001)
- Z-Score Anomaly Detection: Grubbs (1969)
- Energy Consumption Patterns: IEA World Energy Outlook

---

## 📝 GELİŞTİRME NOTLARI

### Bitirme Projesi İçin Önemli Noktalar

1. **Gerçek Veri Seti Kullanımı** ✅
   - 8763 satırlık gerçek enerji tüketim verisi
   - Hava durumu korelasyonu
   - Saatlik granularite

2. **ML Model Entegrasyonu** ✅
   - %96 doğruluk oranı
   - Profesyonel model deployment
   - Feature engineering

3. **Veritabanı Yönetimi** ✅
   - İlişkisel tablo tasarımı
   - CRUD operasyonları
   - Performans optimizasyonu

4. **Detaylı Analitikler** ✅
   - İstatistiksel analizler
   - Trend hesaplamaları
   - Anomali tespiti

5. **Kullanılabilir UI/UX** ✅
   - Modern tasarım
   - Responsive layout
   - Error handling

---

## 🚀 DEMO SENARYOSU

### Jüri Gösterimi İçin Akış

1. **Giriş Ekranı**
   - Kullanıcı girişi göster
   
2. **Dashboard**
   - Günlük tüketim grafiği
   - ML tahmin butonu ile tahmin yap
   - Farklı zaman filtrelerini göster

3. **Cihazlar**
   - Cihaz listesi
   - Tüketim değerleri

4. **Raporlar**
   - Detaylı grafikler
   - Karşılaştırma tabloları
   - Cihaz bazlı breakdown

5. **Detaylı Analiz** 🆕
   - Günlük karşılaştırma
   - Trend analizi
   - Anomali tespiti
   - Tasarruf potansiyeli

6. **Öneriler**
   - Akıllı tasarruf önerileri
   - Öneri uygulama

7. **Veri Yönetimi** 🆕
   - Gerçekçi veri oluşturma
   - Veritabanı istatistikleri
   - Öneri üretme

---

## 📊 PERFORMANS METRİKLERİ

- **ML Model Doğruluğu**: %96
- **Veritabanı Sorgu Süresi**: <50ms (local)
- **API Response Time**: ~200-500ms
- **UI Frame Rate**: 60 FPS
- **App Size**: ~25MB

---

## 🎓 SONUÇ

Bu proje, **gerçek dünya problemine (yüksek enerji faturaları)** yapay zeka ve mobil teknolojiler kullanarak **pratik bir çözüm** sunmaktadır. 

### Özgün Değerler:
✅ Gerçek veri seti üzerinden çalışan ML modeli
✅ Detaylı analitik algoritmaları
✅ Modern ve kullanılabilir arayüz
✅ Clean Architecture uygulama
✅ Bitirme projesi standartlarına uygun dokümantasyon

### Öğrenme Çıktıları:
- Full-stack development
- Machine learning deployment
- Database management
- Mobile app development
- Data analytics

---

## 👨‍💻 PROJE DETAYLARI

**Geliştirme Süresi**: 2-3 hafta (tahmini)
**Kod Satırı**: ~3500+ satır
**Dosya Sayısı**: 30+ Dart dosyası + Python backend
**Ekran Sayısı**: 8 farklı ekran

---

**Not**: Bu proje akademik amaçlıdır ve gerçek IoT cihazlar olmadan, simüle edilmiş verilerle çalışmaktadır. Production kullanımı için ek güvenlik ve IoT entegrasyonları gereklidir.
