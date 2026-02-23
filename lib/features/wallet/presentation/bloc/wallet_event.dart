// lib/features/wallet/presentation/bloc/wallet_event.dart

import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object> get props => [];
}

class GetWalletBalanceEvent extends WalletEvent {}

class GetTransactionHistoryEvent extends WalletEvent {
  final int? limit;
  final int? offset;
  const GetTransactionHistoryEvent({this.limit, this.offset});

  @override
  List<Object> get props => [
        if (limit != null) limit!,
        if (offset != null) offset!,
      ];
}

class WithdrawFundsEvent extends WalletEvent {
  final double amount;
  final String bankName;
  final String accountNumber;
  const WithdrawFundsEvent({
    required this.amount,
    required this.bankName,
    required this.accountNumber,
  });

  @override
  List<Object> get props => [amount, bankName, accountNumber];
}

class DepositFundsEvent extends WalletEvent {
  final double amount;
  const DepositFundsEvent({required this.amount});

  @override
  List<Object> get props => [amount];
}
