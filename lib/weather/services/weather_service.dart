import 'package:dio/dio.dart';
import '../models/weather_model.dart';

/// Service responsible for fetching weather data from external APIs.
/// Uses the Open-Meteo API (Free, no key required).
class WeatherService {
  final Dio _dio;

  WeatherService({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetches current weather data for a given city name.
  /// 
  /// The process involves two steps:
  /// 1. Geocoding the city name to get (Lat, Lng).
  /// 2. Fetching forecast data for those coordinates.
  Future<WeatherData> getWeatherByCity(String cityName) async {
    try {
      // Step 1: Geocoding
      final geoResponse = await _dio.get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {
          'name': cityName,
          'count': 1,
          'language': 'es',
          'format': 'json',
        },
      );

      if (geoResponse.data['results'] == null || (geoResponse.data['results'] as List).isEmpty) {
        throw Exception('Ciudad no encontrada. Por favor revisa el nombre.');
      }

      final location = geoResponse.data['results'][0];
      final double lat = location['latitude'];
      final double lon = location['longitude'];
      final String resolvedName = location['name'];

      // Step 2: Weather Forecast
      final weatherResponse = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': 'temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m,weather_code',
          'wind_speed_unit': 'kmh',
        },
      );
      
      if (weatherResponse.statusCode == 200) {
        return WeatherData.fromOpenMeteo(weatherResponse.data, resolvedName);
      } else {
        throw Exception('Error del proveedor de clima: ${weatherResponse.statusCode}');
      }

    } on DioException catch (e) {
      // Handling network-specific errors (Timeout, DNS, etc.)
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
         throw Exception('Tiempo de espera agotado. Revisa tu conexión.');
      }
      throw Exception('Error de conexión con el servicio meteorológico.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}