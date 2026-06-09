import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aqualog/auth/repository/authrepository.dart';
import 'register_event.dart';
import 'register_state.dart';

/// Manages the state of the user registration flow.
/// 
/// Handles form input validation and communication with the [AuthRepository]
/// to create new user accounts.
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;

  RegisterBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const RegisterState()) {
    on<RegisterUsernameChanged>(_onUsernameChanged);
    on<RegisterPasswordChanged>(_onPasswordChanged);
    on<RegisterSubmitted>(_onSubmitted);
  }

  void _onUsernameChanged(RegisterUsernameChanged event, Emitter<RegisterState> emit) {
    emit(state.copyWith(username: event.username));
  }

  void _onPasswordChanged(RegisterPasswordChanged event, Emitter<RegisterState> emit) {
    emit(state.copyWith(password: event.password));
  }

  Future<void> _onSubmitted(RegisterSubmitted event, Emitter<RegisterState> emit) async {
    if (state.formStatus == FormStatus.submissionInProgress) return;
    emit(state.copyWith(formStatus: FormStatus.submissionInProgress));
    try {
      // USAMOS EL EMAIL REAL LIMPIO
      await _authRepository.signUp(
        email: state.username.trim(),
        password: state.password,
      );
      emit(state.copyWith(formStatus: FormStatus.submissionSuccess));
    } on FirebaseAuthException catch (e) {
      // Mapping Firebase error codes to user-friendly messages
      String readableError;
      switch (e.code) {
        case 'email-already-in-use':
          readableError = 'This username is already taken.';
          break;
        case 'invalid-email':
          readableError = 'Invalid username format.';
          break;
        case 'weak-password':
          readableError = 'The password is too weak. Use at least 6 characters.';
          break;
        default:
          readableError = 'Registration error: ${e.message}';
      }

      emit(state.copyWith(
        formStatus: FormStatus.submissionFailure,
        errorMessage: readableError,
      ));
    } catch (_) {
      emit(state.copyWith(
        formStatus: FormStatus.submissionFailure,
        errorMessage: 'An unexpected error occurred.',
      ));
    }
  }
}