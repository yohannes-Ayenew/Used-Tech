// lib/features/profile/presentation/pages/change_password_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/utils/validators.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      context.read<AuthBloc>().add(
        ChangePasswordRequestedEvent(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        ),
      );
    }
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
            Text("Password Changed!", style: context.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              "Your password has been updated successfully.",
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to profile
            },
            child: Text(
              "OK",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Change Password", style: context.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          print('📥 ChangePassword page received state: $state');
          setState(() => _isLoading = false);

          if (state is PasswordChangeSuccess) {
            print('✅ Password change successful!');
            _showSuccessDialog();
          } else if (state is AuthFailure) {
            print('❌ Password change failed: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (_isLoading && mounted) {
            Future.delayed(const Duration(seconds: 15), () {
              if (_isLoading && mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Request timed out. Please try again."),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            });
          }
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: 50,
                          color: context.primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      "Update Password",
                      style: context.textTheme.headlineSmall,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Choose a strong password you haven't used before",
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 32),

                    // Current Password
                    Text(
                      "Current Password",
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrent,
                        validator: Validators.required,
                        style: context.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: "Enter current password",
                          hintStyle: context.textTheme.bodyMedium,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: context.greyText,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrent
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: context.greyText,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrent = !_obscureCurrent;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // New Password
                    Text(
                      "New Password",
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        validator: Validators.strongPassword,
                        style: context.textTheme.bodyLarge,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: "Enter new password",
                          hintStyle: context.textTheme.bodyMedium,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: context.greyText,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNew
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: context.greyText,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNew = !_obscureNew;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Password strength
                    Row(
                      children: [
                        _buildPasswordRequirement(
                          context,
                          '8+ chars',
                          _newPasswordController.text.length >= 8,
                        ),
                        const SizedBox(width: 12),
                        _buildPasswordRequirement(
                          context,
                          'Uppercase',
                          _newPasswordController.text.contains(
                            RegExp(r'[A-Z]'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildPasswordRequirement(
                          context,
                          'Number',
                          _newPasswordController.text.contains(
                            RegExp(r'[0-9]'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildPasswordRequirement(
                          context,
                          'Special',
                          _newPasswordController.text.contains(
                            RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Confirm Password
                    Text(
                      "Confirm New Password",
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        style: context.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: "Confirm new password",
                          hintStyle: context.textTheme.bodyMedium,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: context.greyText,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: context.greyText,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_confirmPasswordController.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              _newPasswordController.text ==
                                  _confirmPasswordController.text
                              ? context.successColor.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _newPasswordController.text ==
                                      _confirmPasswordController.text
                                  ? Icons.check_circle
                                  : Icons.error_outline,
                              color:
                                  _newPasswordController.text ==
                                      _confirmPasswordController.text
                                  ? context.successColor
                                  : Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _newPasswordController.text ==
                                      _confirmPasswordController.text
                                  ? "Passwords match"
                                  : "Passwords do not match",
                              style: TextStyle(
                                color:
                                    _newPasswordController.text ==
                                        _confirmPasswordController.text
                                    ? context.successColor
                                    : Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _handleSubmit,
                              child: const Text("Update Password"),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordRequirement(
    BuildContext context,
    String text,
    bool isMet,
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: isMet ? context.successColor : context.greyText,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: isMet ? context.successColor : context.greyText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
