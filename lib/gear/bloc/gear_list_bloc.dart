import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/gear_repository.dart';
import '../models/gear_model.dart';
import 'gear_list_event.dart';
import 'gear_list_state.dart';

/// Manages the state of the Gear Inventory list.
/// 
/// This BLoC handles real-time data subscriptions from Firestore
/// and user actions like deleting items.
class GearListBloc extends Bloc<GearListEvent, GearListState> {
  final GearRepository _gearRepository;

  GearListBloc({required GearRepository gearRepository})
      : _gearRepository = gearRepository,
        super(const GearListState()) {
    
    on<GearListSubscriptionRequested>(_onSubscriptionRequested);
    on<GearListDeleted>(_onDeleted);
  }

  /// Subscribes to the stream of gear items.
  /// 
  /// Uses [emit.forEach] to reactively update the state whenever the 
  /// repository stream emits a new list (e.g., data added/modified in Firestore).
  /// This approach automatically handles stream subscription and cancellation.
  Future<void> _onSubscriptionRequested(
    GearListSubscriptionRequested event,
    Emitter<GearListState> emit,
  ) async {
    emit(state.copyWith(status: GearListStatus.loading));

    await emit.forEach<List<GearItem>>(
      _gearRepository.getGear(),
      onData: (items) => state.copyWith(
        status: GearListStatus.success,
        items: items,
      ),
      onError: (_, __) => state.copyWith(status: GearListStatus.failure),
    );
  }

  /// Handles the deletion of a specific gear item.
  Future<void> _onDeleted(
    GearListDeleted event,
    Emitter<GearListState> emit,
  ) async {
    try {
      await _gearRepository.deleteGear(event.gearId);
      // No need to emit a new state here; the stream in _onSubscriptionRequested
      // will automatically emit the updated list once the deletion propagates.
    } catch (e) {
      // In a production app, we would emit an error state or side-effect here
      // to notify the UI (e.g., show a SnackBar).
    }
  }
}