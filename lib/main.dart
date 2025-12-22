import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/devices/devices_screen.dart';
import 'screens/suggestions/suggestions_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase geçici olarak kaldırıldı - Mobil için google-services.json gerekiyor
  // Google Sign-In şu anda çalışmayacak, email/password kullanın

  // Hataları yakalayarak kırmızı ekran yerine beyaz ekran göster
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // ErrorWidget builder'ı özelleştir
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  };

  // Mobil için yatay kilit (sadece dikey mod)
  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Status bar renklerini ayarla (Android/iOS)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Windows/Linux/macOS için sqflite_ffi kullan
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Veritabanını arka planda başlat
  DatabaseHelper.instance.database.then((db) {
    debugPrint('Database initialized successfully');
    return db;
  }).catchError((error) {
    debugPrint('Database initialization error: $error');
    return DatabaseHelper.instance.database;
  });

  runApp(const SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ Building SmartHomeApp...');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          debugPrint('🔧 Creating AppState...');
          final appState = AppState();
          // Dili ve temayı yükle
          appState.loadLanguage();
          appState.loadTheme();
          debugPrint('✅ AppState created');
          return appState;
        }),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          debugPrint('📱 Building MaterialApp...');
          return MaterialApp(
            title: 'Akıllı Ev Enerji',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
            routes: {
              '/onboarding': (context) => const OnboardingScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/devices': (context) => const DevicesScreen(),
              '/reports': (context) => const ReportsScreen(),
              '/suggestions': (context) => const SuggestionsScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/analytics': (context) => const AnalyticsScreen(),
              '/admin': (context) => const AdminScreen(),
            },
          );
        },
      ),
    );
  }
}
