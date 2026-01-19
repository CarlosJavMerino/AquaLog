import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Enumeration defining the specific types of diving equipment managed by the application.
/// Used for categorization and sorting in the UI.
enum GearCategory {
  regulator,
  bcd, 
  computer,
  wetsuit, 
  mask,
  fins,
  tank,
  accessory,
  other
}

/// Domain entity representing a piece of diving gear.
/// 
/// Extends [Equatable] to facilitate value comparisons in BLoC state management
/// and testing.
class GearItem extends Equatable {
  final String id;
  final String userId;
  final String brand;       
  final String model;       
  final GearCategory category;
  final DateTime? purchaseDate;
  final DateTime? lastServiceDate;
  final int? serviceIntervalMonths; // Maintenance interval in months
  final String? imageUrl;   // URL from Google Custom Search or user upload

  const GearItem({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.category,
    this.purchaseDate,
    this.lastServiceDate,
    this.serviceIntervalMonths,
    this.imageUrl,
  });

  /// Computed property to determine if the equipment requires maintenance.
  /// 
  /// Returns [true] if the current date is past the calculated next service date.
  bool get needsService {
    if (lastServiceDate == null || serviceIntervalMonths == null) return false;
    final nextService = lastServiceDate!.add(Duration(days: serviceIntervalMonths! * 30));
    return DateTime.now().isAfter(nextService);
  }

  /// Serializes the entity to a JSON map for Firestore persistence.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'brand': brand,
      'model': model,
      'category': category.name, // Storing enum as String
      'purchaseDate': purchaseDate,
      'lastServiceDate': lastServiceDate,
      'serviceIntervalMonths': serviceIntervalMonths,
      'imageUrl': imageUrl,
    };
  }

  /// Factory constructor to reconstitute the entity from a Firestore DocumentSnapshot.
  factory GearItem.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    
    return GearItem(
      id: snap.id,
      userId: data['userId'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      // Safe Enum conversion: Fallback to 'other' if the string doesn't match
      category: GearCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => GearCategory.other,
      ),
      purchaseDate: (data['purchaseDate'] as Timestamp?)?.toDate(),
      lastServiceDate: (data['lastServiceDate'] as Timestamp?)?.toDate(),
      serviceIntervalMonths: data['serviceIntervalMonths'],
      imageUrl: data['imageUrl'],
    );
  }

  /// Creates a copy of this GearItem but with the given fields replaced with the new values.
  GearItem copyWith({
    String? brand,
    String? model,
    GearCategory? category,
    DateTime? purchaseDate,
    DateTime? lastServiceDate,
    int? serviceIntervalMonths,
    String? imageUrl,
  }) {
    return GearItem(
      id: id,
      userId: userId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      category: category ?? this.category,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      serviceIntervalMonths: serviceIntervalMonths ?? this.serviceIntervalMonths,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        brand,
        model,
        category,
        purchaseDate,
        lastServiceDate,
        serviceIntervalMonths,
        imageUrl,
      ];
}