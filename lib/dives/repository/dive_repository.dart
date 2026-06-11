import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/dive_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Repository responsible for managing Dive data interactions with Firebase Firestore
/// y la subida de imágenes a través de la API gratuita de ImgBB.
class DiveRepository {
  final CollectionReference _divesCollection = FirebaseFirestore.instance.collection('dives');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Cliente HTTP para enviar las fotos
  final Dio _dio = Dio();
  
  // TODO: Reemplaza esto por tu API Key real de ImgBB
  final String _imgbbApiKey = dotenv.get('IMGBB_API_KEY');

  /// Retrieves a real-time stream of the current user's dives.
  Stream<List<Dive>> getDives() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _divesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      // Maps the Firestore documents to domain models
      return snapshot.docs.map((doc) => Dive.fromSnapshot(doc)).toList();
    });
  }

  /// Sube las imágenes físicas a ImgBB y devuelve una lista con las URLs web
  Future<List<String>> uploadImages(List<String> imagePaths) async {
    List<String> uploadedUrls = [];

    for (String path in imagePaths) {
      try {
        final file = File(path);
        if (!await file.exists()) continue;

        // 1. Preparamos el archivo para enviarlo a la API
        String fileName = file.path.split('/').last;
        FormData formData = FormData.fromMap({
          'key': _imgbbApiKey,
          'image': await MultipartFile.fromFile(file.path, filename: fileName),
        });

        // 2. Hacemos la petición POST a ImgBB
        final response = await _dio.post(
          'https://api.imgbb.com/1/upload',
          data: formData,
          options: Options(receiveTimeout: const Duration(seconds: 5), sendTimeout: const Duration(seconds: 5))
        );

        // 3. Si la subida es exitosa, extraemos la URL y la guardamos
        if (response.statusCode == 200 && response.data['success'] == true) {
          uploadedUrls.add(response.data['data']['url']); 
        } else {
          uploadedUrls.add(path);
        }
      } catch (e) {
        print('Modo Offline o error de red. Guardando ruta local: $path');
        // Si no hay red, guardamos la ruta local en la base de datos
        uploadedUrls.add(path);
      }
    }
    return uploadedUrls;
  }

  /// Persists a new dive to the database.
  Future<void> addDive({
    required String place,
    required int depth,
    required int time,
    required DateTime date,
    String? notes,
    String? buddy,
    String? visibility,
    String? current,
    int? waterTemp,
    List<String>? photos,
    double? latitude,
    double? longitude,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Unauthenticated: Cannot create a dive without a user session.');
    }

    try {
      await _divesCollection.add({
        'userId': userId,
        'place': place,
        'depth': depth,
        'time': time,
        'date': Timestamp.fromDate(date),
        'notes': notes,
        'buddy': buddy,
        'visibility': visibility,
        'current': current,
        'waterTemp': waterTemp,
        'photos': photos ?? [],
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      // Rethrow allows the BLoC to catch and handle the specific UI error state
      rethrow;
    }
  }

  Future<void> updateDive(Dive dive) async {
    try {
      await _divesCollection.doc(dive.id).update(dive.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDive(String diveId) async {
    try {
      await _divesCollection.doc(diveId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene un Stream en tiempo real de una única inmersión por su ID
  Stream<Dive?> getDiveStream(String diveId) {
    return _divesCollection.doc(diveId).snapshots().map((snap) {
      if (!snap.exists) return null; // Por si se borra la inmersión
      return Dive.fromSnapshot(snap);
    });
  }
}