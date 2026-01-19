import 'package:equatable/equatable.dart';

enum FormStatus { initial, submissionInProgress, submissionSuccess, submissionFailure }

/// Represents the UI state for the Registration screen.
/// 
/// Extends [Equatable] to ensure efficient state comparisons by the BLoC,
/// preventing unnecessary rebuilds if the data hasn't changed.
class RegisterState extends Equatable {
  final String username;
  final String password;
  final FormStatus formStatus;
  final String errorMessage;

  const RegisterState({
    this.username = '',
    this.password = '',
    this.formStatus = FormStatus.initial,
    this.errorMessage = '',
  });

  /// Utility method to create a copy of the state with specific fields updated.
  /// Essential for immutable state management.
  RegisterState copyWith({
    String? username,
    String? password,
    FormStatus? formStatus,
    String? errorMessage,
  }) {
    return RegisterState(
      username: username ?? this.username,
      password: password ?? this.password,
      formStatus: formStatus ?? this.formStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [username, password, formStatus, errorMessage];
}