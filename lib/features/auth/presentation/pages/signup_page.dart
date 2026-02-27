// lib/features/auth/presentation/pages/signup_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'email_verification_page.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please agree to Terms & Conditions")),
        );
        return;
      }

      setState(() => _isLoading = true);

      context.read<AuthBloc>().add(
        SignupRequestedEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
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
        title: Text("Create Account", style: context.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          setState(() => _isLoading = false);

          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is EmailVerificationRequired) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EmailVerificationPage(
                  userId: state.userId,
                  email: state.email,
                  message: state.message,
                ),
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

                  // Logo/Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add,
                      size: 40,
                      color: context.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    "Create Account",
                    style: context.textTheme.headlineSmall,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    "Sign up to start buying and selling safely",
                    style: context.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 32),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    validator: Validators.required,
                    decoration: const InputDecoration(
                      hintText: "Full Name",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    validator: Validators.password,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Password Requirements
                  Row(
                    children: [
                      _buildRequirement(
                        '6+ chars',
                        _passwordController.text.length >= 6,
                      ),
                      const SizedBox(width: 12),
                      _buildRequirement(
                        'Uppercase',
                        _passwordController.text.contains(RegExp(r'[A-Z]')),
                      ),
                      const SizedBox(width: 12),
                      _buildRequirement(
                        'Number',
                        _passwordController.text.contains(RegExp(r'[0-9]')),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    validator: (val) => val != _passwordController.text
                        ? "Passwords do not match"
                        : null,
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

                  const SizedBox(height: 16),

                  // Terms Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        activeColor: context.primaryColor,
                        onChanged: (v) => setState(() => _agreeToTerms = v!),
                      ),
                      Expanded(
                        child: Text(
                          "I agree to Terms of Service and Privacy Policy",
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _handleSignup,
                            child: const Text("Create Account"),
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
                  
                  // Google Sign Up Button
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
                            label: const Text("Sign up with Google"),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.3)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                  ),

                  const SizedBox(height: 40), // Extra space for keyboard smoothness

                  const SizedBox(height: 16),

                  // 🔥 NEW: Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: context.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to login page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Log In",
                          style: TextStyle(
                            color: context.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40), // More bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool met) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 12,
            color: met ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: met ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
