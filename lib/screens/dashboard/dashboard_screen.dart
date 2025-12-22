import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/animations.dart';
import '../prediction/prediction_detail_screen.dart';
import '../time_slot_detail_screen.dart';

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

  Future<void> _refreshData() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await Future.wait([
      appState.loadModelMeta(),
      appState.predictCurrentEnergy(),
    ]);
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
                  child: Center(
                    child: Text(
                      loc.energyDashboard,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    color: AppTheme.primaryColor,
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
                          AnimatedCard(
                            delay: const Duration(milliseconds: 100),
                            child: _buildTimeFilter(),
                          ),
                          const SizedBox(height: 24),

                          // ML Tahmin kartı
                          AnimatedCard(
                            delay: const Duration(milliseconds: 200),
                            child: _buildMLPredictionCard(context, appState),
                          ),
                          const SizedBox(height: 24),

                          // Gelecek Tahmin Grafiği
                          AnimatedCard(
                            delay: const Duration(milliseconds: 300),
                            child:
                                _buildFuturePredictionChart(context, appState),
                          ),
                          const SizedBox(height: 24),

                          // Ana tüketim kartı ve grafik
                          AnimatedCard(
                            delay: const Duration(milliseconds: 400),
                            child: _buildConsumptionCard(context, appState),
                          ),
                          const SizedBox(height: 24),

                          // Alt kartlar
                          AnimatedCard(
                            delay: const Duration(milliseconds: 500),
                            child: Row(
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
                          ),
                          const SizedBox(
                              height: 100), // Bottom navigation için boşluk
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const CustomBottomNavigation(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Seçili filtreye göre tahmin yap
              if (appState.selectedTimeFilter == 'Günlük') {
                appState.predictCurrentEnergy();
              } else {
                // Haftalık veya Aylık için filtreyi yeniden ayarla (otomatik tahmin yapacak)
                appState.setTimeFilter(appState.selectedTimeFilter);
              }
            },
            tooltip: loc.mlPredictionMake,
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
          ),
        );
      },
    );
  }

  Widget _buildTimeFilter() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final loc = appState.loc;
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
                  loc.daily,
                  appState.selectedTimeFilter == 'Günlük',
                  () => appState.setTimeFilter('Günlük'),
                ),
              ),
              Expanded(
                child: _buildFilterButton(
                  context,
                  loc.weekly,
                  appState.selectedTimeFilter == 'Haftalık',
                  () => appState.setTimeFilter('Haftalık'),
                ),
              ),
              Expanded(
                child: _buildFilterButton(
                  context,
                  loc.monthly,
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
    final loc = appState.loc;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PredictionDetailScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 2,
          ),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
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
                      Row(
                        children: [
                          Text(
                            loc.mlPrediction,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: loc.aiModelPrediction,
                            child: Icon(
                              Icons.help_outline,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (appState.modelMeta != null)
                        Text(
                          '${loc.modelLabel}: ${appState.modelMeta!.modelType}',
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
                    onPressed: () {
                      // Seçili filtreye göre tahmin yap
                      if (appState.selectedTimeFilter == 'Günlük') {
                        appState.predictCurrentEnergy();
                      } else {
                        // Haftalık veya Aylık için filtreyi yeniden ayarla
                        appState.setTimeFilter(appState.selectedTimeFilter);
                      }
                    },
                    tooltip: 'Yenile',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (appState.predictionError != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange[700], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tahmin Şu An Yapılamıyor',
                            style: TextStyle(
                              color: Colors.orange[900],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ML modelimiz geçici olarak kullanılamıyor. Geçmiş verilerinizi görebilir ve cihazlarınızı yönetebilirsiniz.',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: Colors.orange[700], size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'İpucu: Yenile butonuna basarak tekrar deneyin',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
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
                            '${appState.currentFilterPrediction?.toStringAsFixed(2) ?? '0.00'} kWh',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
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
                            color: AppTheme.primaryColor.withOpacity(0.1),
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
                  if (appState.currentFilterPrediction != null)
                    _buildComparisonWidget(
                      context,
                      appState.currentFilterPrediction!,
                      appState.totalConsumption,
                    ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.05),
                      AppTheme.primaryColor.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.psychology_outlined,
                      color: AppTheme.primaryColor,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tahmin Yapmaya Hazır',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yapay zeka modelimiz verilerinizi analiz etmeye hazır. Başlamak için yenile butonuna dokunun.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (appState.selectedTimeFilter == 'Günlük') {
                          appState.predictCurrentEnergy();
                        } else {
                          appState.setTimeFilter(appState.selectedTimeFilter);
                        }
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Tahmin Yap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonWidget(
    BuildContext context,
    double predicted,
    double current,
  ) {
    // Fark ve yüzde hesaplama
    final difference = predicted - current;
    final differencePercent = current > 0 ? ((difference / current) * 100) : 0;

    // Fark çok küçükse (0.001'den az) gösterme
    if (difference.abs() < 0.001) {
      return const SizedBox.shrink();
    }

    String message;
    Color color;
    IconData icon;

    if (difference > 0) {
      // Tahmin > Mevcut (daha fazla tüketim bekleniyor)
      message = 'Model daha yüksek tüketim öngörüyor';
      color = Colors.orange[700]!;
      icon = Icons.arrow_upward;
    } else {
      // Tahmin < Mevcut (daha az tüketim bekleniyor)
      message = 'Model daha düşük tüketim öngörüyor';
      color = Colors.green[700]!;
      icon = Icons.arrow_downward;
    }

    // Renk seçimi
    Color backgroundColor;
    Color borderColor;

    if (difference > 0) {
      backgroundColor = Colors.orange[50]!;
      borderColor = Colors.orange[200]!;
    } else {
      backgroundColor = Colors.green[50]!;
      borderColor = Colors.green[200]!;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Tahmin: ',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: '${predicted.toStringAsFixed(2)} kWh',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' | '),
                      const TextSpan(
                        text: 'Mevcut: ',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: '${current.toStringAsFixed(2)} kWh',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fark: ${difference.abs().toStringAsFixed(2)} kWh (${difference > 0 ? '+' : '-'}${differencePercent.abs().toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionCard(BuildContext context, AppState appState) {
    final loc = appState.loc;
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

    final maxValue =
        energyData.map((e) => e.consumption).reduce((a, b) => a > b ? a : b) *
            1.2;

    // En yüksek ve en düşük değerleri bul
    final maxConsumption =
        energyData.map((e) => e.consumption).reduce((a, b) => a > b ? a : b);
    final minConsumption =
        energyData.map((e) => e.consumption).reduce((a, b) => a < b ? a : b);

    // En yüksek değerin indeksini hesapla (bir kez)
    final maxIndex = energyData
        .asMap()
        .entries
        .reduce((a, b) => a.value.consumption > b.value.consumption ? a : b)
        .key;

    // Filtreye göre başlık ve alt metin
    String timeLabel;
    String timeDescription;
    double savingsTarget;

    // Gerçek veriye göre dinamik hedef hesaplama
    final currentConsumption = appState.totalConsumption;

    switch (appState.selectedTimeFilter) {
      case 'Haftalık':
        timeLabel = loc.thisWeek;
        timeDescription = loc.total7Day;
        // Hedef: Mevcut tüketimin %85'i (yani %15 tasarruf hedefi)
        savingsTarget =
            currentConsumption > 0 ? currentConsumption * 0.85 : 150.0;
        break;
      case 'Aylık':
        timeLabel = loc.thisMonth;
        timeDescription = loc.total30Day;
        // Hedef: Mevcut tüketimin %85'i (yani %15 tasarruf hedefi)
        savingsTarget =
            currentConsumption > 0 ? currentConsumption * 0.85 : 600.0;
        break;
      default:
        timeLabel = loc.today;
        timeDescription = loc.total24Hour;
        // Hedef: Mevcut tüketimin %85'i (yani %15 tasarruf hedefi)
        savingsTarget =
            currentConsumption > 0 ? currentConsumption * 0.85 : 20.0;
    }

    // Tasarruf hesaplamaları
    final targetDifference = currentConsumption - savingsTarget;
    final isOverTarget = targetDifference > 0;
    final percentageOfTarget = savingsTarget > 0
        ? (currentConsumption / savingsTarget * 100).clamp(0, 150)
        : 0.0;

    // Tahmini maliyet (kWh başına 2.5 TL)
    final estimatedCost = currentConsumption * 2.5;
    final potentialSavings = isOverTarget ? (targetDifference * 2.5) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Toplam Tüketim',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: timeDescription,
                          child: Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${currentConsumption.toStringAsFixed(1)} kWh',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isOverTarget
                                    ? Colors.orange[700]
                                    : AppTheme.primaryColor,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          timeLabel,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          ' • ₺${estimatedCost.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Durum ikonu
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOverTarget
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isOverTarget ? Icons.trending_up : Icons.check_circle,
                  color: isOverTarget ? Colors.orange : Colors.green,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tasarruf hedefi göstergesi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isOverTarget ? Colors.orange[50] : Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOverTarget ? Colors.orange[200]! : Colors.green[200]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.flag,
                          size: 18,
                          color: isOverTarget
                              ? Colors.orange[700]
                              : Colors.green[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tasarruf Hedefi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isOverTarget
                                ? Colors.orange[900]
                                : Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${savingsTarget.toStringAsFixed(0)} kWh',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isOverTarget
                            ? Colors.orange[700]
                            : Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // İlerleme çubuğu
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (percentageOfTarget / 100).clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    color: isOverTarget ? Colors.orange : Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isOverTarget
                          ? 'Hedefin ${targetDifference.toStringAsFixed(1)} kWh üzerinde'
                          : 'Hedef içinde! ${targetDifference.abs().toStringAsFixed(1)} kWh tasarruf',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverTarget
                            ? Colors.orange[800]
                            : Colors.green[800],
                      ),
                    ),
                    Text(
                      '%${percentageOfTarget.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isOverTarget
                            ? Colors.orange[800]
                            : Colors.green[800],
                      ),
                    ),
                  ],
                ),
                if (isOverTarget && potentialSavings > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.savings,
                          size: 16,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hedefe ulaşarak ₺${potentialSavings.toStringAsFixed(2)} tasarruf edebilirsiniz',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Grafik başlığı ve açıklama
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tüketim Grafiği',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Tooltip(
                message: 'En yüksek tüketim dönemi vurgulanmıştır',
                child: Icon(
                  Icons.bar_chart,
                  size: 16,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Grafik - Filtreye göre dinamik
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final data = energyData[groupIndex];
                      final cost = data.consumption * 2.5;
                      return BarTooltipItem(
                        '${data.hour}\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text:
                                '${data.consumption.toStringAsFixed(1)} kWh\n',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: '₺${cost.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < energyData.length) {
                          final isHighlighted =
                              appState.selectedTimeFilter == 'Günlük'
                                  ? index == 3
                                  : index == maxIndex;

                          return Text(
                            energyData[index].hour,
                            style: TextStyle(
                              color: isHighlighted
                                  ? AppTheme.primaryColor
                                  : Colors.grey[500],
                              fontSize: appState.selectedTimeFilter == 'Aylık'
                                  ? 10
                                  : 12,
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

                  // Sadece en düşük ve en yüksek değerleri renklendir, diğerleri açık mavi
                  Color barColor;
                  if (data.consumption == minConsumption) {
                    // En düşük tüketim: Yeşil
                    barColor = Colors.green;
                  } else if (data.consumption == maxConsumption) {
                    // En yüksek tüketim: Turuncu
                    barColor = Colors.orange;
                  } else {
                    // Diğerleri: Açık mavi
                    barColor = Colors.lightBlue[300]!;
                  }

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data.consumption,
                        color: barColor,
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
    // Filtreye göre tasarruf hesaplama
    String periodLabel;
    double estimatedSaving;

    switch (appState.selectedTimeFilter) {
      case 'Haftalık':
        periodLabel = 'Haftalık';
        estimatedSaving = appState.estimatedMonthlySaving / 4; // Aylığın 1/4'ü
        break;
      case 'Aylık':
        periodLabel = 'Aylık';
        estimatedSaving = appState.estimatedMonthlySaving;
        break;
      default: // Günlük
        periodLabel = 'Günlük';
        estimatedSaving =
            appState.estimatedMonthlySaving / 30; // Aylığın 1/30'u
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'Tahmini $periodLabel Tasarruf',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₺${estimatedSaving.toStringAsFixed(2)}',
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
    // Filtreye göre hedef hesaplama - gerçek veriye göre
    String periodLabel;
    double targetAmount;
    double currentSaving;
    double targetKwh;

    final currentConsumption = appState.totalConsumption;
    const savingPercentage = 0.15; // %15 tasarruf hedefi
    const electricityPrice = 2.5; // TL/kWh

    switch (appState.selectedTimeFilter) {
      case 'Haftalık':
        periodLabel = 'Haftalık';
        // Mevcut tüketimin %15'i tasarruf hedefi
        targetKwh = currentConsumption * savingPercentage;
        targetAmount = targetKwh * electricityPrice;
        currentSaving = appState.currentMonthlySaving / 4;
        break;
      case 'Aylık':
        periodLabel = 'Aylık';
        // Mevcut tüketimin %15'i tasarruf hedefi
        targetKwh = currentConsumption * savingPercentage;
        targetAmount = targetKwh * electricityPrice;
        currentSaving = appState.currentMonthlySaving;
        break;
      default: // Günlük
        periodLabel = 'Günlük';
        // Mevcut tüketimin %15'i tasarruf hedefi
        targetKwh = currentConsumption * savingPercentage;
        targetAmount = targetKwh * electricityPrice;
        currentSaving = appState.currentMonthlySaving / 30;
    }

    final progress = targetAmount > 0 ? (currentSaving / targetAmount) : 0.0;
    final remainingPercent = ((1 - progress) * 100).clamp(0, 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$periodLabel Tasarruf Hedefi',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${targetKwh.toStringAsFixed(0)} kWh / ₺${targetAmount.toStringAsFixed(0)}',
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
            value: progress.clamp(0.0, 1.0),
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
                '${currentSaving.toStringAsFixed(1)} kWh',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              Text(
                remainingPercent > 0
                    ? 'Hedefe %$remainingPercent kaldı'
                    : 'Hedef aşıldı! 🎉',
                style: TextStyle(
                  color: remainingPercent > 0
                      ? Colors.grey[500]
                      : AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: remainingPercent > 0
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFuturePredictionChart(BuildContext context, AppState appState) {
    final loc = appState.loc;
    // Filtre durumuna göre başlık ve veri sayısı
    String chartTitle;
    String tooltipMessage;
    int hoursToPredict;

    switch (appState.selectedTimeFilter) {
      case 'Haftalık':
        chartTitle = loc.next7Days;
        tooltipMessage = loc.next7DaysDesc;
        hoursToPredict = 168; // 7 gün * 24 saat
        break;
      case 'Aylık':
        chartTitle = loc.next4Weeks;
        tooltipMessage = loc.next4WeeksDesc;
        hoursToPredict = 672; // 4 hafta * 7 gün * 24 saat
        break;
      default:
        chartTitle = loc.next24Hours;
        tooltipMessage = loc.next24HoursDesc;
        hoursToPredict = 24;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.timeline,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      chartTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Tooltip(
                  message: tooltipMessage,
                  child: Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<double>?>(
              future: appState.predictFutureHours(hoursToPredict),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.access_time,
                            color: Colors.blue[700], size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Gelecek Tahminler Hazırlanıyor',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.analyzingPattern,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final predictions = snapshot.data!;

                // Filtreye göre veriyi grupla (saatlik / günlük / haftalık)
                List<double> displayData;
                int barCount;

                if (appState.selectedTimeFilter == 'Haftalık') {
                  // 7 günlük toplam (her gün 24 saat)
                  displayData = [];
                  for (int day = 0;
                      day < 7 && day * 24 < predictions.length;
                      day++) {
                    double dailySum = 0;
                    for (int hour = 0;
                        hour < 24 && (day * 24 + hour) < predictions.length;
                        hour++) {
                      dailySum += predictions[day * 24 + hour];
                    }
                    displayData.add(dailySum);
                  }
                  barCount = 7;
                } else if (appState.selectedTimeFilter == 'Aylık') {
                  // 4 haftalık toplam (her hafta 7 gün = 168 saat)
                  displayData = [];
                  for (int week = 0;
                      week < 4 && week * 168 < predictions.length;
                      week++) {
                    double weeklySum = 0;
                    for (int hour = 0;
                        hour < 168 && (week * 168 + hour) < predictions.length;
                        hour++) {
                      weeklySum += predictions[week * 168 + hour];
                    }
                    displayData.add(weeklySum);
                  }
                  barCount = 4;
                } else {
                  // Günlük - 3 saatlik dilimler (8 dilim)
                  displayData = [];
                  for (int slot = 0;
                      slot < 8 && slot * 3 < predictions.length;
                      slot++) {
                    double slotSum = 0;
                    for (int hour = 0;
                        hour < 3 && (slot * 3 + hour) < predictions.length;
                        hour++) {
                      slotSum += predictions[slot * 3 + hour];
                    }
                    displayData.add(slotSum);
                  }
                  barCount = 8;
                }

                final totalPredicted = displayData.reduce((a, b) => a + b);
                final avgPredicted = totalPredicted / displayData.length;
                final maxPredicted =
                    displayData.reduce((a, b) => a > b ? a : b);
                final minPredicted =
                    displayData.reduce((a, b) => a < b ? a : b);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Özet bilgiler
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPredictionStat(
                            'Toplam',
                            '${totalPredicted.toStringAsFixed(1)} kWh',
                            Icons.electric_bolt,
                          ),
                          Container(
                              width: 1, height: 40, color: Colors.grey[300]),
                          _buildPredictionStat(
                            'Ortalama',
                            '${avgPredicted.toStringAsFixed(2)} kWh',
                            Icons.analytics,
                          ),
                          Container(
                              width: 1, height: 40, color: Colors.grey[300]),
                          _buildPredictionStat(
                            'Tepe',
                            '${maxPredicted.toStringAsFixed(2)} kWh',
                            Icons.trending_up,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Basit grafik gösterimi
                    SizedBox(
                      height: 220,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(barCount, (index) {
                          if (index >= displayData.length) {
                            return const Expanded(child: SizedBox());
                          }

                          final value = displayData[index];
                          final normalizedHeight = (value / maxPredicted) * 180;

                          // Double karşılaştırma için tolerance kullan
                          const tolerance = 0.01;
                          final isMax =
                              (value - maxPredicted).abs() < tolerance;
                          final isMin =
                              (value - minPredicted).abs() < tolerance;

                          Color barColor;
                          if (isMax) {
                            barColor = Colors.orange;
                          } else if (isMin) {
                            barColor = Colors.green;
                          } else {
                            barColor = Colors.lightBlue[300]!;
                          }

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (appState.selectedTimeFilter == 'Günlük') {
                                  // Günlük: 3 saatlik dilimler (index zaten dilim numarası)
                                  final startHour = index * 3;
                                  final endHour = startHour + 3;

                                  // O dilimin toplam enerjisi
                                  double totalEnergy = displayData[index];

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TimeSlotDetailScreen(
                                        startHour: startHour,
                                        endHour: endHour,
                                        totalEnergy: totalEnergy,
                                        predictions: predictions,
                                      ),
                                    ),
                                  );
                                } else if (appState.selectedTimeFilter ==
                                    'Haftalık') {
                                  // Haftalık: O günün detaylarını göster
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Gün ${index + 1} Detayı'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Toplam Tüketim: ${displayData[index].toStringAsFixed(2)} kWh'),
                                          const SizedBox(height: 8),
                                          Text(
                                              'Saatlik Ortalama: ${(displayData[index] / 24).toStringAsFixed(2)} kWh/saat'),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Tamam'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (appState.selectedTimeFilter ==
                                    'Aylık') {
                                  // Aylık: O haftanın detaylarını göster
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Hafta ${index + 1} Detayı'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Toplam Tüketim: ${displayData[index].toStringAsFixed(2)} kWh'),
                                          const SizedBox(height: 8),
                                          Text(
                                              'Günlük ortalama: ${(displayData[index] / 7).toStringAsFixed(2)} kWh/gün'),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Tamam'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Değer göstergesi
                                    if (appState.selectedTimeFilter ==
                                            'Günlük' ||
                                        appState.selectedTimeFilter ==
                                            'Haftalık' ||
                                        appState.selectedTimeFilter == 'Aylık')
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          value.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 8,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    else
                                      const SizedBox(height: 16),
                                    // Bar
                                    Container(
                                      height:
                                          normalizedHeight.clamp(3.0, 180.0),
                                      decoration: BoxDecoration(
                                        color: barColor,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(3),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // X ekseni etiketi
                                    if (appState.selectedTimeFilter == 'Günlük')
                                      Text(
                                        '${index * 3}-${(index + 1) * 3}',
                                        style: const TextStyle(
                                          fontSize: 8,
                                          color: Colors.grey,
                                        ),
                                      )
                                    else if (appState.selectedTimeFilter ==
                                        'Haftalık')
                                      Text(
                                        'G${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 8,
                                          color: Colors.grey,
                                        ),
                                      )
                                    else if (appState.selectedTimeFilter ==
                                        'Aylık')
                                      Text(
                                        'H${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 8,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Renk açıklaması
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(Colors.green, 'En Düşük'),
                        const SizedBox(width: 16),
                        _buildLegendItem(Colors.lightBlue[300]!, 'Normal'),
                        const SizedBox(width: 16),
                        _buildLegendItem(Colors.orange, 'En Yüksek'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Bilgilendirme mesajı
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 16,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              appState.selectedTimeFilter == 'Günlük'
                                  ? 'Her çubuk 3 saatlik tüketim dilimini gösteriyor. Tıklayarak detayları görebilirsiniz'
                                  : appState.selectedTimeFilter == 'Haftalık'
                                      ? 'Önümüzdeki 7 günün günlük tüketim tahmini. Tıklayarak detayları görebilirsiniz'
                                      : 'Önümüzdeki 4 haftanın haftalık tüketim tahmini. Tıklayarak detayları görebilirsiniz',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
