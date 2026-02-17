// lib/features/sell/presentation/pages/step2_brand_model_page.dart

import 'package:flutter/material.dart';
import 'package:used_tech_client/core/constants/global_variables.dart';

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

  // Brand data based on category
  late final List<Map<String, dynamic>> _brands;
  late final Map<String, List<String>> _models;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    switch (widget.category) {
      case 'mobile':
        _brands = const [
          {'name': 'Apple', 'icon': '🍎', 'popular': true},
          {'name': 'Samsung', 'icon': '📱', 'popular': true},
          {'name': 'Xiaomi', 'icon': '📱', 'popular': true},
          {'name': 'Huawei', 'icon': '📱'},
          {'name': 'Tecno', 'icon': '📱'},
          {'name': 'Infinix', 'icon': '📱'},
          {'name': 'Oppo', 'icon': '📱'},
          {'name': 'Vivo', 'icon': '📱'},
          {'name': 'Nokia', 'icon': '📱'},
          {'name': 'Google Pixel', 'icon': '📱'},
          {'name': 'OnePlus', 'icon': '📱'},
        ];
        _models = {
          'Apple': [
            'iPhone 14 Pro Max',
            'iPhone 14 Pro',
            'iPhone 14',
            'iPhone 13 Pro Max',
            'iPhone 13 Pro',
            'iPhone 13',
            'iPhone 12 Pro Max',
            'iPhone 12 Pro',
            'iPhone 12',
            'iPhone SE',
          ],
          'Samsung': [
            'Galaxy S23 Ultra',
            'Galaxy S23+',
            'Galaxy S23',
            'Galaxy S22 Ultra',
            'Galaxy S22+',
            'Galaxy S22',
            'Galaxy Note 20',
            'Galaxy A54',
            'Galaxy A34',
            'Galaxy A14',
          ],
          'Xiaomi': [
            'Xiaomi 13 Pro',
            'Xiaomi 13',
            'Redmi Note 12 Pro',
            'Redmi Note 12',
            'Redmi Note 11',
            'Poco X5',
            'Poco F4',
            'Mi 11',
          ],
          'Huawei': ['P60 Pro', 'P50 Pro', 'Mate 50 Pro', 'Nova 11', 'Nova 10'],
          'Tecno': [
            'Camon 20 Pro',
            'Camon 19',
            'Spark 10 Pro',
            'Spark 9',
            'Pop 7',
          ],
          'Infinix': ['Note 30 Pro', 'Note 30', 'Zero 20', 'Hot 30', 'Smart 7'],
          'Oppo': ['Find X5 Pro', 'Reno 10', 'Reno 8', 'A78', 'A58'],
          'Vivo': ['X90 Pro', 'V27', 'Y100', 'Y36'],
          'Nokia': ['G22', 'G21', 'X30', 'C32'],
          'Google Pixel': ['Pixel 7 Pro', 'Pixel 7', 'Pixel 6a', 'Pixel 6'],
          'OnePlus': [
            'OnePlus 11',
            'OnePlus 10 Pro',
            'OnePlus Nord',
            'OnePlus 9',
          ],
        };
        break;

      case 'laptop':
        _brands = const [
          {'name': 'Apple', 'icon': '💻', 'popular': true},
          {'name': 'Dell', 'icon': '💻', 'popular': true},
          {'name': 'HP', 'icon': '💻', 'popular': true},
          {'name': 'Lenovo', 'icon': '💻', 'popular': true},
          {'name': 'Acer', 'icon': '💻'},
          {'name': 'Asus', 'icon': '💻'},
          {'name': 'MSI', 'icon': '💻'},
          {'name': 'Microsoft', 'icon': '💻'},
          {'name': 'Razer', 'icon': '💻'},
          {'name': 'Samsung', 'icon': '💻'},
        ];
        _models = {
          'Apple': [
            'MacBook Pro 16"',
            'MacBook Pro 14"',
            'MacBook Air 15"',
            'MacBook Air 13"',
            'MacBook Pro 13"',
          ],
          'Dell': [
            'XPS 15',
            'XPS 13',
            'Inspiron 15',
            'Inspiron 14',
            'Latitude 7430',
            'Precision Workstation',
          ],
          'HP': [
            'Spectre x360',
            'Envy 15',
            'Pavilion 15',
            'Pavilion 14',
            'Omen 16',
            'EliteBook',
          ],
          'Lenovo': [
            'ThinkPad X1 Carbon',
            'ThinkPad T14',
            'IdeaPad 5',
            'Legion 5 Pro',
            'Yoga 9i',
          ],
          'Acer': ['Swift 3', 'Aspire 5', 'Predator Helios', 'Nitro 5'],
          'Asus': ['ZenBook 14', 'VivoBook 15', 'ROG Zephyrus', 'TUF Gaming'],
          'MSI': ['Stealth 15', 'Raider GE78', 'Pulse 15', 'Cyborg 15'],
          'Microsoft': ['Surface Laptop 5', 'Surface Pro 9', 'Surface Book 3'],
          'Razer': ['Blade 15', 'Blade 14', 'Blade Stealth 13'],
          'Samsung': ['Galaxy Book3 Ultra', 'Galaxy Book3 Pro', 'Galaxy Book2'],
        };
        break;

      case 'tablet':
        _brands = const [
          {'name': 'Apple', 'icon': '📱', 'popular': true},
          {'name': 'Samsung', 'icon': '📱', 'popular': true},
          {'name': 'Amazon', 'icon': '📱'},
          {'name': 'Lenovo', 'icon': '📱'},
          {'name': 'Huawei', 'icon': '📱'},
          {'name': 'Xiaomi', 'icon': '📱'},
        ];
        _models = {
          'Apple': [
            'iPad Pro 12.9"',
            'iPad Pro 11"',
            'iPad Air 5',
            'iPad 10th Gen',
            'iPad mini 6',
          ],
          'Samsung': [
            'Galaxy Tab S9 Ultra',
            'Galaxy Tab S9+',
            'Galaxy Tab S9',
            'Galaxy Tab A8',
            'Galaxy Tab S6 Lite',
          ],
          'Amazon': ['Fire Max 11', 'Fire HD 10', 'Fire HD 8', 'Fire 7'],
          'Lenovo': ['Tab P12 Pro', 'Tab P11', 'Tab M10', 'Tab M8'],
          'Huawei': ['MatePad Pro', 'MatePad 11', 'MediaPad T5'],
          'Xiaomi': ['Pad 6', 'Pad 5', 'Redmi Pad'],
        };
        break;

      default:
        _brands = [];
        _models = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Select Brand & Model",
          style: TextStyle(
            fontSize: 18,
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
          // Progress indicator
          LinearProgressIndicator(
            value: 2 / 5,
            backgroundColor: GlobalVariables.lightGrey,
            valueColor: AlwaysStoppedAnimation(GlobalVariables.primaryTeal),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Step 2 of 5",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "What brand and model?",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Select the brand and model of your ${widget.category}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  // Brand Selection
                  const Text(
                    "Brand",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Popular brands first
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _brands.map((brand) {
                      final isSelected = _selectedBrand == brand['name'];
                      return FilterChip(
                        selected: isSelected,
                        label: Text(brand['name']),
                        avatar: Text(brand['icon']),
                        showCheckmark: false,
                        backgroundColor: Colors.white,
                        selectedColor: GlobalVariables.primaryTeal.withValues(
                          alpha: 0.1,
                        ),
                        checkmarkColor: GlobalVariables.primaryTeal,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? GlobalVariables.primaryTeal
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? GlobalVariables.primaryTeal
                              : Colors.grey.shade300,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedBrand = brand['name'];
                            _selectedModel = null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  if (_selectedBrand != null) ...[
                    const SizedBox(height: 24),

                    // Model Selection
                    const Text(
                      "Model",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: _models[_selectedBrand]!.map((model) {
                          final isSelected = _selectedModel == model;
                          return ListTile(
                            title: Text(model),
                            leading: Radio<String>(
                              value: model,
                              groupValue: _selectedModel,
                              activeColor: GlobalVariables.primaryTeal,
                              onChanged: (value) {
                                setState(() {
                                  _selectedModel = value;
                                });
                              },
                            ),
                            tileColor: isSelected
                                ? GlobalVariables.primaryTeal.withValues(
                                    alpha: 0.05,
                                  )
                                : null,
                          );
                        }).toList(),
                      ),
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
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedModel == null
                      ? null
                      : () {
                          widget.onNext({
                            'brand': _selectedBrand,
                            'model': _selectedModel,
                          });
                        },
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
