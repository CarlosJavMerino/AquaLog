import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:google_maps_flutter/google_maps_flutter.dart';

// BLoC & Domain
import '../add_dive/bloc/add_dive_bloc.dart';
import '../add_dive/bloc/add_dive_event.dart';
import '../add_dive/bloc/add_dive_state.dart';
import '../dives/repository/dive_repository.dart';
import '../dives/models/dive_model.dart';
import 'select_location_screen.dart'; 

// UI Constants
const Color primaryColor = Color(0xFF0A192F);
const Color accentColor = Color(0xFF48E3D4);
const Color cardColor = Color(0xFF112240);
const Color textColor = Colors.white;
const Color hintColor = Colors.white54;

class AddDiveScreen extends StatelessWidget {
  final Dive? initialDive;

  const AddDiveScreen({super.key, this.initialDive});

  static Route<void> route({Dive? initialDive}) {
    return MaterialPageRoute<void>(
      builder: (_) => AddDiveScreen(initialDive: initialDive),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text(
          initialDive == null ? 'Log New Dive' : 'Edit Dive', 
          style: const TextStyle(color: textColor)
        ),
        backgroundColor: cardColor,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: BlocProvider(
        create: (context) {
          return AddDiveBloc(
            diveRepository: RepositoryProvider.of<DiveRepository>(context),
            initialDive: initialDive,
          );
        },
        child: const _AddDiveForm(),
      ),
    );
  }
}

class _AddDiveForm extends StatelessWidget {
  const _AddDiveForm();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddDiveBloc, AddDiveState>(
      listenWhen: (previous, current) => previous.formStatus != current.formStatus,
      listener: (context, state) {
        if (state.formStatus == FormStatus.submissionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        if (state.formStatus == FormStatus.submissionSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Dive Details'),
            const SizedBox(height: 16),
            const _PlaceInput(),
            const SizedBox(height: 12),
            const _LocationSelector(), 
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: _DepthInput()),
                SizedBox(width: 12),
                Expanded(child: _TimeInput()),
              ],
            ),
            const SizedBox(height: 12),
            const _DateInput(),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Conditions'),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: _WaterTempInput()),
                SizedBox(width: 12),
                Expanded(child: _VisibilityInput()),
              ],
            ),
            const SizedBox(height: 12),
            const _CurrentInput(),

            const SizedBox(height: 24),
            _buildSectionHeader('Notes & Media'),
            const SizedBox(height: 16),
            const _BuddyInput(),
            const SizedBox(height: 12),
            const _NotesInput(),
            const SizedBox(height: 16),
            _PhotoPicker(),
            
            const SizedBox(height: 32),
            const _SubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title, 
      style: const TextStyle(
        color: accentColor, 
        fontSize: 18, 
        fontWeight: FontWeight.bold
      )
    );
  }
}

// --- INPUT FIELDS (Refactored for cleaner build method) ---

class _PlaceInput extends StatelessWidget {
  const _PlaceInput();
  @override
  Widget build(BuildContext context) {
    // Note: Using a stateful widget inside here isn't strictly necessary if using Bloc
    // effectively, but storing the controller helps with initial values.
    // For brevity in this portfolio example, we assume stateless + onChanged.
    // However, to strictly maintain cursor position, specific controllers are better.
    // Here we use the simplified Bloc approach.
    final state = context.watch<AddDiveBloc>().state;
    return TextFormField(
      initialValue: state.place,
      decoration: _inputDecoration('Dive Site Name', Icons.place),
      style: const TextStyle(color: textColor),
      onChanged: (v) => context.read<AddDiveBloc>().add(AddDivePlaceChanged(v)),
    );
  }
}

class _DepthInput extends StatelessWidget {
  const _DepthInput();
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddDiveBloc>().state;
    return TextFormField(
      initialValue: state.depth,
      decoration: _inputDecoration('Depth (m)', Icons.arrow_downward),
      style: const TextStyle(color: textColor),
      keyboardType: TextInputType.number,
      onChanged: (v) => context.read<AddDiveBloc>().add(AddDiveDepthChanged(v)),
    );
  }
}

class _TimeInput extends StatelessWidget {
  const _TimeInput();
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddDiveBloc>().state;
    return TextFormField(
      initialValue: state.time,
      decoration: _inputDecoration('Time (min)', Icons.timer),
      style: const TextStyle(color: textColor),
      keyboardType: TextInputType.number,
      onChanged: (v) => context.read<AddDiveBloc>().add(AddDiveTimeChanged(v)),
    );
  }
}

