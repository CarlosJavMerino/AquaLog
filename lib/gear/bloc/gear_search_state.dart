import 'package:equatable/equatable.dart';
import '../models/gear_search_result.dart';

/// Represents the lifecycle stages of a gear search operation.
enum SearchStatus { initial, loading, success, failure }

/// Immutable state class for the Gear Search feature.
///
/// Uses [Equatable] to facilitate value comparison, ensuring the UI 
/// only rebuilds when the state actually changes.
class GearSearchState extends Equatable {
  final SearchStatus status;
  final List<GearSearchResult> results;
  final String errorMessage;

  const GearSearchState({
    this.status = SearchStatus.initial,
    this.results = const [],
    this.errorMessage = '',
  });

  @override
  List<Object> get props => [status, results, errorMessage];
}