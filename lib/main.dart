import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqualog/auth/bloc/auth_bloc.dart';
import 'package:aqualog/auth/bloc/auth_state.dart';
import 'package:aqualog/auth/repository/authrepository.dart';
import 'package:aqualog/screens/home_screen.dart';
import 'package:aqualog/screens/login_screen.dart';
import 'package:aqualog/screens/splash_screen.dart';
import 'package:aqualog/firebase_options.dart';
import 'package:aqualog/dives/repository/dive_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );

  final authRepository = AuthRepository();

  runApp(AquaLogApp(authRepository: authRepository));
}

class AquaLogApp extends StatelessWidget {
  final AuthRepository _authRepository;

  const AquaLogApp({super.key, required AuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Widget build(BuildContext context) {
    // PROFESSIONAL NOTE: Using MultiRepositoryProvider for Dependency Injection.
    // This allows any widget in the tree to access repositories via context.read(),
    // decoupling the UI from the data implementation.
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider(create: (context) => DiveRepository()),
      ],
      child: BlocProvider(
        // The AuthBloc is global because the auth state affects the whole app lifecycle
        create: (_) => AuthBloc(authRepository: _authRepository),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaLog',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF0A192F),
        scaffoldBackgroundColor: const Color(0xFF0A192F),
        // Defining a global color scheme ensures UI consistency
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0A192F),
          secondary: Color(0xFF48E3D4),
        ),
      ),
      // Routing Logic:
      // Instead of named routes, we use a Builder to reactively switch screens
      // based on the AuthBloc state. This handles auto-login and logout gracefully.
      home: Builder(builder: (context) {
        final status = context.select((AuthBloc bloc) => bloc.state.status);
        
        switch (status) {
          case AuthStatus.authenticated:
            return const HomeScreen();
          case AuthStatus.unauthenticated:
            return const LoginScreen();
          case AuthStatus.unknown:
          default:
            return const SplashScreen();
        }
      }),
    );
  }
}