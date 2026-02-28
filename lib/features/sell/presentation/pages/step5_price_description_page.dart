// lib/features/sell/presentation/pages/step5_price_description_page.dart

import 'package:flutter/material.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sell_bloc.dart';
import '../bloc/sell_event.dart';
import '../bloc/sell_state.dart';

class Step5PriceDescriptionPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const Step5PriceDescriptionPage({super.key, required this.onSubmit});

  @override
  State<Step5PriceDescriptionPage> createState() => _Step5PriceDescriptionPageState();
}

class _Step5PriceDescriptionPageState extends State<Step5PriceDescriptionPage> {
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  void _submit() {
    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a price.')));
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid price.')));
      return;
    }

    // Cache final data
    context.read<SellBloc>().add(CacheDraftListingEvent({
      'price': price,
      'description': _descController.text,
    }));

    // Trigger submission
    context.read<SellBloc>().add(const SubmitListingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text("Review & Publish", style: context.textTheme.titleLarge)),
      body: BlocConsumer<SellBloc, SellState>(
        listener: (context, state) {
          if (state is SellError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ListingCreated) {
            // Navigate back to success page
            Navigator.of(context).pushNamedAndRemoveUntil('/success', (route) => false);
          }
        },
        builder: (context, state) {
          final isLoading = state is SellLoading;
          
          return Column(
            children: [
              LinearProgressIndicator(
                value: 1.0, // 100%
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
                      Text("Set Price", style: context.textTheme.headlineSmall),
                      const SizedBox(height: 32),

                      // Price Input
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: "Price (ETB)",
                          prefixIcon: const Icon(Icons.attach_money),
                          suffixText: "ETB",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("💡 Suggested price: 45,000 - 50,000 ETB", style: TextStyle(color: Colors.orange[700], fontSize: 12)),

                      const SizedBox(height: 24),

                      // Description
                      TextField(
                        controller: _descController,
                        maxLines: 4,
                        minLines: 4,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          labelText: "Description",
                          hintText: "Describe scratches, battery health...",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Publish Button
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
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Publish Listing"),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}