import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqualog/auth/repository/authrepository.dart';
import '../login/bloc/login_bloc.dart';
import '../login/bloc/login_event.dart';
import '../login/bloc/login_state.dart';
import 'package:aqualog/screens/register_screen.dart';

// UI Constants
const Color primaryColor = Color(0xFF0A192F);
const Color accentColor = Color(0xFF48E3D4);
const Color textColor = Colors.white;
const Color hintColor = Colors.white54;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const LoginScreen());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        child: Padding(
          // Centering content vertically for better UX on different screen sizes
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
          child: BlocProvider(
            create: (context) {
              return LoginBloc(
                authRepository: RepositoryProvider.of<AuthRepository>(context),
              );
            },
            child: const _LoginForm(),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      // Optimization: Only listen when form status changes to avoid unnecessary checks
      listenWhen: (previous, current) => previous.formStatus != current.formStatus,
      listener: (context, state) {
        if (state.formStatus == FormStatus.submissionFailure) {
          FocusScope.of(context).unfocus(); // Hide keyboard on error
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.errorMessage)),
                  ],
                ),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 4),
              ),
            );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'AquaLog',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 60),
          
          const _UsernameInput(), 
          const SizedBox(height: 20),
          const _PasswordInput(),
          
          const SizedBox(height: 30),
          const _LoginButton(),
          const SizedBox(height: 20),
          
          TextButton(
            onPressed: () {
              Navigator.of(context).push(RegisterScreen.route());
            },
            child: const Text(
              'Create new account',
              style: TextStyle(color: accentColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsernameInput extends StatefulWidget {
  const _UsernameInput();
  @override
  State<_UsernameInput> createState() => _UsernameInputState();
}

class _UsernameInputState extends State<_UsernameInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<LoginBloc>().state.username);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (val) => context.read<LoginBloc>().add(LoginUsernameChanged(val)),
      style: const TextStyle(color: textColor),
      keyboardType: TextInputType.text,
      decoration: _inputDecoration('Username', 'e.g. diver_master'),
    );
  }
}

class _PasswordInput extends StatefulWidget {
  const _PasswordInput();
  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<LoginBloc>().state.password);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (pass) => context.read<LoginBloc>().add(LoginPasswordChanged(pass)),
      obscureText: true,
      style: const TextStyle(color: textColor),
      decoration: _inputDecoration('Password', ''),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.formStatus != current.formStatus,
      builder: (context, state) {
        return state.formStatus == FormStatus.submissionInProgress
            ? const Center(child: CircularProgressIndicator(color: accentColor))
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (state.formStatus != FormStatus.submissionInProgress) {
                     FocusScope.of(context).unfocus();
                     context.read<LoginBloc>().add(const LoginSubmitted());
                  }
                },
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
      },
    );
  }
}

// Helper method for consistent styling
InputDecoration _inputDecoration(String label, String hint) {
  return InputDecoration(
    labelText: label,
    hintText: hint.isNotEmpty ? hint : null,
    labelStyle: const TextStyle(color: hintColor),
    filled: true,
    fillColor: primaryColor.withOpacity(0.5),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: hintColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: accentColor, width: 2),
    ),
  );
}