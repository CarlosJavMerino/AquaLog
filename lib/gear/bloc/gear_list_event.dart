import 'package:equatable/equatable.dart';

abstract class GearListEvent extends Equatable {
  const GearListEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to initialize the subscription to the gear stream.
/// This starts the real-time data flow from the repository to the UI.
class GearListSubscriptionRequested extends GearListEvent {
  const GearListSubscriptionRequested();
}

/// Event triggered when a user confirms the deletion of a gear item.
class GearListDeleted extends GearListEvent {
  final String gearId;

  const GearListDeleted(this.gearId);

  @override
  List<Object?> get props => [gearId];
}