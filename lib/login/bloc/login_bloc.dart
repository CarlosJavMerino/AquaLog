import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aqualog/auth/repository/authrepository.dart';
import 'login_event.dart';
import 'login_state.dart';

/// Manages the state of the Login form.
/// 
/// Handles input validation and interacts with the [AuthRepository] to perform
/// the sign-in operation.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
  }

  void _onUsernameChanged(LoginUsernameChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(username: event.username));
  }

  void _onPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(password: event.password));
  }

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    // Prevent submission if already in progress
    if (state.formStatus == FormStatus.submissionInProgress) return;

    emit(state.copyWith(formStatus: FormStatus.submissionInProgress));
    
    try {
      // IMPLEMENTATION DETAIL:
      // Firebase Auth requires an email address, but the UI asks for a "Username".
      // We append a pseudo-domain to the input to satisfy the email format requirement
      // while keeping the user experience focused on usernames.
      final formattedEmail = '${state.username.trim()}@aqualog.app';

      await _authRepository.logInWithEmailAndPassword(
        email: formattedEmail,
        password: state.password,
      );
      
      emit(state.copyWith(formStatus: FormStatus.submissionSuccess));
      
    } on FirebaseAuthException catch (e) {
      // Map technical Firebase email errors to user-friendly username errors
      String readableError;
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-email':
          readableError = 'Usuario no encontrado.';
          break;
        case 'wrong-password':
          readableError = 'Contraseña incorrecta.';
          break;
        case 'user-disabled':
          readableError = 'Cuenta deshabilitada.';
          break;
        case 'too-many-requests':
          readableError = 'Demasiados intentos. Por favor espera.';
          break;
        default:
          readableError = 'Error de autenticación: ${e.message}';
      }

      emit(state.copyWith(
        formStatus: FormStatus.submissionFailure,
        errorMessage: readableError,
      ));
      
    } catch (e) {
      emit(state.copyWith(
        formStatus: FormStatus.submissionFailure,
        errorMessage: 'Error inesperado: $e',
      ));
    }
  }
}