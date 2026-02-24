import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    if (otp.length < 6) return;
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
          } else if (state is AuthSuccess) {
            print('✅ Verification Success - Auto Logging In');

            // 1. Clear navigation stack down to the root
            Navigator.popUntil(context, (route) => route.isFirst);

            // 2. Since AuthBloc is global and now emits AuthSuccess,
            // the Root Widget (MyApp/BottomBar) will automatically
            // see the authenticated user.

            // Optional: You can force a pushReplacement to ensure fresh state
            // Navigator.pushReplacementNamed(context, '/');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Welcome ${state.user.name}!"),
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
                Text(
                  widget.email,
                  style: TextStyle(
                    color: context.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // OTP INPUT
                Container(
                  decoration: BoxDecoration(
                    color: context.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.borderColor),
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
                    decoration: const InputDecoration(
                      hintText: "000000",
                      counterText: "",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onChanged: (value) {
                      if (value.length == 6) _verifyOtp();
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _verifyOtp,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Verify Email"),
                  ),
                ),

                const SizedBox(height: 16),

                // RESEND
                GestureDetector(
                  onTap: _canResend ? _resendOtp : null,
                  child: Text(
                    _canResend ? "Resend Code" : "Resend in $_resendTimer s",
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
          ),
        ),
      ),
    );
  }
}
