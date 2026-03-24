// lib/features/wallet/presentation/pages/wallet_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/global_variables.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../../domain/entities/transaction_entity.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(GetWalletDataEvent());
  }

  void _showWithdrawOptions(BuildContext context) async {
    final method = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WithdrawBottomSheet(),
    );

    if (method != null && context.mounted) {
      _showWithdrawalForm(context, method);
    }
  }

  void _showWithdrawalForm(BuildContext context, String method) {
    final amountController = TextEditingController();
    final accountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Withdraw via $method", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.darkText)),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount (ETB)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: accountController,
              decoration: InputDecoration(
                labelText: method == "Telebirr" ? "Phone Number" : "Account Number",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount > 0 && accountController.text.isNotEmpty) {
                    context.read<WalletBloc>().add(RequestWithdrawalEvent(
                      amount: amount,
                      bankName: method,
                      accountNumber: accountController.text,
                    ));
                    Navigator.pop(modalContext);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Confirm Withdrawal"),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
          if (state is WithdrawalSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<WalletBloc>().add(GetWalletDataEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. TEAL HEADER & BALANCE CARD ---
                    _buildHeader(context, state),

                    // --- 2. ACTION BUTTONS ---
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildActionButton(Icons.call_made, "Withdraw", Colors.orange, () => _showWithdrawOptions(this.context)),
                            _buildActionButton(Icons.history, "History", GlobalVariables.primaryTeal, () {}),
                            _buildActionButton(Icons.credit_card, "Payment", Colors.purple, () {}),
                          ],
                        ),
                      ),
                    ),

                    // --- 3. TRANSACTION HISTORY ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Transaction History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.darkText)),
                          const SizedBox(height: 15),
                          _buildRecentTransactions(state),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WalletLoaded state) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 40),
      decoration: BoxDecoration(
        color: context.primaryColor,
      ),
      child: Column(
        children: [
          // App Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                ),
              ),
              const Text(
                "Wallet",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // The Balance Card (Outlined)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Available Balance", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatAmount(state.availableBalance),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 5),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text("ETB", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Divider(color: Colors.white.withOpacity(0.2), height: 1),
                const SizedBox(height: 15),
                const Text("Pending Balance (Escrow)", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatAmount(state.escrowBalance),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 5),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 2.0),
                      child: Text("ETB", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text("Will be released after order completion", style: TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Widget _buildActionButton(IconData icon, String label, Color iconColor, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderColor),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.darkText)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(WalletLoaded state) {
    if (state.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Icons.history_toggle_off, size: 48, color: context.greyText.withOpacity(0.3)),
              const SizedBox(height: 10),
              Text("No transactions yet", style: TextStyle(color: context.greyText)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.transactions.length,
      itemBuilder: (context, index) {
        final tx = state.transactions[index];
        return _buildTransactionItem(
          title: tx.description,
          date: _formatDate(tx.createdAt),
          amount: tx.formattedAmount,
          isIncome: tx.type != TransactionType.withdrawal && tx.type != TransactionType.purchaseHold,
          status: tx.status.displayName,
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "Today";
    }
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildTransactionItem({
    required String title,
    required String date,
    required String amount,
    required bool isIncome,
    required String status,
  }) {
    Color amountColor = isIncome ? GlobalVariables.successGreen : Colors.red;
    IconData icon = isIncome ? Icons.trending_up : Icons.call_made;
    Color iconBgColor = isIncome ? GlobalVariables.successGreen.withOpacity(0.1) : Colors.purple.withOpacity(0.1);
    Color iconColor = isIncome ? GlobalVariables.successGreen : Colors.purple;

    Color statusBgColor;
    Color statusTextColor;
    IconData statusIcon;

    if (status == "Success") {
      statusBgColor = GlobalVariables.successGreen.withOpacity(0.1);
      statusTextColor = GlobalVariables.successGreen;
      statusIcon = Icons.check_circle_outline;
    } else if (status == "Pending") {
      statusBgColor = Colors.orange.withOpacity(0.1);
      statusTextColor = Colors.orange;
      statusIcon = Icons.access_time;
    } else {
      statusBgColor = Colors.red.withOpacity(0.1);
      statusTextColor = Colors.red;
      statusIcon = Icons.cancel_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(date, style: TextStyle(color: context.greyText, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: amountColor)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusTextColor, size: 10),
                    const SizedBox(width: 4),
                    Text(status, style: TextStyle(color: statusTextColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WithdrawBottomSheet extends StatelessWidget {
  const WithdrawBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Text("Select Method", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.darkText)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: context.greyText),
              )
            ],
          ),
          const SizedBox(height: 15),
          _buildMethodOption(
            context,
            icon: Icons.phone_android_outlined,
            iconColor: Colors.blue,
            title: "Telebirr",
            subtitle: "Mobile money transfer",
            onTap: () {
              Navigator.pop(context, "Telebirr");
            },
          ),
          const SizedBox(height: 12),
          _buildMethodOption(
            context,
            icon: Icons.account_balance_outlined,
            iconColor: GlobalVariables.successGreen,
            title: "Bank Transfer",
            subtitle: "Direct to bank account",
            onTap: () {
               Navigator.pop(context, "Bank Transfer");
            },
          ),
          const SizedBox(height: 30),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, size: 14, color: context.greyText),
                const SizedBox(width: 4),
                Text("Powered by Chapa", style: TextStyle(color: context.greyText, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildMethodOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: context.borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.darkText)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: context.greyText, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.greyText),
          ],
        ),
      ),
    );
  }
}
