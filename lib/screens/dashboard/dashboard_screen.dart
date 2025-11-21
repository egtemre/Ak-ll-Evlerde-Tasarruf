import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_navigation.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Ekran açıldığında model meta bilgilerini ve tahmin yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.loadModelMeta();
      appState.predictCurrentEnergy();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.menu),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Enerji Panosu',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // Balance the menu icon
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık
                        Text(
                          'Enerji Tüketimi Paneli',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 24),

                        // Zaman filtresi
                        _buildTimeFilter(),
                        const SizedBox(height: 24),

                        // Uyarı kartı
                        _buildWarningCard(),
                        const SizedBox(height: 24),

                        // ML Tahmin kartı
                        _buildMLPredictionCard(context, appState),
                        const SizedBox(height: 24),

                        // Ana tüketim kartı ve grafik
                        _buildConsumptionCard(context, appState),
                        const SizedBox(height: 24),

                        // Alt kartlar
                        Row(
                          children: [
                            Expanded(
                              child: _buildSavingCard(appState),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTargetCard(appState),
                            ),
                          ],
                        ),
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
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              appState.predictCurrentEnergy();
            },
            backgroundColor: AppTheme.primaryColor,
            child: appState.isLoadingPrediction
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.psychology, color: Colors.white),
            tooltip: 'ML Tahmin Yap',
          ),
        );
      },
    );
  }

  Widget _buildTimeFilter() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildFilterButton(
                  context,
                  'Günlük',
                  appState.selectedTimeFilter == 'Günlük',
                  () => appState.setTimeFilter('Günlük'),
                ),
              ),
              Expanded(
                child: _buildFilterButton(
                  context,
                  'Haftalık',
                  appState.selectedTimeFilter == 'Haftalık',
                  () => appState.setTimeFilter('Haftalık'),
                ),
              ),
              Expanded(
                child: _buildFilterButton(
                  context,
                  'Aylık',
                  appState.selectedTimeFilter == 'Aylık',
                  () => appState.setTimeFilter('Aylık'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMLPredictionCard(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ML Tahmin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (appState.modelMeta != null)
                      Text(
                        'Model: ${appState.modelMeta!.modelType}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (appState.isLoadingPrediction)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => appState.predictCurrentEnergy(),
                  tooltip: 'Yenile',
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (appState.predictionError != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appState.predictionError!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (appState.currentPrediction != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tahmin Edilen Tüketim',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${appState.currentPrediction!.prediction.toStringAsFixed(2)} kWh',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                        ),
                      ],
                    ),
                    if (appState.currentPrediction!.proba != null &&
                        appState.currentPrediction!.proba!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Güven',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${(appState.currentPrediction!.proba!.reduce((a, b) => a > b ? a : b) * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Mevcut tüketim ile karşılaştırma
                _buildComparisonWidget(
                  context,
                  appState.totalConsumption,
                  appState.currentPrediction!.prediction,
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tahmin yapmak için yenile butonuna basın',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComparisonWidget(
    BuildContext context,
    double current,
    double predicted,
  ) {
    final difference = predicted - current;
    final differencePercent = current > 0 ? (difference / current * 100) : 0;
    final isPositive = difference > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPositive
            ? Colors.orange[50]
            : AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPositive
              ? Colors.orange[200]!
              : AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? Colors.orange[700] : AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPositive
                      ? 'Tahmin edilen tüketim mevcut değerden yüksek'
                      : 'Tahmin edilen tüketim mevcut değerden düşük',
                  style: TextStyle(
                    color: isPositive ? Colors.orange[700] : AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fark: ${difference.abs().toStringAsFixed(2)} kWh (${differencePercent.abs().toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: isPositive ? Colors.orange[700] : AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Filtreye göre farklı uyarı mesajları
        String warningMessage;
        String warningDetail;
        
        switch (appState.selectedTimeFilter) {
          case 'Haftalık':
            warningMessage = 'Geçen haftaya göre %12 daha fazla kullandınız.';
            warningDetail = 'Olası neden: Hafta sonu tüketimi artışı.';
            break;
          case 'Aylık':
            warningMessage = 'Geçen aya göre %8 daha fazla kullandınız.';
            warningDetail = 'Olası neden: Mevsimsel değişiklikler.';
            break;
          default:
            warningMessage = 'Düne göre %15 daha fazla kullandınız.';
            warningDetail = 'Olası neden: Klima normalden daha uzun süre çalıştı.';
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                warningMessage,
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                warningDetail,
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConsumptionCard(BuildContext context, AppState appState) {
    final energyData = appState.energyData;
    
    // Boş liste kontrolü
    if (energyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('Veri bulunamadı'),
        ),
      );
    }
    
    final maxValue = energyData
            .map((e) => e.consumption)
            .reduce((a, b) => a > b ? a : b) * 1.2;
    
    // En yüksek değerin indeksini hesapla (bir kez)
    final maxIndex = energyData
        .asMap()
        .entries
        .reduce((a, b) => a.value.consumption > b.value.consumption ? a : b)
        .key;
    
    // Filtreye göre başlık ve alt metin
    String timeLabel;
    switch (appState.selectedTimeFilter) {
      case 'Haftalık':
        timeLabel = 'Bu Hafta';
        break;
      case 'Aylık':
        timeLabel = 'Bu Ay';
        break;
      default:
        timeLabel = 'Bugün';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Toplam Tüketim',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${appState.totalConsumption.toStringAsFixed(1)} kWh',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            timeLabel,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Grafik - Filtreye göre dinamik
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < energyData.length) {
                          // Günlük için ortadaki (09:00) vurgulanır
                          // Haftalık ve Aylık için en yüksek değer vurgulanır
                          final isHighlighted = appState.selectedTimeFilter == 'Günlük'
                              ? index == 3
                              : index == maxIndex;

                          return Text(
                            energyData[index].hour,
                            style: TextStyle(
                              color: isHighlighted
                                  ? AppTheme.primaryColor
                                  : Colors.grey[500],
                              fontSize: appState.selectedTimeFilter == 'Aylık' ? 10 : 12,
                              fontWeight: isHighlighted
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: energyData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final isHighlighted = appState.selectedTimeFilter == 'Günlük'
                      ? index == 3
                      : index == maxIndex;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data.consumption,
                        color: isHighlighted
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withValues(alpha: 0.3),
                        width: appState.selectedTimeFilter == 'Aylık' ? 30 : 24,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tahmini Aylık Tasarruf',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₺${appState.estimatedMonthlySaving.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Akıllı cihazlarınız sayesinde',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCard(AppState appState) {
    final progress = appState.currentMonthlySaving / appState.monthlyTarget;
    final remainingPercent = ((1 - progress) * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aylık Tasarruf Hedefi',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '150 kWh / ₺${appState.monthlyTarget.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            minHeight: 8,
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${appState.currentMonthlySaving} kWh',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              Text(
                'Hedefe %$remainingPercent kaldı',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
