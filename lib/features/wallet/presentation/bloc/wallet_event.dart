// lib/features/wallet/presentation/bloc/wallet_event.dart

import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class GetWalletDataEvent extends WalletEvent {}

class RequestWithdrawalEvent extends WalletEvent {
  final double amount;
  final String bankName;
  final String accountNumber;

  const RequestWithdrawalEvent({
    required this.amount,
    required this.bankName,
    required this.accountNumber,
  });

  @override
  List<Object?> get props => [amount, bankName, accountNumber];
}

class InitializeDepositEvent extends WalletEvent {
  final double amount;
  const InitializeDepositEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}
