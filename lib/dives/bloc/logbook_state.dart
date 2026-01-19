import 'package:equatable/equatable.dart';
import '../models/dive_model.dart';

enum LogbookStatus { initial, loading, success, failure }

/// Represents the UI state of the Dive Logbook feature.
///
/// Uses [Equatable] to ensure efficient state comparisons by the BLoC library,
/// preventing unnecessary rebuilds if the data hasn't changed.
class LogbookState extends Equatable {
  final LogbookStatus status;
  final List<Dive> dives;
  final String? errorMessage;

  const LogbookState({
    this.status = LogbookStatus.initial,
    this.dives = const [],
    this.errorMessage,
  });

  /// Utility method to create a modified copy of the state while maintaining immutability.
  /// This is essential for the BLoC pattern as states must be immutable.
  LogbookState copyWith({
    LogbookStatus? status,
    List<Dive>? dives,
    String? errorMessage,
  }) {
    return LogbookState(
      status: status ?? this.status,
      dives: dives ?? this.dives,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [status, dives, errorMessage];
}