import 'package:equatable/equatable.dart';

/// Base class for all events related to the Registration feature.
abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when the username input field changes.
class RegisterUsernameChanged extends RegisterEvent {
  final String username;
  const RegisterUsernameChanged(this.username);

  @override
  List<Object> get props => [username];
}

/// Event triggered when the password input field changes.
class RegisterPasswordChanged extends RegisterEvent {
  final String password;
  const RegisterPasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

/// Event triggered when the user taps the registration submission button.
class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted();
}