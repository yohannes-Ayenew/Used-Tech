// lib/features/sell/presentation/pages/edit_product_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/features/product/domain/entities/product_entity.dart';
import 'package:used_tech_client/core/constants/api_endpoints.dart';
import '../bloc/sell_bloc.dart';

class EditProductPage extends StatefulWidget {
  final ProductEntity product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  
  // Specs
  final _storageController = TextEditingController();
  final _ramController = TextEditingController();
  final _processorController = TextEditingController();
  final _generationController = TextEditingController();

  ProductCategory? _selectedCategory;
  ProductCondition? _selectedCondition;
  
  // Images
  List<String> _currentImageUrls = [];
  List<File> _newImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.product.title;
    _priceController.text = widget.product.price.toStringAsFixed(0);
    _descController.text = widget.product.description;
    _locationController.text = widget.product.location;
    _brandController.text = widget.product.brand;
    _modelController.text = widget.product.model;
    
    _selectedCategory = widget.product.category;
    _selectedCondition = widget.product.condition;
    _currentImageUrls = List.from(widget.product.images);

    // Specs
    _storageController.text = widget.product.storage ?? '';
    _ramController.text = widget.product.ram ?? '';
    _processorController.text = widget.product.processor ?? '';
    _generationController.text = widget.product.generation ?? '';

    // Initialize Bloc with existing data
    context.read<SellBloc>().add(InitEditProductEvent(widget.product));
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImages.addAll(pickedFiles.map((x) => File(x.path)));
        // If user picks new images, we clear the old ones to follow "replacement" logic for now
        // Or we can allow mixing, but backend is simpler with total replacement
        _currentImageUrls = []; 
      });
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final priceText = _priceController.text.trim();
    final description = _descController.text.trim();
    final location = _locationController.text.trim();
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();

    if (title.isEmpty || priceText.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title, Price, and Category are required")),
      );
      return;
    }
    
    if (_newImages.isEmpty && _currentImageUrls.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide at least one image")),
      );
      return;
    }

    final price = double.tryParse(priceText) ?? 0;

    final Map<String, dynamic> updateData = {
      'title': title,
      'price': price,
      'description': description,
      'location': location,
      'brand': brand,
      'model': model,
      'category': _selectedCategory!.name,
      'condition': _selectedCondition!.name,
      'specs': {
        'storage': _storageController.text.trim(),
        'ram': _ramController.text.trim(),
        'processor': _processorController.text.trim(),
        'generation': _generationController.text.trim(),
      }
    };

    // 1. Update Bloc data
    context.read<SellBloc>().add(UpdateSellDataEvent(updateData));
    
    // 2. Add Images if any
    if (_newImages.isNotEmpty) {
       context.read<SellBloc>().add(AddImagesEvent(_newImages));
    }

    // 3. Trigger Update
    context.read<SellBloc>().add(UpdateProductEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SellBloc, SellState>(
      listener: (context, state) {
        if (state is SellSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Listing Updated Successfully!")),
          );
          Navigator.pop(context, true); 
        } else if (state is SellFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text("Full Edit Listing", style: context.textTheme.titleLarge),
        ),
        body: BlocBuilder<SellBloc, SellState>(
          builder: (context, state) {
            final isLoading = state is SellLoading;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Listing Photos"),
                        const SizedBox(height: 16),
                        _buildImageGallery(),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text("Change / Add Images"),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        _buildSectionTitle("Basic Information"),
                        const SizedBox(height: 16),
                        _buildTextField(_titleController, "Listing Title", Icons.title),
                        const SizedBox(height: 16),
                        _buildCategoryDropdown(),
                        const SizedBox(height: 16),
                        _buildConditionDropdown(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_priceController, "Price (ETB)", Icons.attach_money, isNumber: true)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField(_locationController, "Location", Icons.location_on)),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        _buildSectionTitle("Device Details"),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_brandController, "Brand", Icons.branding_watermark)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField(_modelController, "Model", Icons.model_training)),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        _buildSectionTitle("Technical Specifications"),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_storageController, "Storage", Icons.storage)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField(_ramController, "RAM", Icons.memory)),
                          ],
                        ),
                        if (_selectedCategory == ProductCategory.laptop) ...[
                           const SizedBox(height: 16),
                           _buildTextField(_processorController, "Processor", Icons.settings_input_component),
                           const SizedBox(height: 16),
                           _buildTextField(_generationController, "Generation", Icons.history),
                        ],

                        const SizedBox(height: 32),
                        _buildSectionTitle("Description"),
                        const SizedBox(height: 16),
                        _buildTextField(_descController, "Description", Icons.description, isMultiline: true),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                _buildBottomButton(isLoading),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._currentImageUrls.map((url) => _buildImageThumbnail(url, isUrl: true)),
          ..._newImages.map((file) => _buildImageThumbnail(file, isUrl: false)),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(dynamic source, {required bool isUrl}) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
        image: DecorationImage(
          image: isUrl 
              ? NetworkImage(ApiEndpoints.resolveImageUrl(source as String)) as ImageProvider
              : FileImage(source as File),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isUrl) {
                    _currentImageUrls.remove(source);
                  } else {
                    _newImages.remove(source);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return _buildDropdown(
      "Category", 
      _selectedCategory, 
      ProductCategory.values, 
      (val) => setState(() => _selectedCategory = val),
      (val) => val.displayName,
    );
  }

  Widget _buildConditionDropdown() {
    return _buildDropdown(
      "Condition", 
      _selectedCondition, 
      ProductCondition.values, 
      (val) => setState(() => _selectedCondition = val),
      (val) => val.displayName,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: context.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.primaryColor,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildDropdown<T>(String label, T? selected, List<T> items, Function(T?) onChanged, String Function(T) itemLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.bodySmall),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: selected,
              isExpanded: true,
              items: items.map((T value) {
                return DropdownMenuItem<T>(
                  value: value,
                  child: Text(itemLabel(value)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isNumber = false, bool isMultiline = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : (isMultiline ? TextInputType.multiline : TextInputType.text),
      maxLines: isMultiline ? 4 : 1,
      style: context.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: context.cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildBottomButton(bool isLoading) {
    return Container(
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
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Save Changes"),
          ),
        ),
      ),
    );
  }
}
