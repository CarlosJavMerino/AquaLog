import 'package:equatable/equatable.dart';
import '../models/gear_model.dart';

/// Defines the possible UI states for the gear list feature.
enum GearListStatus { initial, loading, success, failure }

/// Represents the state of the Gear List view.
/// 
/// This state manages the list of equipment ([items]) and the current 
/// loading status ([status]) to drive the UI.
class GearListState extends Equatable {
  final GearListStatus status;
  final List<GearItem> items;

  const GearListState({
    this.status = GearListStatus.initial,
    this.items = const [],
  });

  /// Creates a copy of the current state with updated fields.
  /// 
  /// This pattern ensures state immutability, which is crucial for 
  /// predictable state management in BLoC.
  GearListState copyWith({
    GearListStatus? status,
    List<GearItem>? items,
  }) {
    return GearListState(
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }

  @override
  List<Object> get props => [status, items];
}