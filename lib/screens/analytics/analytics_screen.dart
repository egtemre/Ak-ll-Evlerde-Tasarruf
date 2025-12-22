import 'package:flutter/material.dart';
import '../../services/energy_analytics_service.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/empty_state.dart';
import '../../utils/snackbar_helper.dart';

/// Detaylı analiz ekranı
/// İstatistikler, trendler, anomaliler ve öneriler
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final EnergyAnalyticsService _analyticsService = EnergyAnalyticsService();

  bool _isLoading = true;
  Map<String, dynamic>? _dailyComparison;
  Map<String, dynamic>? _weeklyTrend;
  List<Map<String, dynamic>>? _anomalies;
  Map<String, dynamic>? _savingsPotential;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final dailyComp = await _analyticsService.getDailyComparison();
      final weeklyTr = await _analyticsService.getWeeklyTrend();
      final anom = await _analyticsService.detectAnomalies();
      final savings = await _analyticsService.calculateSavingsPotential();

      setState(() {
        _dailyComparison = dailyComp;
        _weeklyTrend = weeklyTr;
        _anomalies = anom;
        _savingsPotential = savings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SnackBarHelper.showError(
          context,
          'Analiz yüklenirken hata oluştu',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Detaylı Analiz',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadAnalytics,
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_dailyComparison == null && _weeklyTrend == null)
                      ? EmptyState(
                          icon: Icons.analytics_outlined,
                          title: 'Henüz analiz verisi yok',
                          message:
                              'Detaylı analizler için en az 7 günlük veri gereklidir. Lütfen veri ekleyin.',
                          actionText: 'Verileri Yenile',
                          onAction: _loadAnalytics,
                        )
                      : RefreshIndicator(
                          onRefresh: _loadAnalytics,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Günlük karşılaştırma
                                _buildDailyComparisonCard(),
                                const SizedBox(height: 16),

                                // Haftalık trend
                                _buildWeeklyTrendCard(),
                                const SizedBox(height: 16),

                                // Tasarruf potansiyeli
                                _buildSavingsPotentialCard(),
                                const SizedBox(height: 16),

                                // Anomaliler
                                if (_anomalies != null &&
                                    _anomalies!.isNotEmpty)
                                  _buildAnomaliesCard(),

                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }

  Widget _buildDailyComparisonCard() {
    if (_dailyComparison == null) return const SizedBox();

    final change = _dailyComparison!['changePercent'] as double;
    final isIncrease = _dailyComparison!['isIncrease'] as bool;
    final today = _dailyComparison!['today'] as double;
    final yesterday = _dailyComparison!['yesterday'] as double;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIncrease ? Icons.trending_up : Icons.trending_down,
                color: isIncrease ? Colors.red : Colors.green,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Günlük Karşılaştırma',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      _dailyComparison!['message'] as String? ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  'Bugün',
                  '${today.toStringAsFixed(1)} kWh',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  'Dün',
                  '${yesterday.toStringAsFixed(1)} kWh',
                  Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  'Değişim',
                  '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                  isIncrease ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrendCard() {
    if (_weeklyTrend == null) return const SizedBox();

    final trend = _weeklyTrend!['trend'] as String? ?? 'stable';
    final message = _weeklyTrend!['message'] as String? ?? '';

    IconData trendIcon;
    Color trendColor;

    switch (trend) {
      case 'increasing':
        trendIcon = Icons.arrow_upward;
        trendColor = Colors.red;
        break;
      case 'decreasing':
        trendIcon = Icons.arrow_downward;
        trendColor = Colors.green;
        break;
      default:
        trendIcon = Icons.remove;
        trendColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [trendColor.withOpacity(0.1), trendColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: trendColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: trendColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(trendIcon, color: trendColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Haftalık Trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsPotentialCard() {
    if (_savingsPotential == null) return const SizedBox();

    final potential = _savingsPotential!['potential'] as double? ?? 0.0;
    final percentage = _savingsPotential!['percentage'] as double? ?? 0.0;
    final costSavings = _savingsPotential!['costSavings'] as String? ?? '0 TL';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.savings, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text(
                'Tasarruf Potansiyeli',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${potential.toStringAsFixed(1)} kWh/hafta',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '≈ ₺$costSavings/ay tasarruf edebilirsiniz',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '%${percentage.toStringAsFixed(0)} optimizasyon',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnomaliesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange[700], size: 24),
              const SizedBox(width: 12),
              Text(
                'Anormal Tüketimler',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Son 7 günde ${_anomalies!.length} anormal tüketim tespit edildi.',
            style: TextStyle(
              color: Colors.orange[800],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ..._anomalies!.take(3).map((anomaly) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.fiber_manual_record,
                        size: 12, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        anomaly['message'] as String? ?? '',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
