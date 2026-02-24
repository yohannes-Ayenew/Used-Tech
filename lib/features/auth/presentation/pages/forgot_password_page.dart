// lib/features/auth/presentation/pages/forgot_password_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      context.read<AuthBloc>().add(
        ForgotPasswordRequestedEvent(email: _emailController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Forgot Password", style: context.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          setState(() => _isLoading = false);

          if (state is ForgotPasswordSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordPage(
                  email: _emailController.text.trim(),
                  userId: null,
                  token: null,
                ),
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 40,
                      color: context.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Reset Password",
                    style: context.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your email to receive a verification code",
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _emailController,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _handleSubmit,
                            child: const Text("Send Reset Code"),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
