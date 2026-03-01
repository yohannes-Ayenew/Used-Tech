// lib/features/sell/presentation/pages/step5_price_description_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import '../bloc/sell_bloc.dart';

class Step5PriceDescriptionPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const Step5PriceDescriptionPage({super.key, required this.onSubmit});

  @override
  State<Step5PriceDescriptionPage> createState() =>
      _Step5PriceDescriptionPageState();
}

class _Step5PriceDescriptionPageState extends State<Step5PriceDescriptionPage> {
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  void _submit() {
    final priceText = _priceController.text.trim();
    if (priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a price")),
      );
      return;
    }

    final price = int.tryParse(priceText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid price")),
      );
      return;
    }

    // 🚀 Close keyboard
    FocusScope.of(context).unfocus();

    // 1. Update Bloc with final fields
    context.read<SellBloc>().add(
      UpdateSellDataEvent({
        'price': price,
        'description': _descController.text.trim(),
      }),
    );

    // 2. Submit everything
    context.read<SellBloc>().add(SubmitListingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SellBloc, SellState>(
      listener: (context, state) {
        if (state is SellSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Listing Published Successfully!")),
          );
          // Go Home
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        } else if (state is SellFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text("Review & Publish", style: context.textTheme.titleLarge),
        ),
        body: BlocBuilder<SellBloc, SellState>(
          builder: (context, state) {
            final isLoading = state is SellLoading;

            return Column(
              children: [
                LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: context.lightGrey,
                  valueColor: AlwaysStoppedAnimation(context.primaryColor),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Step 5 of 5", style: context.textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Text(
                          "Set Price",
                          style: context.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: "Price (ETB)",
                            prefixIcon: const Icon(Icons.attach_money),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _descController,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            labelText: "Description",
                            hintText: "Describe scratches, battery health...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Publish Listing"),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
