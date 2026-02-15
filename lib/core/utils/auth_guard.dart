// lib/core/utils/auth_guard.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../common/widgets/auth_bottom_sheet.dart';

/// Checks if user is logged in using BLoC state.
/// If YES: executes [onAuthenticated].
/// If NO: shows AuthBottomSheet (not full screen).
void authGuard(BuildContext context, VoidCallback onAuthenticated) {
  final state = context.read<AuthBloc>().state;

  if (state is AuthSuccess) {
    onAuthenticated();
  } else {
    // Show Auth Bottom Sheet (not full screen)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AuthBottomSheet(),
    );
  }
}
