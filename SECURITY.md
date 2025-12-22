# 🔒 Güvenlik Politikası (Security Policy)

## 🛡️ Güvenlik Önlemleri

Bu proje eğitim amaçlı geliştirilmiştir ve aşağıdaki güvenlik önlemlerini içerir:

### ✅ Uygulanan Güvenlik Önlemleri

1. **API Keys Gizliliği**
   - Firebase credentials `.gitignore`'da
   - Weather API key'leri environment variable olarak
   - `.env.example` dosyası ile rehberlik

2. **Hassas Bilgiler**
   - Admin credentials environment variable'dan alınıyor
   - Şifreler plaintext olarak saklanmıyor (production'da hash kullanılmalı)
   - Database bilgileri local olarak tutuluyor

3. **Git Güvenliği**
   - `firebase_config.dart` GitHub'a yüklenmiyor
   - `.env` dosyaları ignore ediliyor
   - Hassas dosyalar `.gitignore`'da tanımlı

### ⚠️ Bilinen Güvenlik Uyarıları

Bu proje **eğitim amaçlıdır** ve production'da aşağıdaki iyileştirmeler yapılmalıdır:

1. **Authentication**
   - ❌ Şu anda basit email/password kontrolü var
   - ✅ Production'da JWT veya OAuth2 kullanılmalı
   - ✅ Şifreler bcrypt ile hash'lenmeli

2. **Admin Panel**
   - ❌ Hardcoded admin credentials (env variable ile gizlenmiş)
   - ✅ Production'da role-based access control (RBAC) eklenebilir
   - ✅ Admin girişleri loglanmalı

3. **API Güvenliği**
   - ❌ API endpoint'leri şu anda açık
   - ✅ Production'da rate limiting eklenebilir
   - ✅ API token authentication kullanılmalı

4. **Data Validation**
   - ✅ Form validasyonu yapılıyor
   - ✅ Input sanitization var
   - ⚠️ SQL injection riski düşük (SQLite prepared statements kullanıyor)

## 🔐 Production Önerileri

### Firebase Kullanımı
```dart
// ✅ İYİ - Environment variable kullan
String apiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';

// ❌ KÖTÜ - Hardcoded API key
String apiKey = "AIzaSy...";
```

### Şifre Yönetimi
```dart
// ✅ İYİ - Hash kullan
String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

// ❌ KÖTÜ - Plaintext karşılaştırma
if (password == "admin123") { }
```

### API Keys
```bash
# .env dosyasında
WEATHER_API_KEY=your_actual_key_here
FIREBASE_API_KEY=your_firebase_key

# Flutter'da kullanım
flutter run --dart-define=WEATHER_API_KEY=your_key
```

## 📝 Güvenlik Kontrol Listesi

Production'a geçmeden önce:

- [ ] Tüm API keys environment variable'dan alınıyor
- [ ] Firebase credentials gizli
- [ ] Admin şifreleri hash'lenmiş
- [ ] HTTPS kullanılıyor
- [ ] Input validation tamamlanmış
- [ ] Rate limiting var
- [ ] Error messages hassas bilgi içermiyor
- [ ] Loglar sanitize edilmiş
- [ ] CORS policy ayarlanmış
- [ ] SQL injection koruması var

## 🐛 Güvenlik Açığı Bildirimi

Güvenlik açığı bulduysanız:

1. ❌ **Açık issue açmayın**
2. ✅ **GitHub Security Advisory** kullanın
3. ✅ Veya direkt geliştiriciye ulaşın

## 📚 Kaynaklar

- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)

---

**Not**: Bu proje **eğitim amaçlıdır**. Production kullanımı için profesyonel güvenlik denetimi yapılmalıdır.
