import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aqualog/auth/bloc/auth_bloc.dart';
import 'package:aqualog/auth/bloc/auth_event.dart';
import 'package:aqualog/auth/bloc/auth_state.dart';
import 'package:aqualog/auth/repository/authrepository.dart';

// 1. Creamos las clases falsas (Mocks)
class MockAuthRepository extends Mock implements AuthRepository {}
class MockUser extends Mock implements User {} // Usuario falso de Firebase

void main() {
  group('AuthBloc Tests', () {
    late MockAuthRepository authRepository;
    late AuthBloc authBloc;

    setUp(() {
      authRepository = MockAuthRepository();
      
      // Le decimos al mock qué devolver cuando la app pida el "Stream" del usuario.
      // Empezamos con un stream vacío (usuario no logueado).
      when(() => authRepository.user).thenAnswer((_) => Stream.value(null));
      
      authBloc = AuthBloc(authRepository: authRepository);
    });

    tearDown(() {
      authBloc.close();
    });

    test('El estado inicial debe ser unknown', () {
      expect(authBloc.state.status, AuthStatus.unknown);
    });

    // 2. Usamos blocTest para probar transiciones de estado
    blocTest<AuthBloc, AuthState>(
      'Emite [authenticated] cuando un usuario inicia sesión',
      build: () => authBloc,
      act: (bloc) {
        final mockUser = MockUser(); // Creamos un usuario falso
        bloc.add(AuthUserChanged(mockUser)); // Simulamos que Firebase nos lo envió
      },
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.authenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'Llama a logOut en el repositorio cuando se solicita salir',
      build: () {
        // Le decimos al mock que no haga nada al intentar cerrar sesión
        when(() => authRepository.logOut()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      verify: (_) {
        // Verificamos que el Bloc efectivamente le ordenó al repositorio salir
        verify(() => authRepository.logOut()).called(1);
      },
    );
  });
}