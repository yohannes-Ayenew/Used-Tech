// lib/features/sell/presentation/pages/edit_product_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/features/product/domain/entities/product_entity.dart';
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

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.product.title;
    _priceController.text = widget.product.price.toStringAsFixed(0);
    _descController.text = widget.product.description;
    _locationController.text = widget.product.location;

    // Initialize Bloc with existing data
    context.read<SellBloc>().add(InitEditProductEvent(widget.product));
  }

  void _submit() {
    final title = _titleController.text.trim();
    final priceText = _priceController.text.trim();
    final description = _descController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Price are required")),
      );
      return;
    }

    final price = double.tryParse(priceText) ?? 0;

    // 1. Update Bloc data
    context.read<SellBloc>().add(
          UpdateSellDataEvent({
            'title': title,
            'price': price,
            'description': description,
            'location': location,
          }),
        );

    // 2. Trigger Update
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
          Navigator.pop(context, true); // Return true to indicate success
        } else if (state is SellFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text("Edit Listing", style: context.textTheme.titleLarge),
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
                        _buildSectionTitle("General Information"),
                        const SizedBox(height: 16),
                        _buildTextField(_titleController, "Title", Icons.title),
                        const SizedBox(height: 16),
                        _buildTextField(_priceController, "Price (ETB)", Icons.attach_money, isNumber: true),
                        const SizedBox(height: 16),
                        _buildTextField(_locationController, "Location", Icons.location_on),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Description"),
                        const SizedBox(height: 16),
                        _buildTextField(_descController, "Description", Icons.description, isMultiline: true),
                        const SizedBox(height: 32),
                        const Text(
                          "Note: Category and specs modification is coming soon.",
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                        ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isNumber = false, bool isMultiline = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : (isMultiline ? TextInputType.multiline : TextInputType.text),
      maxLines: isMultiline ? 4 : 1,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: context.cardBackground,
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
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Save Changes"),
          ),
        ),
      ),
    );
  }
}
