// lib/features/sell/presentation/pages/step2_brand_model_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import '../bloc/sell_bloc.dart';
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
    if (widget.category == 'mobile' || widget.category == 'tablet') {
      _brands = [
        {'name': 'Apple', 'icon': Icons.apple},
        {'name': 'Samsung', 'icon': Icons.phone_android},
        {'name': 'Xiaomi', 'icon': Icons.phone_android},
        {'name': 'Google', 'icon': Icons.android},
        {'name': 'Huawei', 'icon': Icons.phone_android},
        {'name': 'Tecno', 'icon': Icons.phone_android},
        {'name': 'Infinix', 'icon': Icons.phone_android},
        {'name': 'Itel', 'icon': Icons.phone_android},
        {'name': 'Oppo', 'icon': Icons.phone_android},
        {'name': 'Realme', 'icon': Icons.phone_android},
        {'name': 'OnePlus', 'icon': Icons.phone_android},
        {'name': 'Sony', 'icon': Icons.phone_android},
      ];
      _models = {
        'Apple': [
          'iPhone 15 Pro Max', 'iPhone 15 Pro', 'iPhone 15 Plus', 'iPhone 15',
          'iPhone 14 Pro Max', 'iPhone 14 Pro', 'iPhone 14',
          'iPhone 13 Pro Max', 'iPhone 13 Pro', 'iPhone 13',
          'iPhone 12 Pro Max', 'iPhone 12', 'iPhone 11', 'iPhone SE (2022)',
          'iPad Pro M4', 'iPad Pro M2', 'iPad Air 5', 'iPad Mini 6',
        ],
        'Samsung': [
          'Galaxy S24 Ultra', 'Galaxy S23 Ultra', 'Galaxy S22 Ultra', 'Galaxy S21 FE',
          'Galaxy Z Fold 5', 'Galaxy Z Flip 5',
          'Galaxy A54 5G', 'Galaxy A34 5G', 'Galaxy A14', 'Galaxy A05s',
          'Galaxy M54', 'Galaxy Tab S9 Ultra',
        ],
        'Xiaomi': [
          'Xiaomi 14 Ultra', 'Xiaomi 13T Pro', 'Redmi Note 13 Pro+', 'Redmi Note 13',
          'Redmi Note 12', 'Redmi 13C', 'Poco F5', 'Poco X6 Pro', 'Poco M6 Pro',
        ],
        'Tecno': [
          'Phantom V Fold', 'Phantom X2 Pro', 'Camon 30 Premier', 'Camon 30 Pro',
          'Spark 20 Pro+', 'Spark 10 Pro', 'Pova 5 Pro', 'Pop 8',
        ],
        'Infinix': [
          'Zero 30 5G', 'Note 40 Pro', 'Note 30 VIP', 'Hot 40 Pro', 'Smart 8 Pro',
          'GT 10 Pro', 'Note 12 G96',
        ],
        'Itel': [
          'S23+', 'P55+', 'A70', 'P40', 'S18',
        ],
        'Google': [
          'Pixel 8 Pro', 'Pixel 7 Pro', 'Pixel 6a', 'Pixel Fold',
        ],
        'Huawei': [
          'P60 Pro', 'Mate 60 Pro', 'Nova 11i', 'Y9a',
        ],
      };
    } else {
      _brands = [
        {'name': 'Apple', 'icon': Icons.apple},
        {'name': 'Dell', 'icon': Icons.laptop},
        {'name': 'HP', 'icon': Icons.laptop},
        {'name': 'Lenovo', 'icon': Icons.laptop},
        {'name': 'Asus', 'icon': Icons.laptop},
        {'name': 'Acer', 'icon': Icons.laptop},
        {'name': 'Microsoft', 'icon': Icons.laptop},
        {'name': 'MSI', 'icon': Icons.laptop},
        {'name': 'Razer', 'icon': Icons.laptop},
      ];
      _models = {
        'Apple': [
          'MacBook Pro M3 Max (16")', 'MacBook Pro M3 (14")', 'MacBook Air M3',
          'MacBook Pro M2', 'MacBook Air M2', 'MacBook Air M1', 'iMac M3',
        ],
        'Dell': [
          'XPS 15 9530', 'XPS 13 Plus', 'Latitude 7440', 'Precision 5570',
          'Inspiron 16 Plus', 'Alienware m18 R1', 'G15 Gaming',
        ],
        'HP': [
          'Spectre x360 14', 'Envy x360', 'Pavilion Plus 14', 'Victus 16',
          'Omen 17', 'EliteBook 840 G10', 'ProBook 450 G9',
        ],
        'Lenovo': [
          'ThinkPad X1 Carbon Gen 11', 'Legion Pro 7i', 'Yoga 9i Gen 8',
          'IdeaPad Slim 5', 'ThinkBook 14 Gen 4',
        ],
        'Asus': [
          'ROG Zephyrus G14', 'Zenbook 14X OLED', 'Vivobook S 15',
          'TUF Gaming F15', 'ProArt Studiobook',
        ],
        'Microsoft': [
          'Surface Pro 9', 'Surface Laptop 5', 'Surface Studio 2+', 'Surface Go 3',
        ],
      };
    }
  }

  void _nextStep() {
    if (_selectedBrand != null &&
        _selectedBrand!.isNotEmpty &&
        _selectedModel != null &&
        _selectedModel!.isNotEmpty) {
      FocusScope.of(context).unfocus();

      context.read<SellBloc>().add(
        UpdateSellDataEvent({
          'brand': _selectedBrand,
          'model': _selectedModel,
          'category': widget.category,
        }),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Step3ConditionSpecsPage(
            category: widget.category,
            onNext: (data) {},
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Brand and Model")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final modelsList = _models[_selectedBrand] ?? [];

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("List Your Device", style: context.textTheme.titleLarge),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: 0.4,
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
                  Text(
                    "Device Details",
                    style: context.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 32),
                  Text("Brand *", style: context.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.primaryColor
                                : context.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? context.primaryColor
                                  : context.borderColor,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                brand['icon'],
                                color: isSelected
                                    ? Colors.white
                                    : context.greyText,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                brand['name'],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : context.darkText,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_selectedBrand != null) ...[
                    Text("Model *", style: context.textTheme.titleMedium),
                    const SizedBox(height: 12),
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
                          hint: Text(
                            "Select Model",
                            style: context.textTheme.bodyMedium,
                          ),
                          isExpanded: true,
                          dropdownColor: context.cardBackground,
                          items: (modelsList.isEmpty ? ['Standard Model'] : modelsList).map((model) {
                            return DropdownMenuItem(
                              value: model,
                              child: Text(
                                model,
                                style: context.textTheme.bodyLarge,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedModel = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
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
