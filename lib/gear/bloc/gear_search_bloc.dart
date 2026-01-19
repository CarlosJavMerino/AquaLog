import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/gear_search_service.dart';
import 'gear_search_event.dart';
import 'gear_search_state.dart';

/// Manages the search logic for the Gear inventory.
/// 
/// This BLoC acts as the intermediary between the UI search input 
/// and the external [GearSearchService] (Google Custom Search API).
class GearSearchBloc extends Bloc<GearSearchEvent, GearSearchState> {
  final GearSearchService _searchService;

  GearSearchBloc({required GearSearchService searchService})
      : _searchService = searchService,
        super(const GearSearchState()) {
    
    on<GearSearchQueryChanged>(_onQueryChanged);
    on<GearSearchClear>(_onClear);
  }

  /// Triggers the search operation.
  /// 
  /// Emits [SearchStatus.loading] immediately, then awaits the service result.
  /// Maps exceptions to [SearchStatus.failure] with a readable error message.
  Future<void> _onQueryChanged(
    GearSearchQueryChanged event,
    Emitter<GearSearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(const GearSearchState(status: SearchStatus.initial));
      return;
    }

    emit(const GearSearchState(status: SearchStatus.loading));

    try {
      final results = await _searchService.searchGear(event.query);
      
      emit(GearSearchState(
        status: SearchStatus.success,
        results: results,
      ));
    } catch (e) {
      emit(GearSearchState(
        status: SearchStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Resets the search state, clearing results and errors.
  void _onClear(GearSearchClear event, Emitter<GearSearchState> emit) {
    emit(const GearSearchState(status: SearchStatus.initial));
  }
}