# Firebase Mobil Kurulum Rehberi

Bu rehber, Android ve iOS cihazlarda Firebase Authentication ve Google Sign-In'i yapılandırmak için gerekli adımları içerir.

## ✅ Tamamlanan Adımlar

1. ✅ Firebase paketleri pubspec.yaml'a eklendi
2. ✅ Firebase Auth Service oluşturuldu
3. ✅ Login screen Firebase için güncellendi
4. ✅ main.dart Firebase başlatma kodu eklendi
5. ✅ Android build.gradle dosyaları güncellendi

## 🔧 Yapılması Gerekenler

### 1. Firebase Console'da Proje Oluşturma

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. "Add project" butonuna tıklayın
3. Proje adı girin: `smart-home-energy` veya istediğiniz bir ad
4. Google Analytics'i isteğe bağlı olarak etkinleştirin
5. Projeyi oluşturun

### 2. Android İçin Firebase Yapılandırması

#### 2.1. Firebase'e Android Uygulaması Ekleyin

1. Firebase Console'da projenize gidin
2. "Add app" > Android ikonuna tıklayın
3. **Android package name**: `com.smarthome.energy`
   - ⚠️ Bu değer `android/app/build.gradle` dosyasındaki `applicationId` ile aynı olmalı
4. **App nickname**: Smart Home Energy (opsiyonel)
5. **Debug signing certificate SHA-1**: (Google Sign-In için gerekli)
   
   Terminalden alın:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   
   Veya Windows için:
   ```powershell
   cd android
   gradlew.bat signingReport
   ```
   
   Çıktıda "SHA1" değerini bulun ve Firebase'e yapıştırın.

6. "Register app" butonuna tıklayın

#### 2.2. google-services.json Dosyasını İndirin

1. Firebase Console'dan `google-services.json` dosyasını indirin
2. Dosyayı şu klasöre koyun:
   ```
   android/app/google-services.json
   ```

#### 2.3. Google Sign-In'i Etkinleştirin

1. Firebase Console > Authentication > Sign-in method
2. "Google" sağlayıcısını etkinleştirin
3. Proje support email'i ayarlayın
4. "Save" butonuna tıklayın

### 3. iOS İçin Firebase Yapılandırması

#### 3.1. Firebase'e iOS Uygulaması Ekleyin

1. Firebase Console'da projenize gidin
2. "Add app" > iOS ikonuna tıklayın
3. **iOS bundle ID**: `com.smarthome.energy`
   - ⚠️ Bu değer `ios/Runner/Info.plist` dosyasındaki bundle identifier ile aynı olmalı
4. **App nickname**: Smart Home Energy (opsiyonel)
5. "Register app" butonuna tıklayın

#### 3.2. GoogleService-Info.plist Dosyasını İndirin

1. Firebase Console'dan `GoogleService-Info.plist` dosyasını indirin
2. Xcode'da projeyi açın:
   ```bash
   open ios/Runner.xcworkspace
   ```
3. `GoogleService-Info.plist` dosyasını Runner klasörüne sürükleyin
   - ✅ "Copy items if needed" seçeneğini işaretleyin
   - ✅ Target olarak "Runner"ı seçin

#### 3.3. iOS Yapılandırması

`ios/Runner/Info.plist` dosyasına şu kodu ekleyin (</dict> etiketinden önce):

```xml
<!-- Google Sign-In için -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- GoogleService-Info.plist'ten REVERSED_CLIENT_ID değerini buraya yapıştırın -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

⚠️ `YOUR-CLIENT-ID` değerini `GoogleService-Info.plist` dosyasından alın:
- Dosyayı açın
- `REVERSED_CLIENT_ID` değerini bulun
- Yukardaki `YOUR-CLIENT-ID` yerine yapıştırın

### 4. Test Etme

#### Android'de Test

```bash
# Android cihaz/emülatör bağlayın
flutter devices

# Uygulamayı çalıştırın
flutter run -d android
```

#### iOS'da Test (Mac gerekli)

```bash
# iOS simülatör/cihaz bağlayın
flutter devices

# Uygulamayı çalıştırın
flutter run -d ios
```

### 5. Doğrulama Kontrol Listesi

Uygulamayı çalıştırdıktan sonra:

- [ ] Uygulama hatasız açılıyor
- [ ] Login ekranında "Google ile Giriş Yap" butonu görünüyor
- [ ] Google Sign-In butonuna tıklandığında:
  - Windows'ta: "Sadece mobil cihazlarda desteklenir" mesajı görünüyor ✅
  - Android/iOS'ta: Google hesap seçim ekranı açılıyor
- [ ] Google hesabı seçildikten sonra Dashboard'a yönlendiriliyor
- [ ] Çıkış yapıp tekrar Google ile giriş yapılabiliyor

### 6. Yaygın Hatalar ve Çözümleri

#### "google-services.json not found"
- `android/app/` klasöründe dosya olduğundan emin olun
- `flutter clean` ve `flutter pub get` çalıştırın

#### "SHA-1 certificate error"
- SHA-1 sertifikasını Firebase Console'a ekleyin
- Debug ve Release SHA-1'leri farklıdır

#### "API key not valid"
- `google-services.json` dosyasının doğru projeden indirildiğinden emin olun
- Firebase Console'da Authentication > Google'ın etkin olduğunu kontrol edin

#### "PlatformException (sign_in_failed)"
- SHA-1 sertifikası eksik olabilir
- Package name yanlış olabilir (`com.smarthome.energy`)
- Google Sign-In Firebase'de etkin değil

### 7. Güvenlik Notları

🔒 **ÖNEMLİ**: 
- `google-services.json` ve `GoogleService-Info.plist` dosyaları hassas bilgiler içerir
- Bu dosyaları public repository'lere yüklememeye dikkat edin
- `.gitignore` dosyanıza şunları ekleyin:

```gitignore
# Firebase yapılandırma dosyaları
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
ios/firebase_app_id_file.json
```

### 8. Ek Kaynaklar

- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [Google Sign-In Flutter Package](https://pub.dev/packages/google_sign_in)
- [Firebase Auth Flutter](https://firebase.google.com/docs/auth/flutter/start)

## 🎉 Kurulum Tamamlandı!

Tüm adımları tamamladıktan sonra, mobil cihazlarda Google Sign-In çalışacaktır.

Windows'ta test ederken email/şifre ile giriş yapın:
- Email: `test@example.com`
- Şifre: `123456` (minimum 6 karakter)

veya Admin hesabı:
- Email: `root`
- Şifre: `admin123`
