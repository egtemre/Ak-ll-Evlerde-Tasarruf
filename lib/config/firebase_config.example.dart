/// Firebase Configuration - Example File
///
/// GİTHUB'A ATMADAN ÖNCE:
/// 1. Bu dosyayı kopyalayın: firebase_config.example.dart -> firebase_config.dart
/// 2. firebase_config.dart dosyasında kendi Firebase bilgilerinizi girin
/// 3. firebase_config.dart .gitignore'da olduğu için GitHub'a yüklenmez
///
/// FIREBASE KURULUMU:
/// 1. https://console.firebase.google.com adresine gidin
/// 2. Yeni proje oluşturun (veya mevcut projeyi seçin)
/// 3. Authentication > Sign-in method > Google'ı etkinleştirin
/// 4. Proje ayarlarından Web API Key'inizi alın
/// 5. Aşağıdaki değerleri kendi bilgilerinizle değiştirin
library;

class FirebaseConfig {
  // Firebase Web API Key
  static const String apiKey =
      "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"; // Buraya kendi API key'inizi girin

  // Firebase Auth Domain
  static const String authDomain =
      "your-project-id.firebaseapp.com"; // Buraya kendi domain'inizi girin

  // Firebase Project ID
  static const String projectId =
      "your-project-id"; // Buraya kendi project ID'nizi girin

  // Firebase Storage Bucket
  static const String storageBucket =
      "your-project-id.appspot.com"; // Buraya kendi storage bucket'ınızı girin

  // Firebase Messaging Sender ID
  static const String messagingSenderId =
      "123456789012"; // Buraya kendi sender ID'nizi girin

  // Firebase App ID
  static const String appId =
      "1:123456789012:web:abcdef1234567890abcdef"; // Buraya kendi app ID'nizi girin

  // Google Client ID (Web)
  static const String googleClientId =
      "123456789012-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com"; // Buraya kendi client ID'nizi girin
}
