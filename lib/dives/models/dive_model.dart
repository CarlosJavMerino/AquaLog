import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Domain model representing a Dive log entry.
/// 
/// Extends [Equatable] to allow value comparison instead of reference comparison,
/// which is crucial for BLoC state changes detection.
class Dive extends Equatable {
  final String id;
  final String userId;
  final String place;
  final int depth;
  final int time;
  final DateTime date;
  final String? notes;
  final List<String> photos; // Stores Base64 strings or URLs
  
  // Optional environmental & social data
  final String? buddy;
  final String? visibility;
  final String? current;
  final int? waterTemp;
  final double? latitude;
  final double? longitude;

  const Dive({
    required this.id,
    required this.userId,
    required this.place,
    required this.depth,
    required this.time,
    required this.date,
    this.notes,
    this.buddy,
    this.visibility,
    this.current,
    this.waterTemp,
    this.photos = const [],
    this.latitude,
    this.longitude,
  });

  /// Converts the domain model to a JSON map for Firestore persistence.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'place': place,
      'depth': depth,
      'time': time,
      'date': Timestamp.fromDate(date), // Firestore requires Timestamp
      'notes': notes,
      'buddy': buddy,
      'visibility': visibility,
      'current': current,
      'waterTemp': waterTemp,
      'photos': photos,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Factory constructor to create a Dive from a Firestore Document.
  factory Dive.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    
    return Dive(
      id: snap.id,
      userId: data['userId'] ?? '',
      place: data['place'] ?? 'Unknown',
      depth: data['depth'] ?? 0,
      time: data['time'] ?? 0,
      // Handle the conversion from Firestore Timestamp back to Dart DateTime
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'],
      buddy: data['buddy'],
      visibility: data['visibility'],
      current: data['current'],
      waterTemp: data['waterTemp'],
      photos: List<String>.from(data['photos'] ?? []),
      latitude: data['latitude']?.toDouble(), 
      longitude: data['longitude']?.toDouble(),
    );
  }
  
  @override
  List<Object?> get props => [
        id, userId, place, depth, time, date, notes,
        buddy, visibility, current, waterTemp, photos, latitude, longitude
      ];
}