class _DateInput extends StatelessWidget {
  const _DateInput();
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddDiveBloc>().state;
    return OutlinedButton.icon(
      icon: const Icon(Icons.calendar_today, color: accentColor),
      label: Text(
        DateFormat('MMMM dd, yyyy').format(state.date),
        style: const TextStyle(color: textColor),
      ),
      onPressed: () async {
        FocusScope.of(context).unfocus();
        final newDate = await showDatePicker(
          context: context,
          initialDate: state.date,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (newDate != null && context.mounted) {
          context.read<AddDiveBloc>().add(AddDiveDateChanged(newDate));
        }
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: hintColor),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}

class _LocationSelector extends StatelessWidget {
  const _LocationSelector();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddDiveBloc>().state;
    final hasLocation = state.latitude != null;

    return ListTile(
      tileColor: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Icon(Icons.map, color: hasLocation ? accentColor : hintColor),
      title: Text(
        hasLocation ? 'Location Set' : 'Set Location on Map',
        style: TextStyle(color: hasLocation ? accentColor : hintColor),
      ),
      subtitle: hasLocation 
        ? Text('${state.latitude!.toStringAsFixed(4)}, ${state.longitude!.toStringAsFixed(4)}', style: const TextStyle(color: hintColor, fontSize: 12))
        : null,
      onTap: () async {
        final LatLng? result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SelectLocationScreen(
              initialLocation: hasLocation ? LatLng(state.latitude!, state.longitude!) : null
            ),
          ),
        );
        if (result != null && context.mounted) {
          context.read<AddDiveBloc>().add(AddDiveLocationChanged(
            latitude: result.latitude, 
            longitude: result.longitude
          ));
        }
      },
    );
  }
}

// ... Additional simple inputs for brevity in this snippet ...
class _WaterTempInput extends StatelessWidget {
  const _WaterTempInput();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: context.read<AddDiveBloc>().state.waterTemp,
      decoration: _inputDecoration('Temp (°C)', Icons.thermostat),
      style: const TextStyle(color: textColor),
      keyboardType: TextInputType.number,
      onChanged: (v) => context.read<AddDiveBloc>().add(AddDiveWaterTempChanged(v)),
    );
  }
}

class _VisibilityInput extends StatelessWidget {
  const _VisibilityInput();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: context.read<AddDiveBloc>().state.visibility,
      decoration: _inputDecoration('Visibility', Icons.visibility),
      style: const TextStyle(color: textColor),
      onChanged: (v) => context.read<AddDiveBloc>().add(AddDiveVisibilityChanged(v)),
    );
  }
}

class _CurrentInput extends StatelessWidget {
  const _CurrentInput();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: context.read<AddDiveBloc>().state.current,
      decoration: _inputDecoration('Current (e.g., Strong)', Icons.waves),
      style: const TextStyle(color: textColor),
      onChanged: (v) => context.read<AddDiveBloc>().add(AddDiveCurrentChanged(v)),
    );
  }
}

class _BuddyInput extends StatelessWidget {
  const _BuddyInput();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: context.read<AddDiveBloc>().state.buddy,
      decoration: _inputDecoration('Buddy Name', Icons.person),
      style: const TextStyle(color: textColor),
      onChanged: (v) => context.read<AddDiveBloc>().add(AddDiveBuddyChanged(v)),
    );
  }
}

class _NotesInput extends StatelessWidget {
  const _NotesInput();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: context.read<AddDiveBloc>().state.notes,
      decoration: _inputDecoration('Notes / Observations', Icons.note).copyWith(
        alignLabelWithHint: true,
      ),
      style: const TextStyle(color: textColor),
      maxLines: 4,
      onChanged: (v) => context.read<AddDiveBloc>().add(AddDiveNotesChanged(v)),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddDiveBloc>().state;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
            final List<XFile> images = await picker.pickMultiImage(imageQuality: 50);
            if (images.isNotEmpty && context.mounted) {
              context.read<AddDiveBloc>().add(
                AddDiveImagesSelected(images.map((e) => e.path).toList())
              );
            }
          },
          icon: const Icon(Icons.add_a_photo, color: accentColor),
          label: const Text('Add Photos', style: TextStyle(color: textColor)),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: hintColor)),
        ),
        if (state.localImagePaths.isNotEmpty || state.existingPhotoUrls.isNotEmpty)
          Container(
            height: 100,
            margin: const EdgeInsets.only(top: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...state.existingPhotoUrls.map((url) => _Thumbnail(
                      image: NetworkImage(url),
                      // EVENTO: Borrar foto ya guardada
                      onRemove: () => context.read<AddDiveBloc>().add(AddDiveExistingImageRemoved(url)),
                    )),
                ...state.localImagePaths.map((path) => _Thumbnail(
                      image: FileImage(File(path)),
                      // EVENTO: Borrar foto local recién elegida
                      onRemove: () => context.read<AddDiveBloc>().add(AddDiveLocalImageRemoved(path)),
                    )),
              ],
            ),
          ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback onRemove; // <-- Nuevo parámetro

  const _Thumbnail({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // La imagen con un poco de margen arriba y a la derecha para que quepa la X
        Padding(
          padding: const EdgeInsets.only(right: 12.0, top: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image(image: image, width: 90, height: 90, fit: BoxFit.cover),
          ),
        ),
        // Botón circular rojo con la X
        Positioned(
          top: 0,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddDiveBloc>().state;
    
    if (state.formStatus == FormStatus.submissionInProgress) {
      return const Center(child: CircularProgressIndicator(color: accentColor));
    }

    return ElevatedButton(
      onPressed: () => context.read<AddDiveBloc>().add(const AddDiveSubmitted()),
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text('Save Dive Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

InputDecoration _inputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: hintColor),
    labelStyle: const TextStyle(color: hintColor),
    filled: true,
    fillColor: cardColor,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: accentColor)),
  );
}