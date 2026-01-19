import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:aqualog/auth/repository/authrepository.dart';
import 'package:aqualog/auth/bloc/auth_event.dart';
import 'package:aqualog/auth/bloc/auth_state.dart';

/// Manages the authentication state of the application.
/// 
/// It listens to the Firebase Auth Stream and converts it into application states
/// (Authenticated, Unauthenticated, Unknown).
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unknown()) {
    
    // Subscribe to the repository's user stream immediately upon creation
    _userSubscription = _authRepository.user.listen((user) {
      add(AuthUserChanged(user));
    });

    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    // Determine state based on the presence of a user object
    if (event.user != null) {
      emit(AuthState.authenticated(event.user!));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }
  
  void _onAuthLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) {
    // We don't manually emit unauthenticated here.
    // Calling logOut() triggers the stream, which fires AuthUserChanged,
    // which eventually updates the state. Single Source of Truth.
    _authRepository.logOut(); 
  }
  
  @override
  Future<void> close() {
    // Prevents memory leaks by cancelling the subscription when the Bloc is destroyed
    _userSubscription?.cancel();
    return super.close();
  }
}