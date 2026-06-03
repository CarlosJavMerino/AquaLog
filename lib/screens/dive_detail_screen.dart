import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../dives/models/dive_model.dart';
import 'add_dive_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../dives/repository/dive_repository.dart';

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
    // Envolvemos la pantalla en un StreamBuilder que escucha a Firestore
    return StreamBuilder<Dive?>(
      // Accedemos a la función que acabamos de crear en el repositorio
      stream: RepositoryProvider.of<DiveRepository>(context).getDiveStream(dive.id),
      initialData: dive, // Usamos la inmersión original para evitar un parpadeo de carga
      builder: (context, snapshot) {
        
        // Si por algún motivo no hay datos (ej. se borró)
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            backgroundColor: primaryColor,
            body: Center(child: CircularProgressIndicator(color: accentColor)),
          );
        }

        // Esta es nuestra inmersión ACTUALIZADA en tiempo real
        final currentDive = snapshot.data!;

        return Scaffold(
          backgroundColor: primaryColor,
          appBar: AppBar(
            title: Text(currentDive.place, style: const TextStyle(color: textColor)),
            backgroundColor: cardColor,
            iconTheme: const IconThemeData(color: accentColor),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: accentColor),
                onPressed: () {
                  // Le pasamos la inmersión actualizada al formulario
                  Navigator.of(context).push(AddDiveScreen.route(initialDive: currentDive));
                },
              )
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 1. FECHA
              Center(
                child: Text(
                  DateFormat('EEEE, dd MMMM yyyy').format(currentDive.date),
                  style: const TextStyle(color: hintColor, fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),

              // 2. GALERÍA DE FOTOS (Actualizada con zoom)
              if (currentDive.photos.isNotEmpty) ...[
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: currentDive.photos.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showFullScreenImage(context, currentDive.photos[index]),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: hintColor.withOpacity(0.3)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildImage(currentDive.photos[index]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 3. PARÁMETROS PRINCIPALES
              _buildSectionTitle('Datos de la Inmersión'),
              _buildDetailCard(
                children: [
                  _DetailRow(icon: Icons.waves, label: 'Profundidad', value: '${currentDive.depth} m'),
                  _DetailRow(icon: Icons.timer, label: 'Tiempo', value: '${currentDive.time} min'),
                ],
              ),
              const SizedBox(height: 24),

              // 4. UBICACIÓN (MAPA ESTÁTICO)
              if (currentDive.latitude != null && currentDive.longitude != null) ...[
                _buildSectionTitle('Ubicación'),
                const SizedBox(height: 8),
                _buildMapPreview(currentDive.latitude!, currentDive.longitude!), // Actualizado abajo
                const SizedBox(height: 24),
              ],

              // 5. CONDICIONES
              _buildSectionTitle('Condiciones'),
              _buildDetailCard(
                children: [
                  _DetailRow(icon: Icons.visibility, label: 'Visibilidad', value: currentDive.visibility),
                  _DetailRow(icon: Icons.compare_arrows, label: 'Corriente', value: currentDive.current),
                  _DetailRow(
                      icon: Icons.thermostat,
                      label: 'Temperatura',
                      value: currentDive.waterTemp != null ? '${currentDive.waterTemp} ºC' : null),
                ],
              ),
              const SizedBox(height: 24),

              // 6. COMPAÑERO Y NOTAS
              _buildSectionTitle('Notas y Compañía'),
              _buildDetailCard(
                children: [
                  _DetailRow(icon: Icons.person, label: 'Compañero', value: currentDive.buddy),
                  _DetailRow(icon: Icons.subject, label: 'Notas', value: currentDive.notes, isMultiLine: true),
                ],
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
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

  void _showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero, // Para que ocupe toda la pantalla
        child: Stack(
          alignment: Alignment.center,
          children: [
            // El widget mágico para hacer Zoom
            InteractiveViewer(
              panEnabled: true, // Permitir mover la foto
              minScale: 1.0,
              maxScale: 4.0,    // Zoom máximo de 4x
              child: _buildImage(imagePath),
            ),
            // Botón de cerrar en la esquina superior derecha
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renders a static Google Map (Lite Mode).
  /// 
  /// Lite Mode is chosen to reduce memory usage and API costs, 
  /// as the user does not need to interact with the map in this preview view.
  Widget _buildMapPreview(double lat, double lng) {
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