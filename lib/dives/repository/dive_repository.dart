import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/dive_model.dart';

/// Repository responsible for managing Dive data interactions with Firebase Firestore.
/// 
/// Follows the Repository pattern to abstract the data source implementation 
/// from the business logic.
class DiveRepository {
  final CollectionReference _divesCollection = FirebaseFirestore.instance.collection('dives');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retrieves a real-time stream of the current user's dives.
  /// 
  /// Returns an empty stream if no user is logged in.
  /// Ordered by date descending (newest first).
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

  /// Processes local images and converts them to Base64 strings.
  /// 
  /// ARCHITECTURAL DECISION:
  /// For this MVP/Portfolio project, images are stored as Base64 strings directly 
  /// in the Firestore document to avoid the complexity and cost of Firebase Storage.
  /// 
  /// Note: In a production environment with high-res images, this should be refactored 
  /// to upload files to a bucket (S3/Firebase Storage) and store only URLs here.
  /// Additionally, image compression should be handled in a separate Isolate.
  Future<List<String>> uploadImages(List<String> imagePaths) async {
    List<String> base64Images = [];

    for (String path in imagePaths) {
      try {
        final file = File(path);
        if (!await file.exists()) continue;

        final bytes = await file.readAsBytes();
        String base64String = base64Encode(bytes);
        
        // Appends the data URI scheme for easy rendering in Flutter
        base64Images.add('data:image/jpeg;base64,$base64String');
      } catch (e) {
        // Logging the error internally, but allowing the process to continue for other images
        print('Error encoding image $path: $e');
      }
    }
    return base64Images;
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
}