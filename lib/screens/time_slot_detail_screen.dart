import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

/// Belirli bir zaman dilimindeki cihaz tüketimlerini gösteren ekran
class TimeSlotDetailScreen extends StatefulWidget {
  final int startHour;
  final int endHour;
  final double totalEnergy;
  final List<double>? predictions;

  const TimeSlotDetailScreen({
    super.key,
    required this.startHour,
    required this.endHour,
    required this.totalEnergy,
    this.predictions,
  });

  @override
  State<TimeSlotDetailScreen> createState() => _TimeSlotDetailScreenState();
}

class _TimeSlotDetailScreenState extends State<TimeSlotDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '${widget.startHour.toString().padLeft(2, '0')}:00 - ${widget.endHour.toString().padLeft(2, '0')}:00 Detayları',
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Özet kart
                _buildSummaryCard(),
                const SizedBox(height: 20),

                // Cihaz listesi başlığı
                const Text(
                  'Bu Saatlerde Aktif Cihazlar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Cihaz tüketim kartları
                ..._buildDeviceCards(appState),

                const SizedBox(height: 20),

                // Öneriler kartı
                _buildRecommendationsCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard() {
    final hourRange = widget.endHour - widget.startHour;
    final avgPerHour = widget.totalEnergy / hourRange;

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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity( 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Zaman Dilimi',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.startHour.toString().padLeft(2, '0')}:00 - ${widget.endHour.toString().padLeft(2, '0')}:00',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white30, height: 1),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryStat(
                  'Toplam',
                  '${widget.totalEnergy.toStringAsFixed(2)} kWh',
                  Icons.electric_bolt,
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white30,
                ),
                _buildSummaryStat(
                  'Saatlik Ort.',
                  '${avgPerHour.toStringAsFixed(2)} kWh',
                  Icons.analytics,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity( 0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDeviceCards(AppState appState) {
    // Zaman dilimine göre simüle edilmiş cihaz verileri
    final devices = _getDevicesForTimeSlot();

    if (devices.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            children: [
              Icon(Icons.devices_other, color: Colors.blue[700], size: 48),
              const SizedBox(height: 12),
              Text(
                'Bu saatte aktif cihaz bulunamadı',
                style: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return devices.map((device) {
      final percentage = (device['energy'] / widget.totalEnergy * 100);
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: device['color'].withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  device['icon'],
                  color: device['color'],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${device['energy'].toStringAsFixed(2)} kWh',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: device['color'],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percentage / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: device['color'],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Map<String, dynamic>> _getDevicesForTimeSlot() {
    // Zaman dilimine göre gerçekçi cihaz simülasyonu
    final hour = widget.startHour;

    // Eğer predictions varsa, o saatteki gerçek tahmin değerini kullan
    double baseEnergy =
        widget.totalEnergy / (widget.endHour - widget.startHour);
    if (widget.predictions != null &&
        widget.startHour < widget.predictions!.length) {
      baseEnergy = widget.predictions![widget.startHour];
    }

    if (hour >= 0 && hour < 6) {
      // Gece 00:00 - 06:00 (Düşük tüketim)
      return [
        {
          'name': 'Buzdolabı',
          'icon': Icons.kitchen,
          'color': Colors.blue,
          'energy': baseEnergy * 0.45,
        },
        {
          'name': 'Modem/Router',
          'icon': Icons.router,
          'color': Colors.purple,
          'energy': baseEnergy * 0.30,
        },
        {
          'name': 'Bekleme Modundaki Cihazlar',
          'icon': Icons.power_settings_new,
          'color': Colors.orange,
          'energy': baseEnergy * 0.25,
        },
      ];
    } else if (hour >= 6 && hour < 9) {
      // Sabah 06:00 - 09:00 (Orta tüketim)
      return [
        {
          'name': 'Su Isıtıcısı',
          'icon': Icons.water_drop,
          'color': Colors.red,
          'energy': baseEnergy * 0.35,
        },
        {
          'name': 'Kahve Makinesi',
          'icon': Icons.coffee,
          'color': Colors.brown,
          'energy': baseEnergy * 0.25,
        },
        {
          'name': 'Buzdolabı',
          'icon': Icons.kitchen,
          'color': Colors.blue,
          'energy': baseEnergy * 0.20,
        },
        {
          'name': 'Aydınlatma',
          'icon': Icons.lightbulb,
          'color': Colors.amber,
          'energy': baseEnergy * 0.20,
        },
      ];
    } else if (hour >= 9 && hour < 12) {
      // Öğle 09:00 - 12:00 (Yüksek tüketim)
      return [
        {
          'name': 'Çamaşır Makinesi',
          'icon': Icons.local_laundry_service,
          'color': Colors.teal,
          'energy': baseEnergy * 0.30,
        },
        {
          'name': 'Bulaşık Makinesi',
          'icon': Icons.countertops,
          'color': Colors.indigo,
          'energy': baseEnergy * 0.28,
        },
        {
          'name': 'Fırın',
          'icon': Icons.bakery_dining,
          'color': Colors.deepOrange,
          'energy': baseEnergy * 0.25,
        },
        {
          'name': 'Buzdolabı',
          'icon': Icons.kitchen,
          'color': Colors.blue,
          'energy': baseEnergy * 0.17,
        },
      ];
    } else if (hour >= 12 && hour < 15) {
      // Öğleden sonra 12:00 - 15:00
      return [
        {
          'name': 'Televizyon',
          'icon': Icons.tv,
          'color': Colors.blueGrey,
          'energy': baseEnergy * 0.30,
        },
        {
          'name': 'Klima',
          'icon': Icons.ac_unit,
          'color': Colors.cyan,
          'energy': baseEnergy * 0.35,
        },
        {
          'name': 'Buzdolabı',
          'icon': Icons.kitchen,
          'color': Colors.blue,
          'energy': baseEnergy * 0.20,
        },
        {
          'name': 'Bilgisayar',
          'icon': Icons.computer,
          'color': Colors.grey,
          'energy': baseEnergy * 0.15,
        },
      ];
    } else if (hour >= 15 && hour < 18) {
      // İkindi 15:00 - 18:00
      return [
        {
          'name': 'Klima',
          'icon': Icons.ac_unit,
          'color': Colors.cyan,
          'energy': baseEnergy * 0.40,
        },
        {
          'name': 'Ütü',
          'icon': Icons.iron,
          'color': Colors.pink,
          'energy': baseEnergy * 0.25,
        },
        {
          'name': 'Televizyon',
          'icon': Icons.tv,
          'color': Colors.blueGrey,
          'energy': baseEnergy * 0.20,
        },
        {
          'name': 'Buzdolabı',
          'icon': Icons.kitchen,
          'color': Colors.blue,
          'energy': baseEnergy * 0.15,
        },
      ];
    } else if (hour >= 18 && hour < 21) {
      // Akşam 18:00 - 21:00 (En yüksek tüketim)
      return [
        {
          'name': 'Fırın',
          'icon': Icons.bakery_dining,
          'color': Colors.deepOrange,
          'energy': baseEnergy * 0.30,
        },
        {
          'name': 'Klima',
          'icon': Icons.ac_unit,
          'color': Colors.cyan,
          'energy': baseEnergy * 0.25,
        },
        {
          'name': 'Aydınlatma',
          'icon': Icons.lightbulb,
          'color': Colors.amber,
          'energy': baseEnergy * 0.20,
        },
        {
          'name': 'Televizyon',
          'icon': Icons.tv,
          'color': Colors.blueGrey,
          'energy': baseEnergy * 0.15,
        },
        {
          'name': 'Buzdolabı',
          'icon': Icons.kitchen,
          'color': Colors.blue,
          'energy': baseEnergy * 0.10,
        },
      ];
    } else {
      // Gece 21:00 - 00:00
      return [
        {
          'name': 'Televizyon',
          'icon': Icons.tv,
          'color': Colors.blueGrey,
          'energy': baseEnergy * 0.35,
        },
        {
          'name': 'Aydınlatma',
          'icon': Icons.lightbulb,
          'color': Colors.amber,
          'energy': baseEnergy * 0.30,
        },
        {
          'name': 'Buzdolabı',
          'icon': Icons.kitchen,
          'color': Colors.blue,
          'energy': baseEnergy * 0.20,
        },
        {
          'name': 'Şarj Cihazları',
          'icon': Icons.battery_charging_full,
          'color': Colors.green,
          'energy': baseEnergy * 0.15,
        },
      ];
    }
  }

  Widget _buildRecommendationsCard() {
    final recommendations = _getRecommendationsForTimeSlot();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity( 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.tips_and_updates,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tasarruf Önerileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          rec,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  List<String> _getRecommendationsForTimeSlot() {
    final hour = widget.startHour;

    if (hour >= 0 && hour < 6) {
      return [
        'Gece saatlerinde bekleme modundaki cihazları kapatın',
        'Akıllı prizler kullanarak bekleme tüketimini minimize edin',
        'Şarj cihazlarını gece boyunca takılı bırakmayın',
      ];
    } else if (hour >= 6 && hour < 9) {
      return [
        'Su ısıtıcınızı sadece ihtiyacınız kadar su ile çalıştırın',
        'Sabah rutininizi kısa tutarak enerji tasarrufu sağlayın',
        'Aydınlatma için doğal ışıktan yararlanın',
      ];
    } else if (hour >= 9 && hour < 12) {
      return [
        'Çamaşır makinesini tam dolu çalıştırın',
        'Fırını önceden ısıtma süresini minimize edin',
        'Bulaşık makinesini eco modda çalıştırın',
      ];
    } else if (hour >= 12 && hour < 15) {
      return [
        'Klimayı 24°C\'de tutarak enerji tasarrufu yapın',
        'Kullanmadığınız cihazları kapatın',
        'Güneş ışığından faydalanarak aydınlatma ihtiyacını azaltın',
      ];
    } else if (hour >= 15 && hour < 18) {
      return [
        'Klimanın sıcaklık ayarını kontrol edin',
        'Ütüyü düşük sıcaklık gerektiren kıyafetlerle başlayın',
        'Perdeleri kapatarak klimanın yükünü azaltın',
      ];
    } else if (hour >= 18 && hour < 21) {
      return [
        'Fırın yerine microdalga fırın kullanmayı düşünün',
        'LED ampuller kullanarak aydınlatma maliyetini düşürün',
        'Cihazları aynı anda çalıştırmaktan kaçının',
      ];
    } else {
      return [
        'Televizyon ve diğer eğlence cihazlarını kullanmadığınızda kapatın',
        'Gece ışığı yerine zamanlayıcılı aydınlatma kullanın',
        'Şarj cihazlarını şarj tamamlandıktan sonra çıkarın',
      ];
    }
  }
}
