import 'package:flutter/material.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C853), // Modern green
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                "Your device is now live!",
                style: context.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: context.theme.colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                "Buyers can now see your listing. You'll be notified when someone is interested.",
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.greyText,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              
              // View Listing Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Home or Listing detail
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0097A7), // Teal
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("View Listing", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Sell Another Device Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate back to the Sell flow
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false, arguments: {'initialTab': 2}); // Assuming tab 2 is Sell
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.theme.colorScheme.onBackground,
                    side: BorderSide(color: context.borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Sell Another Device", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
