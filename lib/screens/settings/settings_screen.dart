import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_navigation.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _darkModeEnabled = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      _darkModeEnabled = value;
    });

    // AppState'teki temayı güncelle
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.setTheme(value);

    if (mounted) {
      SnackBarHelper.showInfo(
        context,
        value ? 'Koyu tema açıldı' : 'Açık tema açıldı',
      );
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final loc = appState.loc;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        loc.settings,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          _showLogoutDialog(context, appState);
                        },
                        icon: const Icon(Icons.logout),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profil bölümü
                        _buildSectionTitle(loc.profile),
                        const SizedBox(height: 16),
                        _buildProfileCard(appState),
                        const SizedBox(height: 32),

                        // Bildirimler bölümü
                        _buildSectionTitle(loc.notifications),
                        const SizedBox(height: 16),
                        _buildNotificationCard(loc),
                        const SizedBox(height: 32),

                        // Uygulama bölümü
                        _buildSectionTitle(appState.languageCode == 'tr'
                            ? 'Uygulama'
                            : 'Application'),
                        const SizedBox(height: 16),
                        _buildAppSettingsCard(appState, loc),
                        const SizedBox(height: 32),

                        // Yardım ve Destek bölümü
                        _buildSectionTitle(loc.help),
                        const SizedBox(height: 16),
                        _buildHelpCard(loc),
                        const SizedBox(height: 32),

                        // Hukuki bölümü
                        _buildSectionTitle(
                            appState.languageCode == 'tr' ? 'Hukuki' : 'Legal'),
                        const SizedBox(height: 16),
                        _buildLegalCard(appState),

                        const SizedBox(
                            height: 100), // Bottom navigation için boşluk
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const CustomBottomNavigation(),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProfileCard(AppState appState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profil resmi
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Kullanıcı bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.userName.isNotEmpty
                      ? appState.userName
                      : 'Emre Kaya',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appState.userEmail.isNotEmpty
                      ? appState.userEmail
                      : 'emre.kaya@email.com',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppLocalizations loc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.notifications,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.notificationDesc,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsCard(AppState appState, AppLocalizations loc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(loc.detailedAnalysis, '', () {
            Navigator.pushNamed(context, '/analytics');
          }),
          const Divider(height: 1),
          _buildSettingItem(loc.dataManagement, loc.developer, () {
            Navigator.pushNamed(context, '/admin');
          }),
          const Divider(height: 1),
          _buildLanguageSelector(appState),
          const Divider(height: 1),
          _buildDarkModeToggle(loc),
          const Divider(height: 1),
          _buildSettingItem(loc.deviceConnection, '', () {}),
        ],
      ),
    );
  }

  Widget _buildHelpCard(AppLocalizations loc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(loc.faq, '', () {}),
          const Divider(height: 1),
          _buildSettingItem(loc.energyTips, '', () {}),
          const Divider(height: 1),
          _buildSettingItem(
            loc.showIntro,
            loc.showIntroDesc,
            () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('onboarding_completed');
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Tanıtım sıfırlandı. Uygulama yeniden başlatın.'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeToggle(AppLocalizations loc) {
    return ListTile(
      title: Text(
        loc.darkMode,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _darkModeEnabled ? 'Açık' : 'Kapalı',
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Switch(
        value: _darkModeEnabled,
        onChanged: _toggleDarkMode,
        activeColor: AppTheme.primaryColor,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildLegalCard(AppState appState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            appState.languageCode == 'tr'
                ? 'Gizlilik Politikası'
                : 'Privacy Policy',
            '',
            () {},
          ),
          const Divider(height: 1),
          _buildSettingItem(
            appState.languageCode == 'tr'
                ? 'Kullanım Şartları'
                : 'Terms of Service',
            '',
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
                fontSize: 14,
              ),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }

  Widget _buildLanguageSelector(AppState appState) {
    final languageName = appState.languageCode == 'tr' ? 'Türkçe' : 'English';

    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('Dil'),
      subtitle: Text(languageName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showLanguageDialog(appState);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }

  void _showLanguageDialog(AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String selectedLanguage = appState.languageCode;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Dil Seçin / Select Language'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Türkçe'),
                    leading: Icon(
                      selectedLanguage == 'tr'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selectedLanguage == 'tr'
                          ? AppTheme.primaryColor
                          : Colors.grey,
                    ),
                    onTap: () {
                      setState(() {
                        selectedLanguage = 'tr';
                      });
                      appState.changeLanguage('tr');
                      Navigator.pop(dialogContext);
                      if (mounted) {
                        SnackBarHelper.showInfo(
                            this.context, 'Dil Türkçe olarak değiştirildi');
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('English'),
                    leading: Icon(
                      selectedLanguage == 'en'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selectedLanguage == 'en'
                          ? AppTheme.primaryColor
                          : Colors.grey,
                    ),
                    onTap: () {
                      setState(() {
                        selectedLanguage = 'en';
                      });
                      appState.changeLanguage('en');
                      Navigator.pop(dialogContext);
                      if (mounted) {
                        SnackBarHelper.showInfo(
                            this.context, 'Language changed to English');
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text(
              'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                appState.logout();

                // Clear session
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (!context.mounted) return;
                Navigator.of(context).pop();
                SnackBarHelper.showInfo(context, 'Çıkış yapıldı');
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }
}
