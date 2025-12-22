import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather.dart';
import '../providers/app_state.dart';
import '../services/weather_service.dart';
import '../theme/app_theme.dart';

class HourlyWeatherDialog extends StatelessWidget {
  final List<HourlyWeather> hourlyWeather;

  const HourlyWeatherDialog({
    super.key,
    required this.hourlyWeather,
  });

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<AppState>(context, listen: false).loc;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    loc.hourlyForecast,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Saatlik listesi
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                itemCount: hourlyWeather.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final weather = hourlyWeather[index];
                  return _buildHourlyItem(weather, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyItem(HourlyWeather weather, BuildContext context) {
    final loc = Provider.of<AppState>(context, listen: false).loc;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Saat
          SizedBox(
            width: 60,
            child: Text(
              '${weather.hour.toString().padLeft(2, '0')}:00',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // İkon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                WeatherService.getWeatherIcon(weather.icon),
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Açıklama
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WeatherService.getTurkishDescription(weather.description),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${loc.humidity}: %${weather.humidity.toInt()}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Sıcaklık
          Text(
            '${weather.temperature.toStringAsFixed(1)}°',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
