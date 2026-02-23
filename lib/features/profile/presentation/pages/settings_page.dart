// lib/features/profile/presentation/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'edit_profile_page.dart';
import 'verification_page.dart';
import 'change_password_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _twoFactorAuth = false;
  bool _biometricLogin = false;

  String _selectedLanguage = 'English';

  final List<Map<String, String>> _languageOptions = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'am', 'name': 'Amharic', 'native': 'አማርኛ'},
  ];

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Language", style: context.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languageOptions.map((lang) {
            return ListTile(
              title: Text(lang['name']!, style: context.textTheme.bodyLarge),
              subtitle: Text(
                lang['native']!,
                style: context.textTheme.bodySmall,
              ),
              leading: Radio<String>(
                value: lang['name']!,
                groupValue: _selectedLanguage,
                activeColor: context.primaryColor,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Active Sessions", style: context.textTheme.titleLarge),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildSessionItem(
                context,
                'Current Device',
                'iPhone 13 • Addis Ababa',
                'Now',
                isCurrent: true,
              ),
              const Divider(color: Colors.grey),
              _buildSessionItem(
                context,
                'Windows PC',
                'Chrome • Bole',
                '2 hours ago',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: context.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(
    BuildContext context,
    String device,
    String location,
    String time, {
    bool isCurrent = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCurrent ? Icons.phone_android : Icons.devices,
              color: context.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(device, style: context.textTheme.titleMedium),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Current',
                          style: TextStyle(
                            fontSize: 10,
                            color: context.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(location, style: context.textTheme.bodySmall),
              ],
            ),
          ),
          Text(time, style: context.textTheme.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state is AuthSuccess
        ? (context.read<AuthBloc>().state as AuthSuccess).user
        : null;
    final themeCubit = context.watch<ThemeCubit>();
    final currentTheme = themeCubit.state.currentTheme;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Settings", style: context.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ACCOUNT SECTION
            Text(
              "ACCOUNT",
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Profile Info
            _buildSettingsItem(
              context,
              icon: Icons.person_outline,
              title: "Profile Info",
              subtitle: "Edit name, email, phone",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
            ),

            // Verification Status
            _buildSettingsItem(
              context,
              icon: Icons.verified_outlined,
              title: "Verification Status",
              subtitle: user?.kycStatus.displayName ?? "Not Verified",
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (user?.kycStatus.color ?? Colors.grey).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      user?.kycStatus.icon ?? Icons.verified_outlined,
                      size: 14,
                      color: user?.kycStatus.color ?? Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user?.kycStatus.displayName ?? "Not Verified",
                      style: TextStyle(
                        fontSize: 12,
                        color: user?.kycStatus.color ?? Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VerificationPage(),
                  ),
                );
              },
            ),

            // Change Password
            _buildSettingsItem(
              context,
              icon: Icons.lock_outline,
              title: "Change Password",
              subtitle: "Update your password",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // APP PREFERENCES SECTION
            Text(
              "APP PREFERENCES",
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Theme
            _buildSettingsItem(
              context,
              icon: Icons.brightness_6_outlined,
              title: "Theme",
              subtitle: "Choose app appearance",
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getThemeName(currentTheme),
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: context.greyText,
                  ),
                ],
              ),
              onTap: _showThemeDialog,
            ),

            // Theme Options
            Padding(
              padding: const EdgeInsets.only(left: 52, top: 8, bottom: 8),
              child: Row(
                children: [
                  _buildThemeChip(
                    context,
                    'Light',
                    currentTheme == AppTheme.light,
                  ),
                  const SizedBox(width: 8),
                  _buildThemeChip(
                    context,
                    'Dark',
                    currentTheme == AppTheme.dark,
                  ),
                  const SizedBox(width: 8),
                  _buildThemeChip(
                    context,
                    'System',
                    currentTheme == AppTheme.system,
                  ),
                ],
              ),
            ),

            // Language
            _buildSettingsItem(
              context,
              icon: Icons.language_outlined,
              title: "Language",
              subtitle: "Choose app language",
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedLanguage, style: context.textTheme.bodyMedium),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: context.greyText,
                  ),
                ],
              ),
              onTap: _showLanguageDialog,
            ),

            // Language Options
            Padding(
              padding: const EdgeInsets.only(left: 52, top: 8, bottom: 8),
              child: Wrap(
                spacing: 8,
                children: _languageOptions.map((lang) {
                  final isSelected = _selectedLanguage == lang['name'];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.primaryColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? context.primaryColor
                            : context.borderColor,
                      ),
                    ),
                    child: Text(
                      lang['native']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? context.primaryColor
                            : context.greyText,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Notifications
            _buildSettingsItem(
              context,
              icon: Icons.notifications_outlined,
              title: "Notifications",
              subtitle: _notificationsEnabled ? "Enabled" : "Disabled",
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeThumbColor: context.primaryColor,
              ),
              onTap: () {
                setState(() {
                  _notificationsEnabled = !_notificationsEnabled;
                });
              },
            ),

            const SizedBox(height: 24),

            // SECURITY SECTION
            Text(
              "SECURITY",
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Two-Factor Auth
            _buildSettingsItem(
              context,
              icon: Icons.security_outlined,
              title: "Two-Factor Auth",
              subtitle: "Extra security layer",
              trailing: Switch(
                value: _twoFactorAuth,
                onChanged: (value) {
                  setState(() {
                    _twoFactorAuth = value;
                  });
                },
                activeThumbColor: context.primaryColor,
              ),
              onTap: () {
                setState(() {
                  _twoFactorAuth = !_twoFactorAuth;
                });
              },
            ),

            // Biometric Login
            _buildSettingsItem(
              context,
              icon: Icons.fingerprint,
              title: "Biometric Login",
              subtitle: "Fingerprint or Face ID",
              trailing: Switch(
                value: _biometricLogin,
                onChanged: (value) {
                  setState(() {
                    _biometricLogin = value;
                  });
                },
                activeThumbColor: context.primaryColor,
              ),
              onTap: () {
                setState(() {
                  _biometricLogin = !_biometricLogin;
                });
              },
            ),

            // Session Management
            _buildSettingsItem(
              context,
              icon: Icons.devices_outlined,
              title: "Session Management",
              subtitle: "View active sessions",
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: context.greyText,
              ),
              onTap: _showSessionDialog,
            ),

            const SizedBox(height: 24),

            // ABOUT SECTION
            Text(
              "ABOUT",
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Terms & Conditions
            _buildSettingsItem(
              context,
              icon: Icons.description_outlined,
              title: "Terms & Conditions",
              subtitle: "Read our terms of service",
              showArrow: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Terms & Conditions page coming soon"),
                    backgroundColor: context.primaryColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            // Privacy Policy
            _buildSettingsItem(
              context,
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              subtitle: "How we handle your data",
              showArrow: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Privacy Policy page coming soon"),
                    backgroundColor: context.primaryColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            // Help & Support
            _buildSettingsItem(
              context,
              icon: Icons.help_outline,
              title: "Help & Support",
              subtitle: "Get help with the app",
              showArrow: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Help & Support page coming soon"),
                    backgroundColor: context.primaryColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            // App Version
            _buildSettingsItem(
              context,
              icon: Icons.info_outline,
              title: "App Version",
              subtitle: "v1.0.0",
              showArrow: false,
              onTap: () {},
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.system:
        return 'System';
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Theme", style: context.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Light", style: context.textTheme.bodyLarge),
              leading: Radio<AppTheme>(
                value: AppTheme.light,
                groupValue: context.watch<ThemeCubit>().state.currentTheme,
                activeColor: context.primaryColor,
                onChanged: (value) {
                  if (value != null) {
                    context.read<ThemeCubit>().setTheme(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: Text("Dark", style: context.textTheme.bodyLarge),
              leading: Radio<AppTheme>(
                value: AppTheme.dark,
                groupValue: context.watch<ThemeCubit>().state.currentTheme,
                activeColor: context.primaryColor,
                onChanged: (value) {
                  if (value != null) {
                    context.read<ThemeCubit>().setTheme(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: Text("System", style: context.textTheme.bodyLarge),
              leading: Radio<AppTheme>(
                value: AppTheme.system,
                groupValue: context.watch<ThemeCubit>().state.currentTheme,
                activeColor: context.primaryColor,
                onChanged: (value) {
                  if (value != null) {
                    context.read<ThemeCubit>().setTheme(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: context.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(subtitle, style: context.textTheme.bodySmall),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (showArrow)
              Icon(Icons.arrow_forward_ios, size: 14, color: context.greyText),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeChip(BuildContext context, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        AppTheme theme;
        switch (label) {
          case 'Light':
            theme = AppTheme.light;
            break;
          case 'Dark':
            theme = AppTheme.dark;
            break;
          default:
            theme = AppTheme.system;
        }
        context.read<ThemeCubit>().setTheme(theme);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? context.primaryColor : context.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? context.primaryColor : context.greyText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
