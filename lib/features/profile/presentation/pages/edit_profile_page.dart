// lib/features/profile/presentation/pages/edit_profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/core/utils/validators.dart';
import 'package:used_tech_client/features/auth/presentation/pages/email_verification_page.dart';
import 'package:used_tech_client/core/constants/api_endpoints.dart';
import 'package:path/path.dart' as p;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'package:used_tech_client/injection_container.dart' as di;
import 'change_password_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _profileImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  
  // 🚀 CUSTOM STATE: Cache user to prevent UI flickering during AuthLoading
  UserEntity? _currentUser;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthSuccess) {
      _currentUser = state.user;
      _nameController.text = _currentUser!.name;
      _phoneController.text = _currentUser!.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to pick image: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to take photo: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: context.cardBackground),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Profile Photo", style: context.textTheme.titleLarge),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.photo_library, color: context.primaryColor),
              ),
              title: Text(
                "Choose from Gallery",
                style: context.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt, color: context.primaryColor),
              ),
              title: Text("Take a Photo", style: context.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              title: Text(
                "Remove Current Photo",
                style: context.textTheme.bodyLarge?.copyWith(color: Colors.red),
              ),
              onTap: () {
                setState(() {
                  _profileImage = null;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name[0].toUpperCase();
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.green,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Great!",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your profile has been updated successfully",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
    
    // Auto-pop the dialog AND the page
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(); // Go back to profile
      }
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            UpdateProfileRequestedEvent(
              name: _nameController.text,
              phone: _phoneController.text,
              profileImage: _profileImage != null ? XFile(_profileImage!.path) : null,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    
    // 💡 IMPROVED LOGIC: Use local cache if global state is loading
    final user = (state is AuthSuccess) ? state.user : _currentUser;

    if (user == null) {
      // If we don't have a user in local state OR in the BLoC state, 
      // check if the BLoC state is Guest or Initial.
      if (state is AuthGuest || state is AuthInitial) {
        return Scaffold(
          body: Center(
            child: Text("Not authenticated", style: context.textTheme.bodyLarge),
          ),
        );
      }
      // Otherwise, we are likely in an initial loading phase.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final initials = _getInitials(user.name);

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Edit Profile", style: context.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() => _isLoading = true);
          } else if (state is AuthFailure) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AuthSuccess) {
            setState(() {
              _isLoading = false;
              _currentUser = state.user; // Update local cache
            });
            _showSuccessDialog();
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Picture
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.lightGrey,
                            border: Border.all(
                              color: context.borderColor,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: _profileImage != null
                                ? Image.file(_profileImage!, fit: BoxFit.cover)
                                : user.profileImage != null
                                    ? Image.network(
                                        "${ApiEndpoints.baseUrl.replaceAll('/api', '')}/${user.profileImage}",
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Center(
                                          child: Text(
                                            initials,
                                            style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              color: context.primaryColor,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          initials,
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: context.primaryColor,
                                          ),
                                        ),
                                      ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.cardBackground,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      "Tap camera icon to change photo",
                      style: context.textTheme.bodySmall,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Email (read-only)
                  Text(
                    "Email",
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: context.lightGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: context.greyText,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user.email,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.greyText,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: context.greyText,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Full Name
                  Text(
                    "Full Name",
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
                      controller: _nameController,
                      validator: Validators.required,
                      style: context.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: "Enter your full name",
                        hintStyle: context.textTheme.bodyMedium,
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: context.greyText,
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

                  // Phone Number
                  Text(
                    "Phone Number",
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
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone,
                      style: context.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: "Enter your phone number",
                        hintStyle: context.textTheme.bodyMedium,
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: context.greyText,
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          user.isEmailVerified
                          ? context.successColor.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: user.isEmailVerified
                            ? context.successColor.withValues(alpha: 0.3)
                            : Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          user.isEmailVerified
                              ? Icons.mark_email_read
                              : Icons.warning_amber,
                          color: user.isEmailVerified
                              ? context.successColor
                              : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.isEmailVerified
                                    ? "Email Verified"
                                    : "Email Not Verified",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: user.isEmailVerified
                                      ? context.successColor
                                      : Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.isEmailVerified
                                    ? "Your email address is verified"
                                    : "Please verify your email to access all features",
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (!user.isEmailVerified)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmailVerificationPage(
                                    userId: user.id,
                                    email: user.email,
                                    message: "Please verify your email to continue",
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "Verify Now",
                              style: TextStyle(color: context.primaryColor),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Change Password Link
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              color: context.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Change Password",
                                  style: context.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Update your password regularly",
                                  style: context.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: context.greyText,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _handleSubmit,
                            child: const Text("Save Changes"),
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

