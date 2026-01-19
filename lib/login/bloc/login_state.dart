import 'package:equatable/equatable.dart';

/// Represents the execution status of the form submission.
enum FormStatus { initial, submissionInProgress, submissionSuccess, submissionFailure }

/// Manages the state of the Login form.
/// 
/// Extends [Equatable] to ensure efficient state comparison, preventing 
/// unnecessary rebuilds in the UI when the state hasn't actually changed.
class LoginState extends Equatable {
  final String username;
  final String password;
  final FormStatus formStatus;
  final String errorMessage;

  const LoginState({
    this.username = '',
    this.password = '',
    this.formStatus = FormStatus.initial,
    this.errorMessage = '',
  });

  /// Utility method to create a copy of the state with updated fields.
  /// Essential for immutable state management pattern.
  LoginState copyWith({
    String? username,
    String? password,
    FormStatus? formStatus,
    String? errorMessage,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      formStatus: formStatus ?? this.formStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [username, password, formStatus, errorMessage];
}