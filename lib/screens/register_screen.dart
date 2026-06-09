import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqualog/auth/repository/authrepository.dart';
import 'package:aqualog/register/bloc/register_bloc.dart';
import 'package:aqualog/register/bloc/register_event.dart';
import 'package:aqualog/register/bloc/register_state.dart';

// Colores
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
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: BlocProvider(
            create: (context) {
              return RegisterBloc(
                authRepository: RepositoryProvider.of<AuthRepository>(context),
              );
            },
            child: const RegisterForm(),
          ),
        ),
      ),
    );
  }
}

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
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
                duration: const Duration(seconds: 4),
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
            'Bienvenido a AquaLog',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // --- CAMBIO: Texto explicativo para el uso del email real ---
          const Text(
            'Usa un email real para poder recuperar tu cuenta si olvidas la contraseña.',
            textAlign: TextAlign.center,
            style: TextStyle(color: hintColor, fontSize: 14),
          ),
          const SizedBox(height: 40),
          
          const _EmailInput(), // --- CAMBIO: Sustituimos Usuario por Email ---
          const SizedBox(height: 20),
          const _PasswordInput(),
          
          const SizedBox(height: 30),
          const _RegisterButton(),
        ],
      ),
    );
  }
}

// --- CAMBIO: Clase adaptada para el Email ---
class _EmailInput extends StatefulWidget {
  const _EmailInput();
  @override
  State<_EmailInput> createState() => _EmailInputState();
}

class _EmailInputState extends State<_EmailInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Nota: Seguimos usando state.username del bloc por debajo para no romper el resto de la app
    _controller = TextEditingController(text: context.read<RegisterBloc>().state.username);
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
      onChanged: (val) {
        context.read<RegisterBloc>().add(RegisterUsernameChanged(val));
      },
      style: const TextStyle(color: textColor),
      keyboardType: TextInputType.emailAddress, // --- CAMBIO: Muestra el teclado con la '@'
      decoration: InputDecoration(
        labelText: 'Correo Electrónico',
        hintText: 'ejemplo@correo.com',
        labelStyle: const TextStyle(color: hintColor),
        prefixIcon: const Icon(Icons.email, color: hintColor), // --- CAMBIO: Icono de email
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
      ),
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
    _controller = TextEditingController(text: context.read<RegisterBloc>().state.password);
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
      onChanged: (password) =>
          context.read<RegisterBloc>().add(RegisterPasswordChanged(password)),
      obscureText: true,
      style: const TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: 'Contraseña',
        labelStyle: const TextStyle(color: hintColor),
        prefixIcon: const Icon(Icons.lock, color: hintColor), // Añadido para consistencia con el email
        helperText: 'Debe tener al menos 6 caracteres',
        helperStyle: const TextStyle(color: hintColor),
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
      ),
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
                  'Registrarse',
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