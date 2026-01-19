import 'package:equatable/equatable.dart';

abstract class AddDiveEvent extends Equatable {
  const AddDiveEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the place/site name input changes.
class AddDivePlaceChanged extends AddDiveEvent {
  final String place;
  const AddDivePlaceChanged(this.place);
  @override
  List<Object?> get props => [place];
}

/// Triggered when the depth input changes.
class AddDiveDepthChanged extends AddDiveEvent {
  final String depth;
  const AddDiveDepthChanged(this.depth);
  @override
  List<Object?> get props => [depth];
}

/// Triggered when the duration/time input changes.
class AddDiveTimeChanged extends AddDiveEvent {
  final String time;
  const AddDiveTimeChanged(this.time);
  @override
  List<Object?> get props => [time];
}

/// Triggered when the dive date is selected.
class AddDiveDateChanged extends AddDiveEvent {
  final DateTime date;
  const AddDiveDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

/// Triggered when the notes input changes.
class AddDiveNotesChanged extends AddDiveEvent {
  final String notes;
  const AddDiveNotesChanged(this.notes);
  @override
  List<Object?> get props => [notes];
}

/// Triggered when the buddy name input changes.
class AddDiveBuddyChanged extends AddDiveEvent {
  final String buddy;
  const AddDiveBuddyChanged(this.buddy);
  @override
  List<Object?> get props => [buddy];
}

/// Triggered when the visibility input changes.
class AddDiveVisibilityChanged extends AddDiveEvent {
  final String visibility;
  const AddDiveVisibilityChanged(this.visibility);
  @override
  List<Object?> get props => [visibility];
}

/// Triggered when the current condition input changes.
class AddDiveCurrentChanged extends AddDiveEvent {
  final String current;
  const AddDiveCurrentChanged(this.current);
  @override
  List<Object?> get props => [current];
}

/// Triggered when the water temperature input changes.
class AddDiveWaterTempChanged extends AddDiveEvent {
  final String waterTemp;
  const AddDiveWaterTempChanged(this.waterTemp);
  @override
  List<Object?> get props => [waterTemp];
}

/// Triggered when new images are selected from the device gallery.
class AddDiveImagesSelected extends AddDiveEvent {
  final List<String> imagePaths;
  const AddDiveImagesSelected(this.imagePaths);
  @override
  List<Object?> get props => [imagePaths];
}

/// Triggered when a location is selected or cleared via the map interface.
class AddDiveLocationChanged extends AddDiveEvent {
  final double? latitude;
  final double? longitude;

  const AddDiveLocationChanged({this.latitude, this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Triggered when the form is submitted to persist the dive.
class AddDiveSubmitted extends AddDiveEvent {
  const AddDiveSubmitted();
}