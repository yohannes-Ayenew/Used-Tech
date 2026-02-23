// lib/features/sell/presentation/pages/sell_page.dart

import 'package:flutter/material.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'step2_brand_model_page.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.phone_android,
      'title': 'Mobile Phone',
      'subtitle': 'Smartphones & Feature Phones',
      'value': 'mobile',
    },
    {
      'icon': Icons.laptop,
      'title': 'Laptop / Computer',
      'subtitle': 'Laptops, Desktops & All-in-One',
      'value': 'laptop',
    },
    {
      'icon': Icons.tablet_android,
      'title': 'Tablet',
      'subtitle': 'iPads & Android Tablets',
      'value': 'tablet',
    },
  ];

  void _nextStep() {
    if (_selectedCategory != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Step2BrandModelPage(
            category: _selectedCategory!,
            onNext: (data) {
              // Handle next step
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("List Your Device", style: context.textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: 1 / 5,
            backgroundColor: context.lightGrey,
            valueColor: AlwaysStoppedAnimation(context.primaryColor),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Step 1 of 5", style: context.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(
                    "What are you selling?",
                    style: context.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Select the category of your device",
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Category Cards
                  ..._categories.map(
                    (category) => _buildCategoryCard(context, category),
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
                  onPressed: _selectedCategory == null ? null : _nextStep,
                  child: const Text("Next"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final isSelected = _selectedCategory == category['value'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category['value'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryColor.withValues(alpha: 0.05)
              : context.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.primaryColor : context.borderColor,
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
                    ? context.primaryColor.withValues(alpha: 0.1)
                    : context.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category['icon'],
                color: isSelected ? context.primaryColor : context.greyText,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? context.primaryColor
                          : context.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['subtitle'],
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: context.primaryColor,
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
