import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart'; 
import '../dives/models/dive_model.dart';
import 'dive_detail_screen.dart';

// UI Constants
const Color primaryColor = Color(0xFF0A192F);
const Color cardColor = Color(0xFF112240);
const Color accentColor = Color(0xFF48E3D4);
const Color textColor = Colors.white;
const Color hintColor = Colors.white54;

/// A screen that visualizes all recorded dives on an interactive Google Map.
/// 
/// This widget handles:
/// 1. Mapping domain objects [Dive] to UI [Marker]s.
/// 2. Custom styling of the Google Map (Dark Mode / Deep Ocean).
/// 3. Displaying a modal summary when a marker is tapped.
class GlobalMapScreen extends StatefulWidget {
  final List<Dive> dives;

  const GlobalMapScreen({super.key, required this.dives});

  @override
  State<GlobalMapScreen> createState() => _GlobalMapScreenState();
}

class _GlobalMapScreenState extends State<GlobalMapScreen> {
  late Set<Marker> _markers;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _markers = _createMarkers();
  }

  /// Lifecycle method to handle updates from the parent widget (BLoC).
  /// If the list of dives changes (e.g., sync update, deletion), 
  /// we must regenerate the markers to reflect the new state.
  @override
  void didUpdateWidget(GlobalMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dives != widget.dives) {
      setState(() {
        _markers = _createMarkers();
      });
    }
  }

  Set<Marker> _createMarkers() {
    final markers = <Marker>{};

    for (final dive in widget.dives) {
      if (dive.latitude != null && dive.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(dive.id),
            position: LatLng(dive.latitude!, dive.longitude!),
            // Styling the marker to match the app's accent color (Cyan)
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
            onTap: () {
              _showDivePreview(context, dive);
            },
          ),
        );
      }
    }
    return markers;
  }

Widget _buildImage(String imagePath) {
    // Si la ruta empieza por http, es una URL de ImgBB (foto guardada)
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        // Mostramos un indicador de carga mientras la imagen baja de internet
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: accentColor),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.white54),
        ),
      );
    } else {
      // Fallback: Si no empieza por http, asumimos que es una ruta local del teléfono
      // (Por ejemplo, cuando previsualizas antes de guardar)
      return Image.file(File(imagePath), fit: BoxFit.cover);
    }
  }

  /// Displays a summary BottomSheet when a marker is clicked.
  void _showDivePreview(BuildContext context, Dive dive) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: hintColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dive.place,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(dive.date),
                    style: const TextStyle(color: accentColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Image Carousel
              Expanded(
                child: dive.photos.isNotEmpty
                    ? ListView.builder(
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
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: hintColor.withOpacity(0.3)),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_camera_back, size: 40, color: hintColor),
                              SizedBox(height: 8),
                              Text("No photos available", style: TextStyle(color: hintColor)),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              
              // Navigation Action
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(DiveDetailScreen.route(dive));
                },
                child: const Text(
                  'View Full Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal, // Required 'normal' to apply custom JSON styles
      initialCameraPosition: const CameraPosition(
        target: LatLng(40.4167, -3.7037), // Default: Madrid
        zoom: 3,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapToolbarEnabled: false, 
      // Padding ensures Google logo/buttons aren't hidden by the BottomNavigationBar
      padding: const EdgeInsets.only(bottom: 60), 
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        controller.setMapStyle(_deepOceanMapStyle);
      },
    );
  }
}

/// Custom JSON Map Style.
/// Removes irrelevant road details and applies a dark blue theme ("Deep Ocean").
const String _deepOceanMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      { "color": "#1d2c4d" }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#8ec3b9" }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      { "color": "#1a3646" }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#4b6878" }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#334e87" }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      { "color": "#023e58" }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      { "color": "#283d6a" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      { "visibility": "simplified" },
      { "color": "#304a7d" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      { "color": "#0e1626" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#4e6d70" }
    ]
  }
]
''';