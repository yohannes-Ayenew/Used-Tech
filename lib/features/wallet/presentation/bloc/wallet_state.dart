// lib/features/wallet/presentation/bloc/wallet_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletBalanceLoaded extends WalletState {
  final double balance;
  final double pendingBalance;
  const WalletBalanceLoaded({required this.balance, this.pendingBalance = 0});

  @override
  List<Object> get props => [balance, pendingBalance];
}

class TransactionsLoaded extends WalletState {
  final List<TransactionEntity> transactions;
  final bool hasMore;
  const TransactionsLoaded(this.transactions, {this.hasMore = false});

  @override
  List<Object> get props => [transactions, hasMore];
}

class WithdrawalInitiated extends WalletState {
  final String withdrawalId;
  final double amount;
  const WithdrawalInitiated({required this.withdrawalId, required this.amount});

  @override
  List<Object> get props => [withdrawalId, amount];
}

class DepositInitiated extends WalletState {
  final String paymentUrl;
  final double amount;
  const DepositInitiated({required this.paymentUrl, required this.amount});

  @override
  List<Object> get props => [paymentUrl, amount];
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);

  @override
  List<Object> get props => [message];
}
