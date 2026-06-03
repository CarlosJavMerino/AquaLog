import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dives/models/dive_model.dart';
import '../../dives/repository/dive_repository.dart';
import 'add_dive_event.dart';
import 'add_dive_state.dart';

/// Manages the state for adding or editing a Dive.
/// 
/// This BLoC handles form validation, image processing triggering, 
/// and communication with the repository.
class AddDiveBloc extends Bloc<AddDiveEvent, AddDiveState> {
  final DiveRepository _diveRepository;
  final Dive? _initialDive;

  AddDiveBloc({
    required DiveRepository diveRepository,
    Dive? initialDive,
  })  : _diveRepository = diveRepository,
        _initialDive = initialDive,
        super(initialDive != null
            ? AddDiveState.fromDive(initialDive)
            : AddDiveState()) {
    
    // Field update handlers (Reactive approach)
    on<AddDivePlaceChanged>((event, emit) => emit(state.copyWith(place: event.place)));
    on<AddDiveDepthChanged>((event, emit) => emit(state.copyWith(depth: event.depth)));
    on<AddDiveTimeChanged>((event, emit) => emit(state.copyWith(time: event.time)));
    on<AddDiveDateChanged>((event, emit) => emit(state.copyWith(date: event.date)));
    on<AddDiveNotesChanged>((event, emit) => emit(state.copyWith(notes: event.notes)));
    
    // Optional metrics handlers
    on<AddDiveBuddyChanged>((event, emit) => emit(state.copyWith(buddy: event.buddy)));
    on<AddDiveVisibilityChanged>((event, emit) => emit(state.copyWith(visibility: event.visibility)));
    on<AddDiveCurrentChanged>((event, emit) => emit(state.copyWith(current: event.current)));
    on<AddDiveWaterTempChanged>((event, emit) => emit(state.copyWith(waterTemp: event.waterTemp)));
    
    // Media and Location handlers
    on<AddDiveImagesSelected>(_onImagesSelected);
    on<AddDiveLocationChanged>(_onLocationChanged);
    
    // Submission handler
    on<AddDiveSubmitted>(_onSubmitted);
    
    on<AddDiveLocalImageRemoved>((event, emit) {
      final updatedPaths = List<String>.from(state.localImagePaths)..remove(event.path);
      emit(state.copyWith(localImagePaths: updatedPaths));
    });

    on<AddDiveExistingImageRemoved>((event, emit) {
      final updatedUrls = List<String>.from(state.existingPhotoUrls)..remove(event.url);
      emit(state.copyWith(existingPhotoUrls: updatedUrls));
    });
  }

  /// Returns true if the BLoC was initialized with an existing dive (Edit Mode).
  bool get isEditing => _initialDive != null;

  void _onImagesSelected(AddDiveImagesSelected event, Emitter<AddDiveState> emit) {
    // Immutability: Create a new list combining old and new paths
    final updatedPaths = List<String>.from(state.localImagePaths)..addAll(event.imagePaths);
    emit(state.copyWith(localImagePaths: updatedPaths));
  }

  void _onLocationChanged(AddDiveLocationChanged event, Emitter<AddDiveState> emit) {
    emit(state.copyWith(
      latitude: event.latitude,
      longitude: event.longitude,
    ));
  }

  Future<void> _onSubmitted(AddDiveSubmitted event, Emitter<AddDiveState> emit) async {
    // Prevent double submission
    if (state.formStatus == FormStatus.submissionInProgress) return;
    
    // 1. Basic Validation Logic
    if (state.place.isEmpty) {
      emit(state.copyWith(
        formStatus: FormStatus.submissionFailure, 
        errorMessage: 'Por favor, escribe el nombre del lugar.'
      ));
      return;
    }
    
    // 2. Format Validation
    final depthInt = int.tryParse(state.depth);
    final timeInt = int.tryParse(state.time);

    if (depthInt == null || timeInt == null) {
      emit(state.copyWith(
        formStatus: FormStatus.submissionFailure, 
        errorMessage: 'Profundidad y tiempo deben ser números válidos.'
      ));
      return;
    }

    emit(state.copyWith(formStatus: FormStatus.submissionInProgress));

    try {
      // 3. Data Preparation
      final waterTempInt = state.waterTemp.isNotEmpty ? int.tryParse(state.waterTemp) : null;
      if (state.waterTemp.isNotEmpty && waterTempInt == null) {
        throw const FormatException('Temperatura inválida');
      }

      // Process images via Repository (Abstraction)
      List<String> newPhotoUrls = [];
      if (state.localImagePaths.isNotEmpty) {
        newPhotoUrls = await _diveRepository.uploadImages(state.localImagePaths);
      }
      
      final allPhotoUrls = [...state.existingPhotoUrls, ...newPhotoUrls];

      // 4. Persistence
      if (isEditing) {
        final updatedDive = Dive(
          id: _initialDive!.id,
          userId: _initialDive!.userId, // Preserve original owner
          place: state.place,
          depth: depthInt,
          time: timeInt,
          date: state.date,
          notes: state.notes.isNotEmpty ? state.notes : null,
          buddy: state.buddy.isNotEmpty ? state.buddy : null,
          visibility: state.visibility.isNotEmpty ? state.visibility : null,
          current: state.current.isNotEmpty ? state.current : null,
          waterTemp: waterTempInt,
          photos: allPhotoUrls,
          latitude: state.latitude, 
          longitude: state.longitude,
        );
        await _diveRepository.updateDive(updatedDive);
      } else {
        await _diveRepository.addDive(
          place: state.place,
          depth: depthInt,
          time: timeInt,
          date: state.date,
          notes: state.notes.isNotEmpty ? state.notes : null,
          buddy: state.buddy.isNotEmpty ? state.buddy : null,
          visibility: state.visibility.isNotEmpty ? state.visibility : null,
          current: state.current.isNotEmpty ? state.current : null,
          waterTemp: waterTempInt,
          photos: allPhotoUrls,
          latitude: state.latitude,
          longitude: state.longitude,
        );
      }

      emit(state.copyWith(formStatus: FormStatus.submissionSuccess));

    } catch (e) {
      // Error handling allows the UI to show a snackbar and let the user try again
      emit(state.copyWith(
        formStatus: FormStatus.submissionFailure,
        errorMessage: 'Error al guardar. Verifica tu conexión.',
      ));
    }
  }
}