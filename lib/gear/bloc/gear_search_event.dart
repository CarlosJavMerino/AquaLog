import 'package:equatable/equatable.dart';

abstract class GearSearchEvent extends Equatable {
  const GearSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the user modifies the search text field.
/// This will initiate the debouncing logic in the BLoC to fetch results.
class GearSearchQueryChanged extends GearSearchEvent {
  final String query;
  
  const GearSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event triggered to reset the search state and clear the results list.
class GearSearchClear extends GearSearchEvent {}