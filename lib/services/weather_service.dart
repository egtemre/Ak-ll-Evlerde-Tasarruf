import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/weather.dart';

class WeatherService {
  // OpenWeatherMap API key - Gerçek bir API key ile değiştirin
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Muğla koordinatları
  static const double _muglaLat = 37.2153;
  static const double _muglaLon = 28.3636;

  // Şu anki hava durumunu getir
  Future<Weather?> getCurrentWeather() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/weather?lat=$_muglaLat&lon=$_muglaLon&appid=$_apiKey&units=metric&lang=tr',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching current weather: $e');
      return null;
    }
  }

  // Saatlik hava durumu tahmini (48 saat)
  Future<List<HourlyWeather>> getHourlyForecast() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/forecast?lat=$_muglaLat&lon=$_muglaLon&appid=$_apiKey&units=metric&lang=tr',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['list'];

        // Sadece bugünün verilerini al (ilk 8 veri = 24 saat / 3 saat)
        final today = DateTime.now();
        return list
            .map((item) => HourlyWeather.fromJson(item))
            .where((weather) =>
                weather.dateTime.day == today.day &&
                weather.dateTime.month == today.month)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching hourly forecast: $e');
      return [];
    }
  }

  // Mock data - API key olmadan test için
  Weather getMockCurrentWeather() {
    return Weather(
      city: 'Muğla',
      temperature: 22.5,
      tempMin: 18.0,
      tempMax: 26.0,
      description: 'Açık',
      icon: '01d',
      humidity: 65,
      windSpeed: 3.5,
      dateTime: DateTime.now(),
    );
  }

  List<HourlyWeather> getMockHourlyForecast() {
    final now = DateTime.now();
    return List.generate(8, (index) {
      return HourlyWeather(
        dateTime: now.add(Duration(hours: index * 3)),
        temperature: 20.0 + (index * 2),
        description: index % 2 == 0 ? 'Açık' : 'Az bulutlu',
        icon: index % 2 == 0 ? '01d' : '02d',
        humidity: 60.0 + index,
        hour: (now.hour + (index * 3)) % 24,
      );
    });
  }

  // Hava durumu ikonuna göre Flutter ikonu döndür
  static String getWeatherIcon(String iconCode) {
    if (iconCode.startsWith('01')) return '☀️'; // Açık
    if (iconCode.startsWith('02')) return '⛅'; // Az bulutlu
    if (iconCode.startsWith('03')) return '☁️'; // Bulutlu
    if (iconCode.startsWith('04')) return '☁️'; // Çok bulutlu
    if (iconCode.startsWith('09')) return '🌧️'; // Sağanak yağmur
    if (iconCode.startsWith('10')) return '🌦️'; // Yağmurlu
    if (iconCode.startsWith('11')) return '⛈️'; // Gök gürültülü
    if (iconCode.startsWith('13')) return '❄️'; // Karlı
    if (iconCode.startsWith('50')) return '🌫️'; // Sisli
    return '☀️';
  }

  // Türkçe hava durumu açıklaması
  static String getTurkishDescription(String description) {
    final map = {
      'clear sky': 'Açık',
      'few clouds': 'Az Bulutlu',
      'scattered clouds': 'Parçalı Bulutlu',
      'broken clouds': 'Çok Bulutlu',
      'shower rain': 'Sağanak Yağmurlu',
      'rain': 'Yağmurlu',
      'thunderstorm': 'Gök Gürültülü Fırtına',
      'snow': 'Karlı',
      'mist': 'Sisli',
    };
    return map[description.toLowerCase()] ?? description;
  }
}
