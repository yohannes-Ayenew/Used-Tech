// lib/features/auth/presentation/pages/reset_password_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({
    super.key,
    required this.email,
    required userId,
    required token,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    String otp = _otpController.text.trim();

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the 6-digit code"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    context.read<AuthBloc>().add(
      ResetPasswordRequestedEvent(
        email: widget.email,
        otp: otp,
        newPassword: _newPasswordController.text,
      ),
    );
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
        title: Text("Reset Password", style: context.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          setState(() => _isLoading = false);

          if (state is ResetPasswordSuccess) {
            _showSuccessDialog();
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
                  const SizedBox(height: 20),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 50,
                      color: context.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Reset Password",
                    style: context.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter the 6-digit code sent to",
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.lightGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.email,
                      style: TextStyle(
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // OTP Field
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 4),
                    maxLength: 6,
                    decoration: const InputDecoration(
                      hintText: "000000",
                      counterText: "",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // New Password
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    decoration: InputDecoration(
                      hintText: "New Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscureNewPassword = !_obscureNewPassword,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _handleSubmit,
                            child: const Text("Reset Password"),
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Password Reset!", style: context.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              "Your password has been reset successfully.",
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: Text(
              "Go to Login",
              style: TextStyle(
                color: context.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
