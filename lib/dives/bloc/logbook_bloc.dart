import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/dive_repository.dart';
import 'logbook_event.dart';
import 'logbook_state.dart';
import '../models/dive_model.dart';

class LogbookBloc extends Bloc<LogbookEvent, LogbookState> {
  final DiveRepository _diveRepository;

  LogbookBloc({required DiveRepository diveRepository})
      : _diveRepository = diveRepository,
        super(const LogbookState()) { 
    
    on<LogbookSubscriptionRequested>(_onSubscriptionRequested);
    on<LogbookDiveDeleted>(_onDiveDeleted);
    on<LogbookDiveUpdated>(_onDiveUpdated);
  }

  /// Handles real-time updates from the repository.
  /// 
  /// Note: We use [emit.forEach] to bridge the Stream from the repository to the BLoC.
  /// This automatically handles stream subscription and cancellation, 
  /// yielding a new state every time Firestore emits new data.
  Future<void> _onSubscriptionRequested(
    LogbookSubscriptionRequested event,
    Emitter<LogbookState> emit,
  ) async {
    emit(state.copyWith(status: LogbookStatus.loading));
    
    await emit.forEach<List<Dive>>(
      _diveRepository.getDives(),
      onData: (dives) => state.copyWith(
        status: LogbookStatus.success,
        dives: dives,
      ),
      onError: (_, __) => state.copyWith(
        status: LogbookStatus.failure,
        errorMessage: 'Failed to load dives',
      ),
    );
  }

  Future<void> _onDiveDeleted(
    LogbookDiveDeleted event,
    Emitter<LogbookState> emit,
  ) async {
    try {
      // Optimistic UI updates are not needed here because the 
      // Stream in _onSubscriptionRequested will automatically emit the new list
      // once the deletion propagates in Firestore.
      await _diveRepository.deleteDive(event.diveId);
    } catch (e) {
      // In a real app, we might want to emit a transient error state (SnackBar)
      print('Error deleting dive: $e');
    }
  }

  Future<void> _onDiveUpdated(
    LogbookDiveUpdated event,
    Emitter<LogbookState> emit,
  ) async {
    try {
      await _diveRepository.updateDive(event.dive);
    } catch (e) {
      print('Error updating dive: $e');
    }
  }
}