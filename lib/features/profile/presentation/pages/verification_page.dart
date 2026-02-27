import 'dart:io';
import 'package:flutter/foundation.dart';  
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import '../../../auth/domain/enums/kyc_status.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  XFile? _frontImage;
  XFile? _backImage;
  XFile? _faceImage;
  
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(String type, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (type == 'front') _frontImage = image;
          else if (type == 'back') _backImage = image;
          else if (type == 'face') _faceImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showOptions(String type) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () { Navigator.pop(context); _pickImage(type, ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () { Navigator.pop(context); _pickImage(type, ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }

  void _submitVerification() {
    if (_frontImage == null || _backImage == null || _faceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload all 3 photos (Front, Back, Face)"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      RequestVerificationEvent(
        frontImage: _frontImage!,
        backImage: _backImage!,
        faceImage: _faceImage!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final user = state is AuthSuccess ? state.user : null;

    // 1. CHECK STATUS: If Approved or Pending, DO NOT show the form
    if (user != null && (user.kycStatus == KycStatus.approved || user.kycStatus == KycStatus.pending)) {
      return Scaffold(
        appBar: AppBar(title: const Text("Verification Status")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Big Icon
                Icon(
                  user.kycStatus == KycStatus.approved ? Icons.verified : Icons.hourglass_top,
                  size: 100,
                  color: user.kycStatus.color,
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  user.kycStatus.displayName,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: user.kycStatus.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Message
                Text(
                  user.kycStatus.message,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
                // Back Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Go Back to Profile"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. DEFAULT VIEW: Show Upload Form (For 'none' or 'rejected')
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) setState(() => _isLoading = true);
        else setState(() => _isLoading = false);

        if (state is VerificationRequestSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("ID Verification")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user != null && user.kycStatus == KycStatus.rejected)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(child: Text(user.kycStatus.message, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              
              const Text("1. National ID (Front)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildUploadBox('front', _frontImage),

              const SizedBox(height: 20),
              const Text("2. National ID (Back)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildUploadBox('back', _backImage),

              const SizedBox(height: 20),
              const Text("3. Selfie / Face Photo", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildUploadBox('face', _faceImage),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitVerification,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Verification"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadBox(String type, XFile? file) {
    return GestureDetector(
      onTap: () => _showOptions(type),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PlatformAwareImage(file: file),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text("Tap to Upload ${type.toUpperCase()}", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
      ),
    );
  }
}

class PlatformAwareImage extends StatelessWidget {
  final XFile file;
  const PlatformAwareImage({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(file.path, fit: BoxFit.cover);
    } else {
      return Image.file(File(file.path), fit: BoxFit.cover);
    }
  }
}