import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when the username input changes.
class LoginUsernameChanged extends LoginEvent {
  final String username;
  const LoginUsernameChanged(this.username);

  @override
  List<Object> get props => [username];
}

/// Event triggered when the password input changes.
class LoginPasswordChanged extends LoginEvent {
  final String password;
  const LoginPasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

/// Event triggered when the form is submitted.
class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}