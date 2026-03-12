// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'signup_page.dart';
import 'email_verification_page.dart';
import 'forgot_password_page.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../injection_container.dart' as di;
import 'dart:async';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  late StreamSubscription<ConnectivityStatus> _connectivitySubscription;
  ConnectivityStatus _connectivityStatus = ConnectivityStatus.checking;

  @override
  void initState() {
    super.initState();
    final connectivityService = di.sl<ConnectivityService>();
    _connectivityStatus = connectivityService.currentStatus;
    _connectivitySubscription = connectivityService.statusStream.listen((status) {
      if (mounted) {
        setState(() => _connectivityStatus = status);
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage("Please fill in all fields", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    context.read<AuthBloc>().add(
          LoginRequestedEvent(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          setState(() => _isLoading = false);

          if (state is AuthFailure) {
            _showMessage(state.message, Colors.red);
          } else if (state is EmailVerificationRequired) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmailVerificationPage(
                  userId: state.userId,
                  email: state.email,
                  message: state.message,
                ),
              ),
            );
          } else if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, '/');
            _showMessage("Welcome back, ${state.user.name}!", Colors.green);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                    Icons.shopping_bag,
                    size: 40,
                    color: context.primaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                Text("Welcome Back", style: context.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  "Sign in to continue",
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Email
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: "Email",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: context.primaryColor),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _handleLogin,
                          child: const Text("Log In"),
                        ),
                ),

                const SizedBox(height: 16),
                
                // OR Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("OR", style: context.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Google Login Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _isLoading = true);
                            context
                                .read<AuthBloc>()
                                .add(GoogleSignInRequestedEvent());
                          },
                          icon: Image.network(
                            'https://www.gstatic.com/images/branding/product/1x/googleg_48dp.png',
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.login,
                                color: Colors.blue,
                              );
                            },
                          ),
                          label: const Text("Continue with Google"),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                ),

                if (_connectivityStatus == ConnectivityStatus.offline) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Cannot connect to server. Please check your network and make sure the backend is running.",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: context.textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                        ),
                      ),
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                          color: context.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
