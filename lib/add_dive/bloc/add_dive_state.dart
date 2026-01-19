import 'package:equatable/equatable.dart';
import 'package:aqualog/dives/models/dive_model.dart';

enum FormStatus { initial, submissionInProgress, submissionSuccess, submissionFailure }

/// Represents the state of the Dive Entry form (Add/Edit).
/// 
/// Holds all input fields, validation status, and temporary media paths 
/// before they are persisted to the repository.
class AddDiveState extends Equatable {
  // Core Data
  final String place;
  final String depth; 
  final String time;  
  final DateTime date;
  final String notes;

  // Conditions & Social
  final String buddy;
  final String visibility;
  final String current;
  final String waterTemp;

  // Media & Location
  final List<String> localImagePaths;
  final List<String> existingPhotoUrls;
  final double? latitude;
  final double? longitude;
  
  // UI Status
  final FormStatus formStatus;
  final String errorMessage;

  AddDiveState({
    this.place = '',
    this.depth = '',
    this.time = '',
    DateTime? date, 
    this.notes = '',
    this.buddy = '',
    this.visibility = '',
    this.current = '',
    this.waterTemp = '',
    this.localImagePaths = const [],
    this.existingPhotoUrls = const [],
    this.latitude,
    this.longitude,
    this.formStatus = FormStatus.initial,
    this.errorMessage = '',
  }) : date = date ?? DateTime.now(); 

  /// Factory method to initialize the form state from an existing Dive (Edit Mode).
  factory AddDiveState.fromDive(Dive dive) {
    return AddDiveState(
      place: dive.place,
      depth: dive.depth.toString(),
      time: dive.time.toString(),
      date: dive.date,
      notes: dive.notes ?? '',
      buddy: dive.buddy ?? '',
      visibility: dive.visibility ?? '',
      current: dive.current ?? '',
      waterTemp: dive.waterTemp?.toString() ?? '',
      existingPhotoUrls: dive.photos,
      latitude: dive.latitude,
      longitude: dive.longitude,
    );
  }

  AddDiveState copyWith({
    String? place,
    String? depth,
    String? time,
    DateTime? date,
    String? notes,
    String? buddy,
    String? visibility,
    String? current,
    String? waterTemp,
    FormStatus? formStatus,
    String? errorMessage,
    List<String>? localImagePaths,
    List<String>? existingPhotoUrls,
    double? latitude,
    double? longitude,
  }) {
    return AddDiveState(
      place: place ?? this.place,
      depth: depth ?? this.depth,
      time: time ?? this.time,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      buddy: buddy ?? this.buddy,
      visibility: visibility ?? this.visibility,
      current: current ?? this.current,
      waterTemp: waterTemp ?? this.waterTemp,
      formStatus: formStatus ?? this.formStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      localImagePaths: localImagePaths ?? this.localImagePaths,
      existingPhotoUrls: existingPhotoUrls ?? this.existingPhotoUrls,
      // Note: Standard copyWith pattern keeps the old value if the new one is null.
      // If explicit clearing is needed, a wrapper class (e.g. Value<T?>) would be required.
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
    place, depth, time, date, notes, buddy, visibility, current, waterTemp,
    formStatus, errorMessage, localImagePaths, existingPhotoUrls,
    latitude, longitude
  ];
}