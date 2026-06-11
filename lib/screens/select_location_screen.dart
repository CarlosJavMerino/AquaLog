import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// UI Constants
const Color primaryColor = Color(0xFF0A192F);
const Color accentColor = Color(0xFF48E3D4);
const Color cardColor = Color(0xFF112240);
const Color textColor = Colors.white;

/// Screen that allows the user to select a geographical point on the map.
/// Returns a [LatLng] object to the calling screen.
class SelectLocationScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const SelectLocationScreen({super.key, this.initialLocation});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  /// Requests location permissions and moves the camera to the user's current position.
  Future<void> _locateUser() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();

    setState(() {
      _pickedLocation = LatLng(position.latitude, position.longitude);
    });
    
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location', style: TextStyle(color: textColor)),
        backgroundColor: cardColor,
        iconTheme: const IconThemeData(color: accentColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            // Disable button if no location is selected
            onPressed: _pickedLocation == null
                ? null
                : () {
                    Navigator.of(context).pop(_pickedLocation);
                  },
          ),
        ],
      ),
      body: GoogleMap(
        // Technical Note: MapType.normal is required to apply custom JSON styles. 
        // Hybrid/Satellite modes ignore styling.
        mapType: MapType.normal, 
        
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation ?? const LatLng(40.4167, -3.7037), // Default: Madrid
          zoom: widget.initialLocation != null ? 15 : 5,
        ),
        
        onMapCreated: (controller) {
          _mapController = controller;
          
          // Apply custom dark theme
          controller.setMapStyle(_mapStyle);
          
          // If creating a new entry (no initial location), auto-locate the user
          if (widget.initialLocation == null) {
            _locateUser();
          }
        },

        onTap: (LatLng position) {
          setState(() {
            _pickedLocation = position;
          });
        },
        
        markers: _pickedLocation == null
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('picked'),
                  position: _pickedLocation!,
                  // Cyan marker to contrast with the dark map theme
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
                ),
              },
        
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}

// Custom Map Style (Deep Ocean Theme)
// Removes irrelevant landmarks and applies a dark blue palette.
const String _mapStyle = '''
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