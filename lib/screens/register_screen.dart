import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqualog/auth/repository/authrepository.dart';
import 'package:aqualog/register/bloc/register_bloc.dart';
import 'package:aqualog/register/bloc/register_event.dart';
import 'package:aqualog/register/bloc/register_state.dart';

// UI Constants
const Color primaryColor = Color(0xFF0A192F);
const Color accentColor = Color(0xFF48E3D4);
const Color textColor = Colors.white;
const Color hintColor = Colors.white54;

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const RegisterScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: BlocProvider(
            // Dependency Injection: Injecting Repository into the local BLoC
            create: (context) {
              return RegisterBloc(
                authRepository: RepositoryProvider.of<AuthRepository>(context),
              );
            },
            child: const _RegisterForm(),
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm();

  @override
  Widget build(BuildContext context) {
    // Reactive Feedback: Listening to state changes for side effects (Navigation/Snackbars)
    return BlocListener<RegisterBloc, RegisterState>(
      listenWhen: (previous, current) => previous.formStatus != current.formStatus,
      listener: (context, state) {
        if (state.formStatus == FormStatus.submissionSuccess) {
          Navigator.of(context).pop();
        }
        if (state.formStatus == FormStatus.submissionFailure) {
          FocusScope.of(context).unfocus();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.errorMessage)),
                  ],
                ),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Welcome to AquaLog',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Create a user profile to start logging',
            textAlign: TextAlign.center,
            style: TextStyle(color: hintColor, fontSize: 16),
          ),
          const SizedBox(height: 40),
          
          const _UsernameInput(),
          const SizedBox(height: 20),
          const _PasswordInput(),
          
          const SizedBox(height: 30),
          const _RegisterButton(),
        ],
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  const _UsernameInput();

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (val) {
        context.read<RegisterBloc>().add(RegisterUsernameChanged(val));
      },
      style: const TextStyle(color: textColor),
      keyboardType: TextInputType.text,
      decoration: _inputDecoration('Username', 'e.g. diver_pro'),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput();

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (password) =>
          context.read<RegisterBloc>().add(RegisterPasswordChanged(password)),
      obscureText: true,
      style: const TextStyle(color: textColor),
      decoration: _inputDecoration('Password', 'Min. 6 characters'),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  const _RegisterButton();
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
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
                     context.read<RegisterBloc>().add(const RegisterSubmitted());
                  }
                },
                child: const Text(
                  'Sign Up',
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
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white24),
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