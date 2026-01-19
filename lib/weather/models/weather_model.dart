import 'package:flutter/material.dart';

/// Domain model representing weather conditions for a specific location.
/// 
/// Designed to parse and normalize data from Open-Meteo API using WMO Weather Codes.
class WeatherData {
  final String cityName;
  final double temperature;
  final double windSpeed;
  final int windDeg;
  final int humidity;
  final int weatherCode;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.windSpeed,
    required this.windDeg,
    required this.humidity,
    required this.weatherCode,
  });

  /// Factory constructor to parse raw JSON from Open-Meteo API.
  factory WeatherData.fromOpenMeteo(Map<String, dynamic> json, String city) {
    final current = json['current'];
    
    return WeatherData(
      cityName: city,
      temperature: (current['temperature_2m'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      windDeg: (current['wind_direction_10m'] as num).toInt(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      weatherCode: (current['weather_code'] as num).toInt(),
    );
  }

  /// Calculates cardinal wind direction (N, NE, E...) from degrees.
  String get windDirection {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
    var val = ((windDeg / 45) + 0.5).floor();
    return directions[val % 8];
  }

  /// Converts WMO Weather interpretation codes (0-99) into human-readable descriptions.
  /// Note: Strings are kept in Spanish for the target user audience.
  String get description {
    switch (weatherCode) {
      case 0: return 'Cielo despejado';
      case 1: return 'Mayormente despejado';
      case 2: return 'Parcialmente nublado';
      case 3: return 'Nublado';
      case 45: case 48: return 'Niebla';
      case 51: case 53: case 55: return 'Llovizna';
      case 61: case 63: case 65: return 'Lluvia';
      case 80: case 81: case 82: return 'Lluvia intensa';
      case 71: case 73: case 75: return 'Nieve';
      case 95: return 'Tormenta';
      case 96: case 99: return 'Tormenta con granizo';
      default: return 'Clima variable';
    }
  }

  /// Maps WMO codes to Material Icons for visual representation.
  IconData get icon {
    switch (weatherCode) {
      case 0: return Icons.wb_sunny;
      case 1: case 2: return Icons.wb_sunny_outlined;
      case 3: return Icons.cloud;
      case 45: case 48: return Icons.foggy;
      case 51: case 53: case 55: return Icons.grain;
      case 61: case 63: case 65: return Icons.water_drop;
      case 80: case 81: case 82: return Icons.tsunami;
      case 95: case 96: case 99: return Icons.flash_on;
      default: return Icons.help_outline;
    }
  }
  
  /// Determines the UI color theme based on weather severity/type.
  Color get iconColor {
     if (weatherCode == 0) return Colors.orange; // Sunny
     if (weatherCode <= 3) return Colors.yellow; // Cloudy/Partly Sunny
     if (weatherCode >= 95) return Colors.redAccent; // Storm
     return Colors.lightBlueAccent; // Rain/Fog/General
  }
}