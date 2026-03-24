// lib/features/wallet/presentation/widgets/deposit_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/global_variables.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';

class DepositBottomSheet extends StatefulWidget {
  const DepositBottomSheet({super.key});

  @override
  State<DepositBottomSheet> createState() => _DepositBottomSheetState();
}

class _DepositBottomSheetState extends State<DepositBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final List<double> _quickAmounts = [500, 1000, 2000, 5000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Deposit Funds",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.darkText),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: context.greyText),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Enter the amount you'd like to add to your available balance.",
            style: TextStyle(color: context.greyText, fontSize: 13),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.darkText),
            decoration: InputDecoration(
              hintText: "0.00",
              hintStyle: TextStyle(color: context.greyText),
              prefixText: "ETB ",
              prefixStyle: TextStyle(color: context.darkText),
              filled: true,
              fillColor: context.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            children: _quickAmounts.map((amount) {
              return ActionChip(
                label: Text("+$amount", style: TextStyle(color: context.primaryColor)),
                backgroundColor: context.primaryColor.withOpacity(0.05),
                onPressed: () {
                  setState(() {
                    _amountController.text = amount.toStringAsFixed(0);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 0;
                if (amount > 0) {
                  context.read<WalletBloc>().add(InitializeDepositEvent(amount));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Proceed to Payment",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: Opacity(
              opacity: 0.5,
              child: Image.network(
                "https://chapa.co/wp-content/uploads/2022/07/Chapa-Logo-1.png",
                height: 20,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
