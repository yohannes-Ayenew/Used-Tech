// lib/features/sell/presentation/pages/sell_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:used_tech_client/core/constants/global_variables.dart';
import 'step2_brand_model_page.dart';
import 'step3_condition_specs_page.dart';
import 'step4_images_page.dart';
import 'step5_price_description_page.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  int _currentStep = 1;

  // Data collected across steps
  String? _selectedCategory;
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedCondition;
  String? _selectedStorage;
  String? _selectedRam;
  String? _selectedProcessor;
  List<File> _images = [];
  int? _price;
  String? _description;

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
  }

  Future<void> _submitListing() async {
    // TODO: Submit to backend
    print('Submitting listing:');
    print('Category: $_selectedCategory');
    print('Brand: $_selectedBrand');
    print('Model: $_selectedModel');
    print('Condition: $_selectedCondition');
    print('Storage: $_selectedStorage');
    print('RAM: $_selectedRam');
    print('Processor: $_selectedProcessor');
    print('Images: ${_images.length}');
    print('Price: $_price');
    print('Description: $_description');

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your listing has been published!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back to home
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Step 1: Category Selection
    if (_currentStep == 1) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "List Your Device",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: 1 / 5,
              backgroundColor: GlobalVariables.lightGrey,
              valueColor: AlwaysStoppedAnimation(GlobalVariables.primaryTeal),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Step 1 of 5",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "What are you selling?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Select the category of your device",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    _buildCategoryCard(
                      icon: Icons.phone_android,
                      title: "Mobile Phone",
                      subtitle: "Smartphones & Feature Phones",
                      value: "mobile",
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryCard(
                      icon: Icons.laptop,
                      title: "Laptop / Computer",
                      subtitle: "Laptops, Desktops & All-in-One",
                      value: "laptop",
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryCard(
                      icon: Icons.tablet_android,
                      title: "Tablet",
                      subtitle: "iPads & Android Tablets",
                      value: "tablet",
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _selectedCategory == null
                        ? null
                        : () => _nextStep(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlobalVariables.primaryTeal,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Step 2: Brand & Model
    if (_currentStep == 2) {
      return Step2BrandModelPage(
        category: _selectedCategory!,
        onNext: (data) {
          setState(() {
            _selectedBrand = data['brand'];
            _selectedModel = data['model'];
          });
          _nextStep();
        },
      );
    }

    // Step 3: Condition & Specs
    if (_currentStep == 3) {
      return Step3ConditionSpecsPage(
        category: _selectedCategory!,
        onNext: (data) {
          setState(() {
            _selectedCondition = data['condition'];
            _selectedStorage = data['storage'];
            _selectedRam = data['ram'];
            _selectedProcessor = data['processor'];
          });
          _nextStep();
        },
      );
    }

    // Step 4: Images
    if (_currentStep == 4) {
      return Step4ImagesPage(
        onNext: (images) {
          setState(() {
            _images = images;
          });
          _nextStep();
        },
      );
    }

    // Step 5: Price & Description
    if (_currentStep == 5) {
      return Step5PriceDescriptionPage(
        onSubmit: (data) async {
          setState(() {
            _price = data['price'];
            _description = data['description'];
          });
          await _submitListing();
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _selectedCategory == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? GlobalVariables.primaryTeal.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? GlobalVariables.primaryTeal
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? GlobalVariables.primaryTeal.withValues(alpha: 0.1)
                    : GlobalVariables.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? GlobalVariables.primaryTeal : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? GlobalVariables.primaryTeal
                          : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: GlobalVariables.primaryTeal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
