import 'package:flutter/material.dart';
import '../../services/csv_import_service.dart';
import '../../services/database_helper.dart';
import '../../services/energy_analytics_service.dart';
import '../../repositories/energy_repository.dart';
import '../../theme/app_theme.dart';
import '../../utils/snackbar_helper.dart';

/// Veri yönetimi ve test ekranı
/// CSV import, veritabanı yönetimi, test verileri
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final CSVImportService _csvService = CSVImportService();
  final DatabaseHelper _db = DatabaseHelper.instance;
  final EnergyRepository _repository = EnergyRepository();
  final EnergyAnalyticsService _analytics = EnergyAnalyticsService();

  bool _isLoading = false;
  String _statusMessage = '';
  int _totalReadings = 0;
  int _totalDevices = 0;
  int _totalRecommendations = 0;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _buildings = [];
  List<Map<String, dynamic>> _topBuildings = [];
  double _totalConsumption = 0.0;
  int _selectedTab = 0;

  // SQL Query
  final TextEditingController _sqlController = TextEditingController();
  List<Map<String, dynamic>> _sqlResults = [];
  String _sqlError = '';

  @override
  void initState() {
    super.initState();
    // Build tamamlandıktan sonra verileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats();
      _loadUsers();
      _loadDailyConsumption();
      _loadTopBuildings();
    });
  }

  @override
  void dispose() {
    _sqlController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final db = await _db.database;
    final users = await db.query('Users');
    final buildings = await db.query('Buildings');
    if (!mounted) return;
    setState(() {
      _users = users;
      _buildings = buildings;
    });
  }

  Future<void> _loadDailyConsumption() async {
    final db = await _db.database;
    // Son 7 günlük günlük tüketim
    final result = await db.rawQuery('''
      SELECT 
        b.name as building_name,
        DATE(e.timestamp) as date,
        SUM(e.total_kwh) as total_kwh,
        COUNT(*) as reading_count
      FROM Energy_Readings e
      JOIN Buildings b ON e.building_id = b.building_id
      WHERE datetime(e.timestamp) >= datetime('now', '-7 days')
      GROUP BY b.building_id, DATE(e.timestamp)
      ORDER BY date DESC, total_kwh DESC
    ''');

    // Toplam tüketimi hesapla
    double total = 0.0;
    for (var row in result) {
      total += (row['total_kwh'] as num?)?.toDouble() ?? 0.0;
    }

    if (!mounted) return;
    setState(() {
      _totalConsumption = total;
    });
  }

  Future<void> _loadTopBuildings() async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT 
        b.building_id,
        b.name as building_name,
        b.address,
        SUM(e.total_kwh) as total_kwh,
        COUNT(*) as reading_count
      FROM Buildings b
      LEFT JOIN Energy_Readings e ON b.building_id = e.building_id
      GROUP BY b.building_id
      ORDER BY total_kwh DESC
      LIMIT 10
    ''');
    if (!mounted) return;
    setState(() {
      _topBuildings = result;
    });
  }

  Future<void> _loadStats() async {
    final readings = await _repository.getAllReadings();
    final devices = await _repository.getAllDevices();
    final recommendations = await _repository.getAllRecommendations();

    if (!mounted) return;
    setState(() {
      _totalReadings = readings.length;
      _totalDevices = devices.length;
      _totalRecommendations = recommendations.length;
    });

    await _loadUsers();
    await _loadDailyConsumption();
    await _loadTopBuildings();
  }

  Future<void> _seedRealisticData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Gerçekçi veriler oluşturuluyor...';
    });

    try {
      await _csvService.seedRealisticData();
      await _loadStats();

      setState(() {
        _isLoading = false;
        _statusMessage = '✅ 7 günlük veri başarıyla eklendi!';
      });

      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          '7 günlük saatlik enerji verileri eklendi',
        );
      }

      _showSuccessDialog('Gerçekçi Veri Eklendi',
          '7 günlük saatlik enerji tüketim verileri başarıyla oluşturuldu.');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Hata: $e';
      });

      if (mounted) {
        SnackBarHelper.showError(
          context,
          'Veri oluşturulamadı: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _generateRecommendations() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Akıllı öneriler oluşturuluyor...';
    });

    try {
      final recommendations = await _analytics.generateSmartRecommendations();

      for (final rec in recommendations) {
        await _repository.addRecommendation(rec);
      }

      await _loadStats();

      setState(() {
        _isLoading = false;
        _statusMessage = '✅ ${recommendations.length} öneri oluşturuldu!';
      });

      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          '${recommendations.length} akıllı tasarruf önerisi oluşturuldu',
        );
      }

      _showSuccessDialog('Öneriler Oluşturuldu',
          '${recommendations.length} akıllı tasarruf önerisi başarıyla oluşturuldu.');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Hata: $e';
      });

      if (mounted) {
        SnackBarHelper.showError(
          context,
          'Öneriler oluşturulamadı: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await _showConfirmDialog(
      'Tüm Verileri Sil',
      'Tüm enerji kayıtları, cihazlar ve öneriler silinecek. Emin misiniz?',
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Veriler siliniyor...';
    });

    try {
      await _db.clearAllData();
      await _loadStats();

      setState(() {
        _isLoading = false;
        _statusMessage = '✅ Tüm veriler silindi!';
      });

      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          'Tüm veriler başarıyla silindi',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Hata: $e';
      });

      if (mounted) {
        SnackBarHelper.showError(
          context,
          'Veriler silinemedi: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings,
                      color: AppTheme.primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Admin Paneli',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              color: isDark ? Colors.grey[850] : Colors.white,
              child: Row(
                children: [
                  _buildTab('📊 Dashboard', 0),
                  _buildTab('👥 Kullanıcılar', 1),
                  _buildTab('🏠 Evler', 2),
                  _buildTab('⚙️ Veri', 3),
                  _buildTab('💾 SQL', 4),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _selectedTab == 0
                  ? _buildDashboardTab()
                  : _selectedTab == 1
                      ? _buildUsersTab()
                      : _selectedTab == 2
                          ? _buildBuildingsTab()
                          : _selectedTab == 3
                              ? _buildDataManagementTab()
                              : _buildSQLTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? AppTheme.primaryColor
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sistemdeki Kullanıcılar',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                FilledButton.icon(
                  onPressed: () => _showAddUserDialog(),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Yeni Kullanıcı'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kullanıcı listesi
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final userBuildings = _buildings
                    .where((b) => b['user_id'] == user['user_id'])
                    .toList();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isDark ? Colors.grey[850] : Colors.white,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      child: Text(
                        user['name']
                                ?.toString()
                                .substring(0, 1)
                                .toUpperCase() ??
                            'U',
                        style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(user['name'] ?? 'Kullanıcı'),
                    subtitle: Text(user['email'] ?? ''),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Düzenle'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Sil', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditUserDialog(user);
                        } else if (value == 'delete') {
                          _deleteUser(user['user_id'] as int);
                        }
                      },
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Evleri (${userBuildings.length})',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...userBuildings.map((building) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.home,
                                          size: 16,
                                          color: AppTheme.primaryColor),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(building['name'] ?? '',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            Text(building['address'] ?? '',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600])),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genel Bakış',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // İstatistik kartları
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.people,
                    title: 'Kullanıcılar',
                    value: '${_users.length}',
                    color: Colors.blue,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.home,
                    title: 'Evler',
                    value: '${_buildings.length}',
                    color: Colors.green,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.bar_chart,
                    title: 'Okumar',
                    value: '$_totalReadings',
                    color: Colors.orange,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.bolt,
                    title: 'Toplam kWh',
                    value: _totalConsumption.toStringAsFixed(1),
                    color: Colors.purple,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // En çok tüketen evler
            Text(
              'En Çok Tüketen Evler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            if (_topBuildings.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Henüz veri yok',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _topBuildings.length,
                itemBuilder: (context, index) {
                  final building = _topBuildings[index];
                  final kwh =
                      (building['total_kwh'] as num?)?.toDouble() ?? 0.0;
                  final readingCount = building['reading_count'] as int? ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isDark ? Colors.grey[850] : Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title:
                          Text(building['building_name']?.toString() ?? 'Ev'),
                      subtitle: Text(building['address']?.toString() ?? ''),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${kwh.toStringAsFixed(1)} kWh',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            '$readingCount okuma',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        await _loadUsers();
        await _loadTopBuildings();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tüm Evler',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                FilledButton.icon(
                  onPressed: () => _showAddBuildingDialog(),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Yeni Ev'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_buildings.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Henüz ev eklenmemiş',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _buildings.length,
                itemBuilder: (context, index) {
                  final building = _buildings[index];
                  final user = _users.firstWhere(
                    (u) => u['user_id'] == building['user_id'],
                    orElse: () => {'name': 'Bilinmeyen'},
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isDark ? Colors.grey[850] : Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        child: const Icon(Icons.home,
                            color: AppTheme.primaryColor),
                      ),
                      title: Text(building['name']?.toString() ?? 'Ev'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(building['address']?.toString() ?? ''),
                          Text(
                            'Sahibi: ${user['name']}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Düzenle'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Sil',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditBuildingDialog(building);
                          } else if (value == 'delete') {
                            _deleteBuilding(building['building_id'] as int);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSQLTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SQL Sorgu Çalıştır',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // SQL Query Input
          TextField(
            controller: _sqlController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'SELECT * FROM Users;',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
            ),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _executeSQLQuery,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Sorguyu Çalıştır'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  _sqlController.clear();
                  setState(() {
                    _sqlResults = [];
                    _sqlError = '';
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Temizle'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick queries
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickQueryChip('SELECT * FROM Users;'),
              _buildQuickQueryChip('SELECT * FROM Buildings;'),
              _buildQuickQueryChip('SELECT * FROM Energy_Readings LIMIT 10;'),
              _buildQuickQueryChip('SELECT * FROM Devices;'),
            ],
          ),

          const SizedBox(height: 24),

          // Error message
          if (_sqlError.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _sqlError,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          // Results
          if (_sqlResults.isNotEmpty) ...[
            Text(
              'Sonuçlar (${_sqlResults.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  AppTheme.primaryColor.withOpacity(0.1),
                ),
                columns: _sqlResults[0].keys.map((key) {
                  return DataColumn(
                    label: Text(
                      key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                rows: _sqlResults.map((row) {
                  return DataRow(
                    cells: row.values.map((value) {
                      return DataCell(Text(value?.toString() ?? 'NULL'));
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickQueryChip(String query) {
    return ActionChip(
      label: Text(query, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        _sqlController.text = query;
      },
      avatar: const Icon(Icons.code, size: 16),
    );
  }

  Future<void> _executeSQLQuery() async {
    final query = _sqlController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _sqlError = '';
      _sqlResults = [];
    });

    try {
      final db = await _db.database;
      final results = await db.rawQuery(query);

      setState(() {
        _sqlResults = results;
      });

      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          '${results.length} sonuç bulundu',
        );
      }
    } catch (e) {
      setState(() {
        _sqlError = e.toString();
      });

      if (mounted) {
        SnackBarHelper.showError(
          context,
          'Sorgu hatası: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _showAddBuildingDialog() async {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    int? selectedUserId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Yeni Ev Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedUserId,
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı',
                  border: OutlineInputBorder(),
                ),
                items: _users.map((user) {
                  return DropdownMenuItem<int>(
                    value: user['user_id'] as int,
                    child: Text(user['name']?.toString() ?? ''),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedUserId = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Ev Adı',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Adres',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () async {
                if (selectedUserId != null && nameController.text.isNotEmpty) {
                  final db = await _db.database;
                  await db.insert('Buildings', {
                    'user_id': selectedUserId,
                    'name': nameController.text,
                    'address': addressController.text,
                  });
                  await _loadUsers();
                  if (context.mounted) {
                    Navigator.pop(context);
                    SnackBarHelper.showSuccess(context, 'Ev eklendi');
                  }
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditBuildingDialog(Map<String, dynamic> building) async {
    final nameController = TextEditingController(text: building['name']);
    final addressController = TextEditingController(text: building['address']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ev Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Ev Adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Adres',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              final db = await _db.database;
              await db.update(
                'Buildings',
                {
                  'name': nameController.text,
                  'address': addressController.text,
                },
                where: 'building_id = ?',
                whereArgs: [building['building_id']],
              );
              await _loadUsers();
              if (context.mounted) {
                Navigator.pop(context);
                SnackBarHelper.showSuccess(context, 'Ev güncellendi');
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBuilding(int buildingId) async {
    final confirmed = await _showConfirmDialog(
      'Evi Sil',
      'Bu evi silmek istediğinizden emin misiniz? Tüm enerji kayıtları da silinecek.',
    );

    if (confirmed == true) {
      final db = await _db.database;
      await db.delete('Energy_Readings',
          where: 'building_id = ?', whereArgs: [buildingId]);
      await db.delete('Buildings',
          where: 'building_id = ?', whereArgs: [buildingId]);
      await _loadStats();
      if (mounted) {
        SnackBarHelper.showSuccess(context, 'Ev silindi');
      }
    }
  }

  Future<void> _showAddUserDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kullanıcı Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty) {
                final db = await _db.database;
                await db.insert('Users', {
                  'name': nameController.text,
                  'email': emailController.text,
                });
                await _loadUsers();
                if (context.mounted) {
                  Navigator.pop(context);
                  SnackBarHelper.showSuccess(context, 'Kullanıcı eklendi');
                }
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditUserDialog(Map<String, dynamic> user) async {
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcı Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              final db = await _db.database;
              await db.update(
                'Users',
                {
                  'name': nameController.text,
                  'email': emailController.text,
                },
                where: 'user_id = ?',
                whereArgs: [user['user_id']],
              );
              await _loadUsers();
              if (context.mounted) {
                Navigator.pop(context);
                SnackBarHelper.showSuccess(context, 'Kullanıcı güncellendi');
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(int userId) async {
    final confirmed = await _showConfirmDialog(
      'Kullanıcıyı Sil',
      'Bu kullanıcıyı silmek istediğinizden emin misiniz? Tüm evleri ve enerji kayıtları da silinecek.',
    );

    if (confirmed == true) {
      final db = await _db.database;
      // Kullanıcının evlerini bul
      final buildings = await db
          .query('Buildings', where: 'user_id = ?', whereArgs: [userId]);

      // Her evin enerji kayıtlarını sil
      for (var building in buildings) {
        await db.delete('Energy_Readings',
            where: 'building_id = ?', whereArgs: [building['building_id']]);
      }

      // Evleri sil
      await db.delete('Buildings', where: 'user_id = ?', whereArgs: [userId]);

      // Kullanıcıyı sil
      await db.delete('Users', where: 'user_id = ?', whereArgs: [userId]);

      await _loadStats();
      if (mounted) {
        SnackBarHelper.showSuccess(context, 'Kullanıcı silindi');
      }
    }
  }

  Widget _buildDataManagementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İstatistikler
          _buildStatsCard(),
          const SizedBox(height: 24),

          // Durum mesajı
          if (_statusMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusMessage.contains('✅')
                    ? Colors.green[50]
                    : _statusMessage.contains('❌')
                        ? Colors.red[50]
                        : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _statusMessage.contains('✅')
                      ? Colors.green[200]!
                      : _statusMessage.contains('❌')
                          ? Colors.red[200]!
                          : Colors.blue[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _statusMessage.contains('✅')
                        ? Icons.check_circle
                        : _statusMessage.contains('❌')
                            ? Icons.error
                            : Icons.info,
                    color: _statusMessage.contains('✅')
                        ? Colors.green
                        : _statusMessage.contains('❌')
                            ? Colors.red
                            : Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (_statusMessage.isNotEmpty) const SizedBox(height: 24),

          // İşlemler
          Text(
            'Veri İşlemleri',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          _buildActionCard(
            title: 'Gerçekçi Veri Ekle',
            description: '7 günlük saatlik enerji tüketim verisi oluştur',
            icon: Icons.add_chart,
            color: Colors.blue,
            onTap: _seedRealisticData,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 12),

          _buildActionCard(
            title: 'Akıllı Öneriler Oluştur',
            description: 'Mevcut verilere göre tasarruf önerileri üret',
            icon: Icons.lightbulb,
            color: Colors.orange,
            onTap: _generateRecommendations,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 12),

          _buildActionCard(
            title: 'Tüm Verileri Sil',
            description: 'Veritabanındaki tüm kayıtları temizle',
            icon: Icons.delete_forever,
            color: Colors.red,
            onTap: _clearAllData,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 24),

          // Bilgi kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.purple[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Bilgi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Bu ekran test ve geliştirme amaçlıdır. '
                  'Gerçek uygulamada bu özellikler kullanıcıya gösterilmez.',
                  style: TextStyle(
                    color: Colors.purple[800],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Veritabanı İstatistikleri',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Enerji Kayıtları',
                  _totalReadings.toString(),
                  Icons.analytics,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Cihazlar',
                  _totalDevices.toString(),
                  Icons.devices,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Öneriler',
                  _totalRecommendations.toString(),
                  Icons.tips_and_updates,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
