import 'package:firebase_auth/firebase_auth.dart';

/// Repository responsible for abstracting authentication logic via Firebase Auth.
/// 
/// This class isolates the external auth provider dependency, making the 
/// business logic easier to test and maintain.
class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  /// Dependency injection via constructor allows for mocking [FirebaseAuth] during tests.
  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Exposes a stream of [User] objects which emits every time the 
  /// authentication state changes (e.g., sign in, sign out).
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges();
  }

  /// Creates a new user account with email and password.
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Rethrowing allows the BLoC to catch specific FirebaseExceptions
      // and map them to user-friendly error messages.
      rethrow;
    }
  }

  /// Authenticates an existing user.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}