import 'package:equatable/equatable.dart';

/// Base abstract class for all events related to the Weather feature.
///
/// Extends [Equatable] to facilitate testing and state change detection
/// by comparing object values rather than memory references.
abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when the user initiates a weather search for a specific city.
class WeatherSearchRequested extends WeatherEvent {
  final String city;

  const WeatherSearchRequested(this.city);

  @override
  List<Object> get props => [city];
}