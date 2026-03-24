// lib/features/wallet/presentation/bloc/wallet_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final double availableBalance;
  final double escrowBalance;
  final List<TransactionEntity> transactions;

  const WalletLoaded({
    required this.availableBalance,
    required this.escrowBalance,
    required this.transactions,
  });

  @override
  List<Object?> get props => [availableBalance, escrowBalance, transactions];
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);
  @override
  List<Object?> get props => [message];
}

class WithdrawalSuccess extends WalletState {
  final String message;
  const WithdrawalSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class InitializeDepositSuccess extends WalletState {
  final String checkoutUrl;
  const InitializeDepositSuccess(this.checkoutUrl);
  @override
  List<Object?> get props => [checkoutUrl];
}
