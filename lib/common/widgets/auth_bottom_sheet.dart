// lib/common/widgets/auth_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../../core/constants/global_variables.dart';

class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({super.key});

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  // Form states
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final List<TextEditingController> _otpFields = List.generate(
    6,
    (index) => TextEditingController(),
  );

  // UI states
  bool _obscurePassword = true;
  bool _isLoginMode = false;
  int _currentStep = 1; // 1: Email/Password, 2: OTP Verification
  bool _isEmailVerified = false;
  bool _isLoading = false;

  // Timer for resend OTP
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    for (var controller in _otpFields) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTimer = 60;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
            _startResendTimer();
          } else {
            _canResend = true;
          }
        });
      }
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );

    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (!_isLoginMode) {
      if (!value.contains(RegExp(r'[A-Z]'))) {
        return 'Password must contain at least one uppercase letter';
      }
      if (!value.contains(RegExp(r'[0-9]'))) {
        return 'Password must contain at least one number';
      }
    }

    return null;
  }

  void _sendVerificationCode() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call to send verification code
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _currentStep = 2;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Verification code sent to ${_emailController.text}",
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }

  void _verifyCode() {
    setState(() {
      _isLoading = true;
    });

    // Get OTP from all fields
    String otp = _otpFields.map((c) => c.text).join();

    // Simulate API call to verify code
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (otp.length == 6 && otp == '123456') {
          // In real app, verify with backend
          setState(() {
            _isEmailVerified = true;
          });

          // Show success and close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email verified successfully! Account created."),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid verification code"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  void _resendCode() {
    if (_canResend) {
      setState(() {
        _isLoading = true;
      });

      // Simulate resend code
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _startResendTimer();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("New code sent to ${_emailController.text}"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }

  void _handleSubmit() {
    if (_currentStep == 1) {
      _sendVerificationCode();
    } else {
      _verifyCode();
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _currentStep = 1;
      _emailController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Text(
                _isLoginMode ? "Welcome Back" : "Join to Sell Your Device",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Center(
              child: Text(
                _isLoginMode
                    ? "Sign in to continue trading safely"
                    : "Create an account and verify your identity to trade safely with escrow protection.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),

            // Step 1: Email and Password
            if (_currentStep == 1) ...[
              // Email field
              Container(
                decoration: BoxDecoration(
                  color: GlobalVariables.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _validateEmail,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: "Email address",
                    border: InputBorder.none,
                    hintStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    errorStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Password field
              Container(
                decoration: BoxDecoration(
                  color: GlobalVariables.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _validatePassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: "Password",
                    border: InputBorder.none,
                    hintStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    errorStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),

              // Password strength indicator
              if (!_isLoginMode) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPasswordRequirement(
                      '6+ chars',
                      _passwordController.text.length >= 6,
                    ),
                    const SizedBox(width: 12),
                    _buildPasswordRequirement(
                      'Uppercase',
                      _passwordController.text.contains(RegExp(r'[A-Z]')),
                    ),
                    const SizedBox(width: 12),
                    _buildPasswordRequirement(
                      'Number',
                      _passwordController.text.contains(RegExp(r'[0-9]')),
                    ),
                  ],
                ),
              ],
            ],

            // Step 2: OTP Verification
            if (_currentStep == 2) ...[
              // Email verification message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: GlobalVariables.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: GlobalVariables.primaryTeal.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.mark_email_read,
                      color: GlobalVariables.primaryTeal,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Verification Code Sent",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "Enter the 6-digit code sent to ${_emailController.text}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // OTP Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 45,
                    height: 50,
                    decoration: BoxDecoration(
                      color: GlobalVariables.lightGrey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _otpFields[index].text.isNotEmpty
                            ? GlobalVariables.primaryTeal
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: TextField(
                      controller: _otpFields[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      enabled: !_isLoading,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Resend code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: _canResend && !_isLoading ? _resendCode : null,
                    child: Text(
                      _canResend ? "Resend" : "Resend in $_resendTimer s",
                      style: TextStyle(
                        color: _canResend
                            ? GlobalVariables.primaryTeal
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Main Action Button
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalVariables.primaryTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _currentStep == 1
                        ? (_isLoginMode ? "Log In" : "Send Verification Code")
                        : "Verify & Create Account",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            // Back to email (during OTP step)
            if (_currentStep == 2) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = 1;
                    });
                  },
                  child: Text(
                    "Change email address",
                    style: TextStyle(
                      color: GlobalVariables.primaryTeal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],

            // Toggle between Login and Create Account (only in step 1)
            if (_currentStep == 1) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isLoginMode
                        ? "Create new account"
                        : "Already have an account? Log in",
                    style: TextStyle(
                      color: GlobalVariables.primaryTeal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],

            // OR Divider (only for login mode or step 1)
            if (_currentStep == 1) ...[
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "OR",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              // Google Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Handle Google sign in
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Image.network(
                    'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/google/google-original.svg',
                    height: 20,
                    width: 20,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.g_mobiledata,
                        color: Colors.red,
                        size: 24,
                      );
                    },
                  ),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Safety message
            const Center(
              child: Text(
                "Verification required before buying or selling",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 12,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: isMet ? Colors.green : Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
