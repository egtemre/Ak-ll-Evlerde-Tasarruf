import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/devices/devices_screen.dart';
import 'screens/suggestions/suggestions_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Veritabanını arka planda başlat (uygulama açılışını engellemesin)
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: 'Akıllı Ev Enerji',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/devices': (context) => const DevicesScreen(),
          '/reports': (context) => const ReportsScreen(),
          '/suggestions': (context) => const SuggestionsScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}

