import 'package:flutter/material.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'step3_condition_specs_page.dart';

class Step2BrandModelPage extends StatefulWidget {
  final String category;
  final Function(Map<String, dynamic>) onNext;

  const Step2BrandModelPage({
    super.key,
    required this.category,
    required this.onNext,
  });

  @override
  State<Step2BrandModelPage> createState() => _Step2BrandModelPageState();
}

class _Step2BrandModelPageState extends State<Step2BrandModelPage> {
  String? _selectedBrand;
  String? _selectedModel;
  
  // Controllers for "Other" input
  final TextEditingController _customBrandController = TextEditingController();
  final TextEditingController _customModelController = TextEditingController();

  late final List<Map<String, dynamic>> _brands;
  late final Map<String, List<String>> _models;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _customBrandController.dispose();
    _customModelController.dispose();
    super.dispose();
  }

  void _initializeData() {
    if (widget.category == 'mobile') {
      _brands = [
        {'name': 'Apple', 'icon': Icons.apple},
        {'name': 'Samsung', 'icon': Icons.phone_android},
        {'name': 'Xiaomi', 'icon': Icons.phone_android},
        {'name': 'Google', 'icon': Icons.android},
        {'name': 'Huawei', 'icon': Icons.phone_android},
        {'name': 'Other', 'icon': Icons.add},
      ];
      _models = {
        'Apple': ['iPhone 14 Pro Max', 'iPhone 14', 'iPhone 13', 'iPhone 12', 'iPhone 11', 'Other'],
        'Samsung': ['Galaxy S23 Ultra', 'Galaxy S22', 'Galaxy A54', 'Galaxy A14', 'Other'],
        'Xiaomi': ['Redmi Note 12', 'Poco X5', 'Mi 11', 'Other'],
      };
    } else {
      // Laptop / Tablet
      _brands = [
        {'name': 'Dell', 'icon': Icons.laptop},
        {'name': 'HP', 'icon': Icons.laptop},
        {'name': 'Apple', 'icon': Icons.apple},
        {'name': 'Lenovo', 'icon': Icons.laptop},
        {'name': 'Other', 'icon': Icons.add},
      ];
      _models = {
        'Apple': ['MacBook Pro M2', 'MacBook Air M1', 'MacBook Pro Intel', 'Other'],
        'Dell': ['XPS 15', 'XPS 13', 'Inspiron', 'Latitude', 'Other'],
        'HP': ['Pavilion', 'Envy', 'Spectre', 'EliteBook', 'Other'],
      };
    }
  }

  void _nextStep() {
    // 1. Determine Final Brand
    final finalBrand = _selectedBrand == 'Other' 
        ? _customBrandController.text.trim() 
        : _selectedBrand;

    // 2. Determine Final Model
    final finalModel = (_selectedBrand == 'Other' || _selectedModel == 'Other') 
        ? _customModelController.text.trim() 
        : _selectedModel;

    // 3. Validation
    if (finalBrand != null && finalBrand.isNotEmpty && 
        finalModel != null && finalModel.isNotEmpty) {
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Step3ConditionSpecsPage(
            category: widget.category,
            onNext: (data) {
              // Combine brand/model with specs and pass to parent
              final combinedData = {
                'brand': finalBrand,
                'model': finalModel,
                ...data
              };
              widget.onNext(combinedData);
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in Brand and Model")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the list of models for the selected brand, default to empty list if not found
    // If "Other" brand is selected, we don't show the dropdown at all (logic handled below)
    final modelsList = _models[_selectedBrand] ?? [];

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("List Your Device", style: context.textTheme.titleLarge),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: 2 / 5,
            backgroundColor: context.lightGrey,
            valueColor: AlwaysStoppedAnimation(context.primaryColor),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Step 2 of 5", style: context.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text("Device Details", style: context.textTheme.headlineSmall),
                  const SizedBox(height: 32),

                  // 1. BRAND SELECTION
                  Text("Brand *", style: context.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _brands.length,
                    itemBuilder: (context, index) {
                      final brand = _brands[index];
                      final isSelected = _selectedBrand == brand['name'];
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBrand = brand['name'];
                            _selectedModel = null;
                            _customBrandController.clear();
                            _customModelController.clear();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? context.primaryColor : context.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? context.primaryColor : context.borderColor,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                brand['icon'], 
                                color: isSelected ? Colors.white : context.greyText,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                brand['name'],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : context.darkText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Custom Brand Input
                  if (_selectedBrand == 'Other') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _customBrandController,
                      decoration: InputDecoration(
                        labelText: "Enter Brand Name",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: context.lightGrey,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 2. MODEL SELECTION
                  if (_selectedBrand != null) ...[
                    Text("Model *", style: context.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    
                    if (_selectedBrand == 'Other') 
                      // If Brand is "Other", Model must be typed manually
                      TextField(
                        controller: _customModelController,
                        decoration: InputDecoration(
                          labelText: "Enter Model Name",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: context.lightGrey,
                        ),
                      )
                    else 
                      // If Brand is selected, show Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: context.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedModel,
                                hint: Text("Select Model", style: context.textTheme.bodyMedium),
                                isExpanded: true,
                                dropdownColor: context.cardBackground,
                                // ✅ FIX: Use the list directly since it already contains 'Other'
                                items: modelsList.map((model) {
                                  return DropdownMenuItem(
                                    value: model,
                                    child: Text(model, style: context.textTheme.bodyLarge),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedModel = value;
                                    if (value != 'Other') {
                                      _customModelController.text = '';
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          
                          // Custom Model Input if "Other" selected in dropdown
                          if (_selectedModel == 'Other') ...[
                            const SizedBox(height: 16),
                            TextField(
                              controller: _customModelController,
                              decoration: InputDecoration(
                                labelText: "Enter Model Name",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: context.lightGrey,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
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
                  onPressed: _selectedBrand != null ? _nextStep : null,
                  child: const Text("Next"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}