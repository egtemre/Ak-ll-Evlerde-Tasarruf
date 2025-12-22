import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class PredictionDetailScreen extends StatelessWidget {
  const PredictionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Tahmin Detayları'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.currentPrediction == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tahmin verisi bulunamadı',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainPredictionCard(context, appState),
                const SizedBox(height: 16),
                _buildStatisticsCard(context, appState),
                const SizedBox(height: 16),
                _buildRecommendationsCard(context, appState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainPredictionCard(BuildContext context, AppState appState) {
    final predictionValue = appState.currentFilterPrediction ?? 0;
    final currentValue = appState.totalConsumption;
    final difference = predictionValue - currentValue;
    final isHigher = difference > 0;

    // Periyot için etiket
    String periodLabel;
    switch (appState.selectedTimeFilter) {
      case 'Haftalık':
        periodLabel = 'Haftalık';
        break;
      case 'Aylık':
        periodLabel = 'Aylık';
        break;
      default:
        periodLabel = 'Günlük';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity( 0.7)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              isHigher ? Icons.trending_up : Icons.trending_down,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              '$periodLabel Tahmin',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${predictionValue.toStringAsFixed(1)} kWh',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity( 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Mevcut',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currentValue.toStringAsFixed(1)} kWh',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white30,
                  ),
                  Column(
                    children: [
                      const Text(
                        'Fark',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${difference.abs().toStringAsFixed(2)} kWh',
                        style: TextStyle(
                          color:
                              isHigher ? Colors.orange[200] : Colors.green[200],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context, AppState appState) {
    final predictionValue = appState.currentFilterPrediction ?? 0;
    final currentValue = appState.totalConsumption;

    // Debug: Fark hesaplama kontrolü
    debugPrint(
        'DEBUG - Prediction: $predictionValue, Current: $currentValue, Diff: ${(predictionValue - currentValue).abs()}');

    // Periyoda göre istatistikler
    String avgLabel;
    double avgValue;
    String predictionDiffLabel;

    switch (appState.selectedTimeFilter) {
      case 'Haftalık':
        avgLabel = 'Günlük Ortalama';
        avgValue = predictionValue / 7;
        predictionDiffLabel = 'Haftalık Fark';
        break;
      case 'Aylık':
        avgLabel = 'Günlük Ortalama';
        avgValue = predictionValue / 30;
        predictionDiffLabel = 'Aylık Fark';
        break;
      default:
        avgLabel = '8 Saatlik Ortalama';
        avgValue = predictionValue / 3; // 24 saatin 1/3'ü
        predictionDiffLabel = 'Günlük Fark';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.analytics, color: Colors.blue[700]),
                ),
                const SizedBox(width: 12),
                const Text(
                  'İstatistikler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatItem(
              avgLabel,
              '${avgValue.toStringAsFixed(2)} kWh',
              Icons.timeline,
            ),
            const Divider(height: 24),
            _buildStatItem(
              'Model Versiyonu',
              appState.modelMeta?.version ?? '1.0.0',
              Icons.verified,
            ),
            const Divider(height: 24),
            _buildStatItem(
              predictionDiffLabel,
              '${(predictionValue - currentValue).abs().toStringAsFixed(2)} kWh',
              Icons.compare_arrows,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsCard(BuildContext context, AppState appState) {
    final predictionValue = appState.currentFilterPrediction ?? 0;
    final currentValue = appState.totalConsumption;
    final difference = predictionValue - currentValue;
    final isHigher = difference > 0;
    final isLower = difference < 0;

    // Periyot için mesajlar
    String periodText;
    switch (appState.selectedTimeFilter) {
      case 'Haftalık':
        periodText = 'bu hafta';
        break;
      case 'Aylık':
        periodText = 'bu ay';
        break;
      default:
        periodText = 'bugün';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.lightbulb, color: Colors.green[700]),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Akıllı Öneriler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isHigher)
              _buildRecommendationItem(
                'Tüketim Artışı Uyarısı',
                'Modelimiz $periodText için mevcut değerden %${(difference.abs() / currentValue * 100).toStringAsFixed(1)} daha yüksek tüketim öngörüyor. Gereksiz cihazları kapatmayı ve tasarruf önerilerimizi uygulamayı düşünün.',
                Icons.warning_amber,
                Colors.orange,
              )
            else if (isLower)
              _buildRecommendationItem(
                'Tasarruf Başarısı',
                'Tebrikler! Modelimiz $periodText için daha düşük tüketim öngörüyor. Tasarruf çabalarınız sonuç veriyor, böyle devam edin!',
                Icons.check_circle,
                Colors.green,
              ),
            const Divider(height: 24),
            _buildRecommendationItem(
              'Tasarruf Fırsatları',
              'Tasarruf önerileri sayfasından ${appState.suggestions.length} kişiselleştirilmiş öneriyi inceleyin ve aylık faturanızı düşürün.',
              Icons.savings,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity( 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
