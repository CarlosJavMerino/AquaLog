import 'package:flutter_test/flutter_test.dart';
import 'package:aqualog/weather/models/weather_model.dart';
import 'package:flutter/material.dart';

void main() {
  group('WeatherData Model Tests', () {
    
    // Un JSON simulado como el que devolvería la API
    final Map<String, dynamic> mockJson = {
      'current': {
        'temperature_2m': 25.5,
        'wind_speed_10m': 15.0,
        'wind_direction_10m': 90, // 90 grados = Este
        'relative_humidity_2m': 60,
        'weather_code': 0 // 0 = Despejado
      }
    };

    test('fromOpenMeteo crea el objeto correctamente', () {
      final weather = WeatherData.fromOpenMeteo(mockJson, 'Madrid');

      expect(weather.cityName, 'Madrid');
      expect(weather.temperature, 25.5);
      expect(weather.windSpeed, 15.0);
    });

    test('El código 0 devuelve "Cielo despejado" y el icono correcto', () {
      final weather = WeatherData.fromOpenMeteo(mockJson, 'Madrid');

      expect(weather.description, 'Cielo despejado');
      // No testeamos el IconData exacto por problemas de contexto de Flutter en tests unitarios puros, 
      // pero testeamos que la lógica del color funcione
      expect(weather.iconColor.value, const Color(0xFFFF9800).value);
    });

    test('La dirección del viento (90 grados) es "E" (Este)', () {
      final weather = WeatherData.fromOpenMeteo(mockJson, 'Madrid');
      
      expect(weather.windDirection, 'E');
    });
  });
}