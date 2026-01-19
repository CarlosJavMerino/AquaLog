import 'package:equatable/equatable.dart';
import '../models/gear_model.dart';

enum GearFormStatus { initial, submissionInProgress, submissionSuccess, submissionFailure }

/// Represents the immutable state of the 'Add/Edit Gear' form.
/// 
/// Uses [Equatable] to ensure efficient state comparison by the BLoC,
/// preventing unnecessary UI rebuilds if fields haven't changed.
class AddGearState extends Equatable {
  final String brand;
  final String model;
  final GearCategory category;
  final DateTime? purchaseDate;
  final DateTime? lastServiceDate;
  final int? serviceIntervalMonths;
  
  /// URL of the image, typically populated via the Google Search Service integration.
  final String imageUrl; 
  
  final GearFormStatus status;
  final String errorMessage;

  const AddGearState({
    this.brand = '',
    this.model = '',
    this.category = GearCategory.other,
    this.purchaseDate,
    this.lastServiceDate,
    this.serviceIntervalMonths = 12, // Defaults to annual maintenance
    this.imageUrl = '',
    this.status = GearFormStatus.initial,
    this.errorMessage = '',
  });

  AddGearState copyWith({
    String? brand,
    String? model,
    GearCategory? category,
    DateTime? purchaseDate,
    DateTime? lastServiceDate,
    int? serviceIntervalMonths,
    String? imageUrl,
    GearFormStatus? status,
    String? errorMessage,
  }) {
    return AddGearState(
      brand: brand ?? this.brand,
      model: model ?? this.model,
      category: category ?? this.category,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      serviceIntervalMonths: serviceIntervalMonths ?? this.serviceIntervalMonths,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        brand, model, category, purchaseDate, lastServiceDate, 
        serviceIntervalMonths, imageUrl, status, errorMessage
      ];
}