import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sell_bloc.dart';
import '../bloc/sell_event.dart';
import 'step5_price_description_page.dart';

class Step4ImagesPage extends StatefulWidget {
  final Function(List<XFile>) onNext;

  const Step4ImagesPage({super.key, required this.onNext});

  @override
  State<Step4ImagesPage> createState() => _Step4ImagesPageState();
}

class _Step4ImagesPageState extends State<Step4ImagesPage> {
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (_images.length < 10) {
        setState(() {
          _images.add(image);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can only select up to 10 images.')),
        );
      }
    }
  }

  void _nextStep() {
    // Save images to draft then navigate
    context.read<SellBloc>().add(CacheDraftListingEvent({'images': _images}));
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Step5PriceDescriptionPage(
          onSubmit: (data) {
            // Step 5 handles the final submit
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text("List Your Device", style: context.textTheme.titleLarge)),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: 4 / 5,
            backgroundColor: context.lightGrey,
            valueColor: AlwaysStoppedAnimation(context.primaryColor),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Step 4 of 5", style: context.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text("Upload 3 to 10 Photos", style: context.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text("Minimum 3 photos required. Clear photos sell faster!", style: context.textTheme.bodyMedium),
                  const SizedBox(height: 32),

                  // Image Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _images.length < 10 ? _images.length + 1 : 10,
                    itemBuilder: (context, index) {
                      // Add Button (Last item)
                      if (index == _images.length) {
                        return GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.lightGrey,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.borderColor, style: BorderStyle.solid),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: context.greyText),
                                const SizedBox(height: 4),
                                Text("Add", style: context.textTheme.bodySmall),
                              ],
                            ),
                          ),
                        );
                      }

                      // Image Item
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                              ? Image.network(
                                  _images[index].path,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : Image.file(
                                  File(_images[index].path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _images.removeAt(index)),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: const Icon(Icons.close, size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  
                  // Tips
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📷 Photo Tips:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800])),
                        const SizedBox(height: 8),
                        _buildTip("Take photos in good lighting"),
                        _buildTip("Take 1 Front, 1 Back, and 1 Info screen"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Next Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cardBackground,
              border: Border(top: BorderSide(color: context.borderColor)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _images.length >= 3 ? _nextStep : null,
                  child: const Text("Next"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.blue),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.blue)),
        ],
      ),
    );
  }
}