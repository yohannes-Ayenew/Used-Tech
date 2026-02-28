import 'package:flutter/material.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/core/theme/app_theme_extensions.dart';
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
  State<Step3ConditionSpecsPage> createState() => _Step3ConditionSpecsPageState();
}

class _Step3ConditionSpecsPageState extends State<Step3ConditionSpecsPage> {
  // Selections
  String? _selectedCondition;
  String? _selectedStorage;
  String? _selectedRam;
  String? _selectedProcessor;
  String? _selectedCore;
  
  // Manual Entry Controllers
  final _storageController = TextEditingController();
  final _ramController = TextEditingController();
  final _generationController = TextEditingController();

  final List<Map<String, dynamic>> _conditions = [
    {'title': 'Brand New', 'desc': 'Sealed, never used', 'val': 'New'},
    {'title': 'Like New', 'desc': 'Minimal use, no scratches', 'val': 'Like New'},
    {'title': 'Good', 'desc': 'Minor scratches, fully functional', 'val': 'Good'},
    {'title': 'Fair', 'desc': 'Visible wear, fully functional', 'val': 'Fair'},
    {'title': 'For Parts', 'desc': 'Broken or defective', 'val': 'Broken'},
  ];

  final List<String> _processorOptions = ['Intel', 'AMD', 'Apple M1/M2', 'Other'];
  final List<String> _coreOptions = ['i3', 'i5', 'i7', 'i9', 'Ryzen 3', 'Ryzen 5', 'Ryzen 7', 'Other'];

  void _nextStep() {
    // Validate required fields
    if (_selectedCondition == null) return;

    // Build Data Map
    final Map<String, dynamic> specs = {
      'condition': _selectedCondition,
      'storage': _selectedStorage == 'Other' ? _storageController.text : _selectedStorage,
      'ram': _selectedRam == 'Other' ? _ramController.text : _selectedRam,
    };

    // Add PC Specifics
    if (widget.category == 'laptop') {
      specs['processor'] = _selectedProcessor;
      specs['core'] = _selectedCore;
      specs['generation'] = _generationController.text;
    }

    widget.onNext(specs);
    
    // Navigate
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Step4ImagesPage(
          onNext: (images) {
            // Logic handled by parent bloc/controller
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define options based on category
    List<String> storageOpts = ['64GB', '128GB', '256GB', '512GB', '1TB', 'Other'];
    List<String> ramOpts = ['4GB', '8GB', '16GB', '32GB', 'Other'];

    if (widget.category == 'laptop') {
      storageOpts = ['256GB SSD', '512GB SSD', '1TB SSD', '1TB HDD', 'Other'];
    }

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text("Specs & Condition", style: context.textTheme.titleLarge)),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: 3 / 5,
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

                  // 1. CONDITION (Required for all)
                  Text("Condition *", style: context.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ..._conditions.map((c) => _buildConditionCard(c)),

                  const SizedBox(height: 24),

                  // 2. STORAGE
                  _buildSectionTitle("Storage *"),
                  _buildChipGroup(storageOpts, _selectedStorage, (val) {
                    setState(() {
                      _selectedStorage = val;
                      if (val != 'Other') _storageController.clear();
                    });
                  }),
                  if (_selectedStorage == 'Other') 
                    _buildTextInput(_storageController, "Enter Storage (e.g. 3TB)"),

                  const SizedBox(height: 24),

                  // 3. RAM
                  _buildSectionTitle("RAM *"),
                  _buildChipGroup(ramOpts, _selectedRam, (val) {
                    setState(() {
                      _selectedRam = val;
                      if (val != 'Other') _ramController.clear();
                    });
                  }),
                  if (_selectedRam == 'Other') 
                    _buildTextInput(_ramController, "Enter RAM (e.g. 12GB)"),

                  // 4. PC SPECIFIC FIELDS (Only if Laptop)
                  if (widget.category == 'laptop') ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Text("Processor Details", style: context.textTheme.titleLarge),
                    const SizedBox(height: 16),

                    // Processor Brand
                    _buildSectionTitle("Processor Type"),
                    _buildChipGroup(_processorOptions, _selectedProcessor, (val) {
                      setState(() => _selectedProcessor = val);
                    }),
                    const SizedBox(height: 16),

                    // Core / Series
                    _buildSectionTitle("Core / Series"),
                    _buildChipGroup(_coreOptions, _selectedCore, (val) {
                      setState(() => _selectedCore = val);
                    }),
                    const SizedBox(height: 16),

                    // Generation (Text Field)
                    _buildSectionTitle("Generation (Optional)"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _generationController,
                      decoration: InputDecoration(
                        hintText: "e.g. 11th Gen, 12th Gen",
                        filled: true,
                        fillColor: context.lightGrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
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
              color: context.cardBackground,
              border: Border(top: BorderSide(color: context.borderColor)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedCondition == null ? null : _nextStep,
                  child: const Text("Next"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildChipGroup(List<String> options, String? selectedValue, Function(String) onSelect) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) => onSelect(option),
          selectedColor: Theme.of(context).extension<AppColors>()?.primaryTeal ?? Colors.teal,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).extension<AppColors>()?.darkText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: Theme.of(context).extension<AppColors>()?.cardBackground,
          side: BorderSide(
            color: isSelected 
              ? Colors.transparent 
              : Theme.of(context).extension<AppColors>()?.borderColor ?? Colors.grey,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextInput(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: TextField(
        controller: controller,
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
    final colors = Theme.of(context).extension<AppColors>();
    
    return GestureDetector(
      onTap: () => setState(() => _selectedCondition = item['val']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors?.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? (colors?.primaryTeal ?? Colors.teal) : (colors?.borderColor ?? Colors.grey),
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
                      color: isSelected ? colors?.primaryTeal : colors?.darkText,
                    )
                  ),
                  const SizedBox(height: 4),
                  Text(item['desc'], style: colors != null ? TextStyle(color: colors.greyText, fontSize: 13) : null),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colors?.primaryTeal),
          ],
        ),
      ),
    );
  }
}