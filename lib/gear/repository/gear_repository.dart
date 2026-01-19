import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gear_model.dart';

/// Repository responsible for managing Gear (equipment) data in Firestore.
///
/// Implements standard CRUD operations and handles data ownership verification via Firebase Auth.
class GearRepository {
  final CollectionReference _gearCollection;
  final FirebaseAuth _auth;

  /// Constructor allows dependency injection for testing purposes.
  /// Defaults to singleton instances if not provided.
  GearRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _gearCollection = (firestore ?? FirebaseFirestore.instance).collection('gear'),
        _auth = auth ?? FirebaseAuth.instance;

  /// Retrieves a real-time stream of gear items for the current user.
  ///
  /// Items are sorted by [category] to facilitate grouped UI rendering.
  /// Returns an empty stream if the user is unauthenticated.
  Stream<List<GearItem>> getGear() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _gearCollection
        .where('userId', isEqualTo: userId)
        .orderBy('category') 
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => GearItem.fromSnapshot(doc)).toList();
    });
  }

  /// Persists a new gear item to the database.
  ///
  /// Throws an [Exception] if no user is currently logged in.
  Future<void> addGear(GearItem gear) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Unauthenticated: Cannot add gear.');

    // Ensure the data belongs to the current user before saving
    // Note: The 'id' in the model is ignored here as Firestore generates a new one.
    final data = gear.toJson();
    data['userId'] = userId; 

    await _gearCollection.add(data);
  }

  /// Updates an existing gear item.
  ///
  /// Note: Firestore Security Rules should enforce that users can only update their own documents.
  Future<void> updateGear(GearItem gear) async {
    await _gearCollection.doc(gear.id).update(gear.toJson());
  }

  /// Removes a gear item from the inventory.
  Future<void> deleteGear(String gearId) async {
    await _gearCollection.doc(gearId).delete();
  }
}