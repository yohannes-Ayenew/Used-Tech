// lib/features/auth/presentation/pages/email_verification_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/common/widgets/bottom_bar.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class EmailVerificationPage extends StatefulWidget {
  final String userId;
  final String email;
  final String message;

  const EmailVerificationPage({
    super.key,
    required this.userId,
    required this.email,
    required this.message,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTimer = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
        }
      });
      return _resendTimer > 0 && mounted;
    });
  }

  void _verifyOtp() {
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

    setState(() => _isLoading = true);
    context.read<AuthBloc>().add(
      VerifyEmailEvent(userId: widget.userId, otp: otp),
    );
  }

  void _resendOtp() {
    if (!_canResend) return;

    setState(() => _isLoading = true);
    context.read<AuthBloc>().add(ResendOTPEvent(email: widget.email));
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
        title: Text("Verify Email", style: context.textTheme.titleLarge),
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
          } else if (state is OTPResent) {
            _startResendTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.successColor,
              ),
            );
          } else if (state is EmailVerified) {
            print('✅ Email verified - auto-login successful!');
            print('👤 User: ${state.user.email}');
            print('🔑 Token: ${state.token.substring(0, 10)}...');

            // Instead of pushing a new BottomBar, pop back to the existing one
            // and let the AuthBloc state update it automatically
            Navigator.popUntil(context, (route) => route.isFirst);

            // Then navigate to home with sell tab
            Navigator.pushReplacementNamed(
              context,
              '/',
              arguments: {'initialTab': 2},
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Welcome ${state.user.name}! Start selling now!"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                    Icons.mark_email_read,
                    size: 50,
                    color: context.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Verify Your Email",
                  style: context.textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
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
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // OTP Input Field
                Container(
                  decoration: BoxDecoration(
                    color: context.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _otpController.text.isNotEmpty
                          ? context.primaryColor
                          : context.borderColor,
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: "000000",
                      hintStyle: TextStyle(
                        fontSize: 32,
                        letterSpacing: 8,
                        color: context.greyText.withValues(alpha: 0.3),
                      ),
                      counterText: "",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 6) {
                        _verifyOtp();
                      }
                      setState(() {});
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Paste hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.content_paste,
                      size: 14,
                      color: context.greyText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "You can paste the entire code (Ctrl+V)",
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.greyText,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Resend timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive code? ",
                      style: context.textTheme.bodySmall,
                    ),
                    GestureDetector(
                      onTap: _canResend ? _resendOtp : null,
                      child: Text(
                        _canResend ? "Resend" : "Resend in $_resendTimer s",
                        style: TextStyle(
                          color: _canResend
                              ? context.primaryColor
                              : context.greyText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _verifyOtp,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Verify Email"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Create a new wrapper widget for BottomBar with initial tab
class BottomBarWithInitialTab extends StatelessWidget {
  final int initialTab;

  const BottomBarWithInitialTab({super.key, required this.initialTab});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return BottomBar(initialTab: initialTab);
      },
    );
  }
}
