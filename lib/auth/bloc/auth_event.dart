import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Base class for all authentication events.
/// Extends [Equatable] to facilitate event comparison in tests and BLoC transitions.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event notified when the authentication state changes in the repository.
/// 
/// This is typically emitted by the repository's Stream<User?> listener
/// whenever a user logs in, logs out, or the token refreshes.
class AuthUserChanged extends AuthEvent {
  final User? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

/// Event triggered by the UI when the user requests to sign out.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}