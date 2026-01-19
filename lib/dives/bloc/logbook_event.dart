import 'package:equatable/equatable.dart';
import '../models/dive_model.dart';

abstract class LogbookEvent extends Equatable {
  const LogbookEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to initialize the subscription to the Firestore stream.
class LogbookSubscriptionRequested extends LogbookEvent {
  const LogbookSubscriptionRequested();
}

/// Event triggered when a user requests to delete a specific dive.
class LogbookDiveDeleted extends LogbookEvent {
  final String diveId;

  const LogbookDiveDeleted(this.diveId);

  @override
  List<Object?> get props => [diveId];
}

/// Event triggered when a dive has been modified and needs to be updated in the repository.
class LogbookDiveUpdated extends LogbookEvent {
  final Dive dive;

  const LogbookDiveUpdated(this.dive);

  @override
  List<Object?> get props => [dive];
}