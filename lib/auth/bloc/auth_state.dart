import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Defines the possible authentication states of the application.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Represents the state of the authentication flow.
///
/// Extends [Equatable] to ensure efficient state comparisons, preventing
/// unnecessary rebuilds if the state hasn't effectively changed.
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;

  /// Private constructor to ensure state instances are created 
  /// only via the specific named constructors below.
  const AuthState._({
    this.status = AuthStatus.unknown,
    this.user,
  });

  /// Initial state when the application launches and the auth check hasn't completed.
  const AuthState.unknown() : this._();

  /// State representing a successfully logged-in user.
  const AuthState.authenticated(User user)
      : this._(status: AuthStatus.authenticated, user: user);

  /// State representing a logged-out or non-authenticated session.
  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  @override
  List<Object?> get props => [status, user];
}