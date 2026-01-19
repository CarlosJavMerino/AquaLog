import 'package:equatable/equatable.dart';
import '../models/gear_model.dart';
import '../models/gear_search_result.dart';

abstract class AddGearEvent extends Equatable {
  const AddGearEvent();
  @override
  List<Object?> get props => [];
}

// --- Field Modification Events ---

class AddGearBrandChanged extends AddGearEvent {
  final String brand;
  const AddGearBrandChanged(this.brand);
  @override
  List<Object?> get props => [brand];
}

class AddGearModelChanged extends AddGearEvent {
  final String model;
  const AddGearModelChanged(this.model);
  @override
  List<Object?> get props => [model];
}

class AddGearCategoryChanged extends AddGearEvent {
  final GearCategory category;
  const AddGearCategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
}

class AddGearPurchaseDateChanged extends AddGearEvent {
  final DateTime date;
  const AddGearPurchaseDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class AddGearServiceDateChanged extends AddGearEvent {
  final DateTime date;
  const AddGearServiceDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class AddGearIntervalChanged extends AddGearEvent {
  final int months;
  const AddGearIntervalChanged(this.months);
  @override
  List<Object?> get props => [months];
}

// --- Action Events ---

/// Triggered when a user selects a search result (from Google API)
/// to auto-populate the form fields.
class AddGearAutoFilled extends AddGearEvent {
  final GearSearchResult result;
  const AddGearAutoFilled(this.result);
  @override
  List<Object?> get props => [result];
}

class AddGearSubmitted extends AddGearEvent {
  const AddGearSubmitted();
}