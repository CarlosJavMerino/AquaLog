import 'package:equatable/equatable.dart';
import '../models/weather_model.dart';

/// Represents the lifecycle stages of a weather data request.
enum WeatherStatus { initial, loading, success, failure }

/// Defines the UI state for the Weather feature.
///
/// Uses [Equatable] to ensure value equality, allowing the Bloc to ignore
/// duplicate states and minimize unnecessary widget rebuilds.
class WeatherState extends Equatable {
  final WeatherStatus status;
  final WeatherData? weather;
  final String errorMessage;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather,
    this.errorMessage = '',
  });

  @override
  List<Object?> get props => [status, weather, errorMessage];
}