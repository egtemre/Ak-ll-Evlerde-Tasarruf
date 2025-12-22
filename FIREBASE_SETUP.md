# 🔥 Firebase Google Sign-In Kurulum Rehberi

Bu proje **Firebase Authentication** kullanarak güvenli Google Sign-In özelliği sunmaktadır.

## 📋 Gereksinimler

- Flutter SDK (3.5.0 veya üzeri)
- Firebase hesabı (ücretsiz)
- Google Cloud Console erişimi

---

## 🚀 Kurulum Adımları

### 1️⃣ Firebase Projesi Oluşturma

1. [Firebase Console](https://console.firebase.google.com)'a gidin
2. **"Add project"** veya **"Proje ekle"** butonuna tıklayın
3. Proje adı girin (örn: `smart-home-energy`)
4. Google Analytics'i etkinleştirin (opsiyonel)
5. Projeyi oluşturun

### 2️⃣ Firebase Authentication'ı Etkinleştirme

1. Firebase Console'da projenizi açın
2. Sol menüden **"Authentication"** seçin
3. **"Get started"** veya **"Başlayın"** butonuna tıklayın
4. **"Sign-in method"** sekmesine gidin
5. **"Google"** sağlayıcısını etkinleştirin:
   - Google'ı seçin
   - **"Enable"** (Etkinleştir) toggle'ını açın
   - Proje public-facing adını girin
   - Support email seçin
   - **"Save"** (Kaydet) butonuna tıklayın

### 3️⃣ Web App Ekleme

1. Firebase Console'da projenizi açın
2. Proje ayarlarına gidin (⚙️ ikonu)
3. **"Your apps"** bölümünde **"</>"** (Web) ikonuna tıklayın
4. App nickname girin (örn: `Smart Home Web`)
5. **"Register app"** butonuna tıklayın
6. Firebase SDK configuration bilgilerini kopyalayın

### 4️⃣ Firebase Config Dosyasını Oluşturma

1. Bu projedeki `lib/config/firebase_config.example.dart` dosyasını kopyalayın:
   ```bash
   cp lib/config/firebase_config.example.dart lib/config/firebase_config.dart
   ```

2. `lib/config/firebase_config.dart` dosyasını açın

3. Firebase Console'dan aldığınız bilgileri yapıştırın:
   ```dart
   class FirebaseConfig {
     static const String apiKey = "AIzaSy...";  // Web API Key
     static const String authDomain = "your-project.firebaseapp.com";
     static const String projectId = "your-project-id";
     static const String storageBucket = "your-project.appspot.com";
     static const String messagingSenderId = "123456789012";
     static const String appId = "1:123...:web:abc...";
     static const String googleClientId = "123...-xxx.apps.googleusercontent.com";
   }
   ```

### 5️⃣ Paketleri Yükleme

```bash
flutter pub get
```

### 6️⃣ Uygulamayı Çalıştırma

```bash
# Windows
flutter run -d windows

# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

---

## 🔒 Güvenlik Notları

### ⚠️ ÖNEMLİ: API Key'leri GitHub'a Yüklemeyin!

`firebase_config.dart` dosyası `.gitignore`'da kayıtlıdır ve otomatik olarak Git'e eklenmez.

**GitHub'a yüklerken kontrol edin:**
```bash
git status  # firebase_config.dart dosyası listelenmemeli
```

### 📁 Güvenli Dosyalar

Aşağıdaki dosyalar `.gitignore`'dadır ve GitHub'a yüklenmez:
- `lib/config/firebase_config.dart` ✅
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)
- `.env` dosyaları

### 📝 Örnek Dosya

`firebase_config.example.dart` dosyası şablon olarak GitHub'a yüklenmiştir.
Diğer geliştiriciler bu dosyayı kopyalayıp kendi Firebase bilgilerini girebilir.

---

## 🎯 Kullanım

### Google ile Giriş Yapma

1. Uygulamayı çalıştırın
2. Login ekranında **"Google ile Devam Et"** butonuna tıklayın
3. Google hesabınızı seçin
4. İzinleri onaylayın
5. Otomatik olarak dashboard'a yönlendirileceksiniz

### Çıkış Yapma

1. Ayarlar ekranına gidin
2. **"Çıkış Yap"** butonuna tıklayın

---

## 🐛 Sorun Giderme

### Firebase initialization error

**Hata:**  `Firebase initialization error`

**Çözüm:** 
1. `firebase_config.dart` dosyasının doğru oluşturulduğundan emin olun
2. API key'lerinizin doğru kopyalandığından emin olun
3. Firebase Console'da projenin aktif olduğundan emin olun

### Google Sign-In cancelled

**Hata:** Kullanıcı girişi iptal etti

**Çözüm:** Normal bir durum - kullanıcı giriş ekranını kapattı

### PlatformException: sign_in_failed

**Hata:** Google Sign-In başarısız

**Çözüm:**
1. Firebase Console'da Google authentication'ın etkin olduğundan emin olun
2. OAuth 2.0 Client ID'nin doğru yapılandırıldığından emin olun
3. İnternet bağlantınızı kontrol edin

---

## 📱 Platform Özel Kurulum

### Android

1. Firebase Console'da Android app ekleyin
2. `google-services.json` dosyasını indirin
3. `android/app/` klasörüne kopyalayın

### iOS

1. Firebase Console'da iOS app ekleyin
2. `GoogleService-Info.plist` dosyasını indirin
3. Xcode ile projeye ekleyin

### Web

Yukarıdaki adımlar Web için yeterlidir. Ek kurulum gerekmez.

---

## 📚 Ek Kaynaklar

- [Firebase Authentication Docs](https://firebase.google.com/docs/auth)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Google Sign-In Package](https://pub.dev/packages/google_sign_in)

---

## 📄 Lisans

Bu proje MIT lisansı altındadır.

---

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit edin (`git commit -m 'Add amazing feature'`)
4. Push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

**Not:** PR göndermeden önce `firebase_config.dart` dosyasının commit edilmediğinden emin olun!
