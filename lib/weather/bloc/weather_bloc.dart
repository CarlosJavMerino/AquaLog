import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/weather_service.dart';
import 'weather_event.dart';
import 'weather_state.dart';

/// Manages the state of weather data retrieval.
/// 
/// This BLoC acts as the intermediary between the UI and the [WeatherService],
/// handling asynchronous data fetching, loading states, and error mapping.
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherService _service;

  WeatherBloc({required WeatherService service})
      : _service = service,
        super(const WeatherState()) {
    on<WeatherSearchRequested>(_onSearch);
  }

  /// Handles the search request.
  /// 
  /// Triggers a state change to [loading], fetches data from the service,
  /// and updates the state to either [success] or [failure].
  Future<void> _onSearch(WeatherSearchRequested event, Emitter<WeatherState> emit) async {
    // Input validation: Ignore empty or whitespace-only queries
    if (event.city.trim().isEmpty) return;

    // Reset state to loading (clearing previous results if any)
    emit(const WeatherState(status: WeatherStatus.loading));

    try {
      final result = await _service.getWeatherByCity(event.city);
      emit(WeatherState(status: WeatherStatus.success, weather: result));
    } catch (e) {
      // Error Handling: Clean up the exception message for better UI presentation
      // Removing the technical 'Exception:' prefix to show a user-friendly message.
      final cleanError = e.toString().replaceAll('Exception:', '').trim();
      
      emit(WeatherState(
        status: WeatherStatus.failure, 
        errorMessage: cleanError,
      ));
    }
  }
}