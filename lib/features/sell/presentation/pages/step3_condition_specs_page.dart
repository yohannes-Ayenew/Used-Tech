// lib/features/sell/presentation/pages/step3_condition_specs_page.dart

import 'package:flutter/material.dart';
import 'package:used_tech_client/core/constants/global_variables.dart';

class Step3ConditionSpecsPage extends StatefulWidget {
  final String category;
  final Function(Map<String, dynamic>) onNext;

  const Step3ConditionSpecsPage({
    super.key,
    required this.category,
    required this.onNext,
  });

  @override
  State<Step3ConditionSpecsPage> createState() =>
      _Step3ConditionSpecsPageState();
}

class _Step3ConditionSpecsPageState extends State<Step3ConditionSpecsPage> {
  String? _selectedCondition;
  String? _selectedStorage;
  String? _selectedRam;
  String? _selectedProcessor;

  final List<Map<String, dynamic>> _conditions = [
    {
      'value': 'new',
      'label': 'Brand New',
      'desc': 'Sealed box, never used',
      'color': Colors.green,
    },
    {
      'value': 'like new',
      'label': 'Like New',
      'desc': 'Open box, no scratches',
      'color': Colors.teal,
    },
    {
      'value': 'good',
      'label': 'Good',
      'desc': 'Minor scratches, fully functional',
      'color': Colors.blue,
    },
    {
      'value': 'fair',
      'label': 'Fair',
      'desc': 'Visible wear/dents, fully functional',
      'color': Colors.orange,
    },
    {
      'value': 'for parts',
      'label': 'For Parts',
      'desc': 'Broken/Defective',
      'color': Colors.red,
    },
  ];

  late final List<String> _storageOptions;
  late final List<String> _ramOptions;
  late final List<String> _processorOptions;

  @override
  void initState() {
    super.initState();
    _initializeOptions();
  }

  void _initializeOptions() {
    switch (widget.category) {
      case 'mobile':
        _storageOptions = ['64GB', '128GB', '256GB', '512GB', '1TB'];
        _ramOptions = ['4GB', '6GB', '8GB', '12GB', '16GB'];
        _processorOptions = [];
        break;
      case 'laptop':
        _storageOptions = ['256GB', '512GB', '1TB', '2TB'];
        _ramOptions = ['8GB', '16GB', '32GB', '64GB'];
        _processorOptions = [
          'i3',
          'i5',
          'i7',
          'i9',
          'Ryzen 3',
          'Ryzen 5',
          'Ryzen 7',
          'Ryzen 9',
          'M1',
          'M2',
        ];
        break;
      case 'tablet':
        _storageOptions = ['64GB', '128GB', '256GB', '512GB'];
        _ramOptions = ['4GB', '6GB', '8GB', '12GB'];
        _processorOptions = [];
        break;
      default:
        _storageOptions = [];
        _ramOptions = [];
        _processorOptions = [];
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
          "Condition & Specs",
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
          LinearProgressIndicator(
            value: 3 / 5,
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
                    "Step 3 of 5",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Device Condition",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Select the condition of your device",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  // Condition Cards
                  ..._conditions.map((condition) {
                    final isSelected = _selectedCondition == condition['value'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCondition = condition['value'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? condition['color'].withValues(alpha: 0.05)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? condition['color']
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: condition['color'].withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getConditionIcon(condition['value']),
                                color: condition['color'],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    condition['label'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: condition['color'],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    condition['desc'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: condition['color'],
                              ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Storage Options
                  if (_storageOptions.isNotEmpty) ...[
                    const Text(
                      "Storage",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: _storageOptions.map((storage) {
                        final isSelected = _selectedStorage == storage;
                        return ChoiceChip(
                          label: Text(storage),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStorage = storage;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: GlobalVariables.primaryTeal,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? GlobalVariables.primaryTeal
                                : Colors.grey.shade300,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // RAM Options
                  if (_ramOptions.isNotEmpty) ...[
                    const Text(
                      "RAM",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: _ramOptions.map((ram) {
                        final isSelected = _selectedRam == ram;
                        return ChoiceChip(
                          label: Text(ram),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedRam = ram;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: GlobalVariables.primaryTeal,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? GlobalVariables.primaryTeal
                                : Colors.grey.shade300,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Processor Options (for laptops)
                  if (_processorOptions.isNotEmpty) ...[
                    const Text(
                      "Processor",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: _processorOptions.map((processor) {
                        final isSelected = _selectedProcessor == processor;
                        return ChoiceChip(
                          label: Text(processor),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedProcessor = processor;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: GlobalVariables.primaryTeal,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? GlobalVariables.primaryTeal
                                : Colors.grey.shade300,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
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
                  onPressed: _isValid()
                      ? () {
                          widget.onNext({
                            'condition': _selectedCondition,
                            'storage': _selectedStorage,
                            'ram': _selectedRam,
                            'processor': _selectedProcessor,
                          });
                        }
                      : null,
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

  bool _isValid() {
    if (_selectedCondition == null) return false;
    if (widget.category == 'laptop') {
      return _selectedStorage != null &&
          _selectedRam != null &&
          _selectedProcessor != null;
    }
    if (widget.category == 'mobile' || widget.category == 'tablet') {
      return _selectedStorage != null && _selectedRam != null;
    }
    return false;
  }

  IconData _getConditionIcon(String condition) {
    switch (condition) {
      case 'new':
        return Icons.new_releases;
      case 'like new':
        return Icons.star;
      case 'good':
        return Icons.thumb_up;
      case 'fair':
        return Icons.autorenew;
      case 'for parts':
        return Icons.build;
      default:
        return Icons.devices;
    }
  }
}
