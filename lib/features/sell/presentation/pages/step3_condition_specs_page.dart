import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/app_theme_extensions.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import '../bloc/sell_bloc.dart';
import 'step4_images_page.dart';

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
  int _batteryHealth = 100;

  final List<Map<String, dynamic>> _conditions = [
    {'title': 'Brand New', 'desc': 'Sealed box', 'val': 'New'},
    {'title': 'Like New', 'desc': 'Open box, no scratches', 'val': 'Like New'},
    {'title': 'Good', 'desc': 'Minor scratches, fully functional', 'val': 'Good'},
    {'title': 'Fair', 'desc': 'Visible wear/dents, fully functional', 'val': 'Fair'},
    {'title': 'For Parts', 'desc': 'Broken/Defective', 'val': 'Broken'},
  ];

  void _nextStep() {
    if (_selectedCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select device condition")),
      );
      return;
    }
    if (_selectedStorage == null || _selectedRam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Storage and RAM")),
      );
      return;
    }

    // 🚀 Close keyboard
    FocusScope.of(context).unfocus();

    final Map<String, dynamic> specs = {
      'condition': _selectedCondition,
      'storage': _selectedStorage,
      'ram': _selectedRam,
    };

    if (widget.category == 'mobile' || widget.category == 'tablet') {
      specs['batteryHealth'] = _batteryHealth;
    }

    if (widget.category == 'laptop') {
      specs['processor'] = _selectedProcessor;
    }

    // 📥 Update Bloc
    context.read<SellBloc>().add(UpdateSellDataEvent(specs));

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Step4ImagesPage(onNext: (_) {})),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> storageOpts = [
      '64GB',
      '128GB',
      '256GB',
      '512GB',
      '1TB',
    ];
    List<String> ramOpts = ['4GB', '6GB', '8GB', '12GB', '16GB'];

    if (widget.category == 'laptop') {
      storageOpts = ['256GB SSD', '512GB SSD', '1TB SSD', '2TB SSD'];
      ramOpts = ['8GB', '16GB', '24GB', '32GB', '64GB'];
    }

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Specs & Condition", style: context.textTheme.titleLarge),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: context.lightGrey,
            valueColor: AlwaysStoppedAnimation(context.primaryColor),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Step 3 of 5", style: context.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text("Details", style: context.textTheme.headlineSmall),
                  const SizedBox(height: 32),
                  
                  // Battery Health for Mobiles
                  if (widget.category == 'mobile' || widget.category == 'tablet') ...[
                    Text("Battery Health: $_batteryHealth%", style: context.textTheme.titleMedium),
                    Slider(
                      value: _batteryHealth.toDouble(),
                      min: 50,
                      max: 100,
                      divisions: 50,
                      label: "$_batteryHealth%",
                      activeColor: context.primaryColor,
                      onChanged: (double value) {
                        setState(() {
                          _batteryHealth = value.toInt();
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Processor for Laptops
                  if (widget.category == 'laptop') ...[
                    Text("Processor *", style: context.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      value: _selectedProcessor,
                      hint: "Select Processor",
                      items: ['Intel Core i3', 'Intel Core i5', 'Intel Core i7', 'Intel Core i9', 'Apple M1', 'Apple M2', 'Apple M3', 'Ryzen 5', 'Ryzen 7', 'Ryzen 9'],
                      onChanged: (v) => setState(() => _selectedProcessor = v),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text("Condition *", style: context.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ..._conditions.map((c) => _buildConditionCard(c)),
                  
                  const SizedBox(height: 24),
                  Text("Storage *", style: context.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: storageOpts
                        .map(
                          (o) => _buildChip(
                            o,
                            _selectedStorage,
                            (v) => setState(() => _selectedStorage = v),
                          ),
                        )
                        .toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  Text("RAM *", style: context.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: ramOpts
                        .map(
                          (o) => _buildChip(
                            o,
                            _selectedRam,
                            (v) => setState(() => _selectedRam = v),
                          ),
                        )
                        .toList(),
                  ),
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
                  onPressed: (_selectedCondition == null || _selectedStorage == null || _selectedRam == null) ? null : _nextStep,
                  child: const Text("Next"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String? value, required String hint, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: context.textTheme.bodyMedium),
          isExpanded: true,
          dropdownColor: context.cardBackground,
          items: items.map((o) => DropdownMenuItem(value: o, child: Text(o, style: context.textTheme.bodyLarge))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildChip(String label, String? selected, Function(String) onSelect) {
    return ChoiceChip(
      label: Text(label),
      selected: selected == label,
      onSelected: (val) => onSelect(label),
      selectedColor: context.primaryColor,
      backgroundColor: context.cardBackground,
      labelStyle: TextStyle(
        color: selected == label ? Colors.white : context.darkText,
      ),
    );
  }

  Widget _buildTextInput(TextEditingController ctrl, String hint) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Theme.of(context).extension<AppColors>()?.lightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildConditionCard(Map<String, dynamic> item) {
    final isSelected = _selectedCondition == item['val'];
    return GestureDetector(
      onTap: () => setState(() => _selectedCondition = item['val']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.primaryColor : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? context.primaryColor
                          : context.darkText,
                    ),
                  ),
                  Text(item['desc'], style: context.textTheme.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: context.primaryColor),
          ],
        ),
      ),
    );
  }
}
