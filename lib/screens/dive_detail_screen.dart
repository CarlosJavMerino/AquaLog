import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../dives/models/dive_model.dart';
import 'add_dive_screen.dart';

// UI Constants
const Color primaryColor = Color(0xFF0A192F);
const Color accentColor = Color(0xFF48E3D4);
const Color cardColor = Color(0xFF112240);
const Color textColor = Colors.white;
const Color hintColor = Colors.white54;

/// Displays the detailed information of a specific [Dive] entry.
/// 
/// This screen acts as a read-only view for dive data, media gallery, 
/// and location visualization, with an entry point to edit the log.
class DiveDetailScreen extends StatelessWidget {
  final Dive dive;

  const DiveDetailScreen({super.key, required this.dive});

  static Route<void> route(Dive dive) {
    return MaterialPageRoute<void>(
      builder: (_) => DiveDetailScreen(dive: dive),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text(dive.place, style: const TextStyle(color: textColor)),
        backgroundColor: cardColor,
        iconTheme: const IconThemeData(color: accentColor),
        actions: [
          IconButton(
            key: const Key('diveDetailScreen_edit_iconButton'),
            icon: const Icon(Icons.edit, color: accentColor),
            onPressed: () {
              Navigator.of(context).push(AddDiveScreen.route(initialDive: dive));
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Date Header
          Center(
            child: Text(
              DateFormat('EEEE, dd MMMM yyyy').format(dive.date),
              style: const TextStyle(color: hintColor, fontSize: 18),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Media Gallery
          if (dive.photos.isNotEmpty) ...[
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dive.photos.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: hintColor.withOpacity(0.3)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildImage(dive.photos[index]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 3. Key Metrics
          _buildSectionTitle('Dive Data'),
          _buildDetailCard(
            children: [
              _DetailRow(icon: Icons.waves, label: 'Depth', value: '${dive.depth} m'),
              _DetailRow(icon: Icons.timer, label: 'Bottom Time', value: '${dive.time} min'),
            ],
          ),
          const SizedBox(height: 24),

          // 4. Location Preview
          if (dive.latitude != null && dive.longitude != null) ...[
            _buildSectionTitle('Location'),
            const SizedBox(height: 8),
            _buildMapPreview(),
            const SizedBox(height: 24),
          ],

          // 5. Environmental Conditions
          _buildSectionTitle('Conditions'),
          _buildDetailCard(
            children: [
              _DetailRow(icon: Icons.visibility, label: 'Visibility', value: dive.visibility),
              _DetailRow(icon: Icons.compare_arrows, label: 'Current', value: dive.current),
              _DetailRow(
                  icon: Icons.thermostat,
                  label: 'Water Temp',
                  value: dive.waterTemp != null ? '${dive.waterTemp} ºC' : null),
            ],
          ),
          const SizedBox(height: 24),

          // 6. Social & Notes
          _buildSectionTitle('Buddy & Notes'),
          _buildDetailCard(
            children: [
              _DetailRow(icon: Icons.person, label: 'Buddy', value: dive.buddy),
              _DetailRow(icon: Icons.subject, label: 'Notes', value: dive.notes, isMultiLine: true),
            ],
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  /// Renders images supporting Network URLs, Base64 strings, and Local Files.
  /// 
  /// Note: Base64 decoding is handled here to support the current Firestore implementation
  /// without external storage buckets. In a production app with heavy media, 
  /// this logic would delegate to a cached network image provider.
  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error, color: Colors.red)),
      );
    } else if (imagePath.startsWith('data:image')) {
      try {
        final base64String = imagePath.split(',').last;
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      } catch (e) {
        return const Center(child: Icon(Icons.broken_image, color: Colors.white54));
      }
    } else {
      return Image.file(File(imagePath), fit: BoxFit.cover);
    }
  }

  /// Renders a static Google Map (Lite Mode).
  /// 
  /// Lite Mode is chosen to reduce memory usage and API costs, 
  /// as the user does not need to interact with the map in this preview view.
  Widget _buildMapPreview() {
    final lat = dive.latitude!;
    final lng = dive.longitude!;
    final position = LatLng(lat, lng);

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hintColor.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          liteModeEnabled: true, // Performance optimization
          mapType: MapType.hybrid,
          initialCameraPosition: CameraPosition(
            target: position,
            zoom: 14,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('diveLocation'),
              position: position,
            ),
          },
          // Disable interaction for static preview
          zoomControlsEnabled: false,
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: accentColor, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDetailCard({required List<Widget> children}) {
    // Filter out null or empty rows to keep the UI clean
    final activeChildren = children.whereType<_DetailRow>().where((row) {
      return row.value != null && row.value!.isNotEmpty;
    }).toList();

    if (activeChildren.isEmpty) return const SizedBox.shrink();

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: activeChildren,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isMultiLine;

  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: hintColor, size: 20),
          const SizedBox(width: 16),
          Text(
            '$label:',
            style: const TextStyle(color: hintColor, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value!,
              style: const TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}