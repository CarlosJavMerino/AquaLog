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
const Color cardColor = Color(0xFF112240); // Añadido para el color del Dialog
const Color textColor = Colors.white;
const Color hintColor = Colors.white54;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: BlocProvider(
        create: (context) {
          return LoginBloc(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          );
        },
        child: const _LoginForm(),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (prev, curr) => prev.formStatus != curr.formStatus,
      listener: (context, state) {
        if (state.formStatus == FormStatus.submissionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.scuba_diving, size: 80, color: accentColor),
            const SizedBox(height: 20),
            const Text(
              'AquaLog',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor, 
                fontSize: 32, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 40),
            
            _EmailInput(), // Actualizado
            const SizedBox(height: 16),
            _PasswordInput(),
            
            // --- NUEVO: Botón de recuperar contraseña ---
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showResetPasswordDialog(context),
                child: const Text(
                  '¿Olvidaste tu contraseña?', 
                  style: TextStyle(color: hintColor)
                ),
              ),
            ),
            // --------------------------------------------

            const SizedBox(height: 16),
            _LoginButton(),
            
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).push(RegisterScreen.route()),
              child: const Text(
                '¿Nuevo buceador? Crea una cuenta', 
                style: TextStyle(color: accentColor)
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ACTUALIZADO: Antes era _UsernameInput ---
class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (val) => context.read<LoginBloc>().add(LoginUsernameChanged(val)),
      style: const TextStyle(color: textColor),
      keyboardType: TextInputType.emailAddress, // Teclado optimizado para emails
      decoration: _authDecoration('Correo Electrónico', Icons.email),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (val) => context.read<LoginBloc>().add(LoginPasswordChanged(val)),
      obscureText: true,
      style: const TextStyle(color: textColor),
      decoration: _authDecoration('Contraseña', Icons.lock),
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoginBloc>().state;
    
    if (state.formStatus == FormStatus.submissionInProgress) {
      return const Center(child: CircularProgressIndicator(color: accentColor));
    }

    return ElevatedButton(
      onPressed: () => context.read<LoginBloc>().add(const LoginSubmitted()),
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Text(
        'Iniciar sesión', 
        style: TextStyle(
          color: primaryColor, 
          fontSize: 18, 
          fontWeight: FontWeight.bold
        )
      ),
    );
  }
}

InputDecoration _authDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: hintColor),
    labelStyle: const TextStyle(color: hintColor),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: hintColor),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: accentColor),
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: Colors.white10,
  );
}

// --- NUEVO: Función para mostrar el Pop-up de recuperación ---
void _showResetPasswordDialog(BuildContext context) {
  final TextEditingController emailController = TextEditingController();
  // Pre-rellenamos el email si el usuario ya lo había escrito en la pantalla
  emailController.text = context.read<LoginBloc>().state.username; 

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Recuperar contraseña', style: TextStyle(color: textColor)),
        content: TextField(
          controller: emailController,
          style: const TextStyle(color: textColor),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Tu correo electrónico',
            hintStyle: const TextStyle(color: hintColor),
            filled: true,
            fillColor: primaryColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: hintColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                // Llamamos a la función del repositorio para enviar el correo
                RepositoryProvider.of<AuthRepository>(context).resetPassword(email: email);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Si el correo existe, te enviaremos un enlace.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Enviar enlace', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}