import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';

/// Checks if user is logged in.
/// If YES: executes [onAuthenticated].
/// If NO: opens Login Screen.
void authGuard(BuildContext context, VoidCallback onAuthenticated) {
  final state = context.read<AuthBloc>().state;

  if (state is AuthSuccess) {
    onAuthenticated();
  } else {
    // Navigate to Login Page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}
