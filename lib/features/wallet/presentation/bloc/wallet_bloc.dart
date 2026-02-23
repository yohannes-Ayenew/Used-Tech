// lib/features/wallet/presentation/bloc/wallet_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletInitial()) {
    on<GetWalletBalanceEvent>(_onGetWalletBalance);
    on<GetTransactionHistoryEvent>(_onGetTransactionHistory);
    on<WithdrawFundsEvent>(_onWithdrawFunds);
    on<DepositFundsEvent>(_onDepositFunds);
  }

  Future<void> _onGetWalletBalance(
    GetWalletBalanceEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      // TODO: Implement get wallet balance
      // final balance = await walletRepository.getBalance();
      // final pending = await walletRepository.getPendingBalance();
      emit(WalletBalanceLoaded(balance: 12500, pendingBalance: 3200));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onGetTransactionHistory(
    GetTransactionHistoryEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      // TODO: Implement get transaction history
      // final transactions = await walletRepository.getTransactions(
      //   limit: event.limit,
      //   offset: event.offset,
      // );
      // final hasMore = transactions.length == (event.limit ?? 20);
      emit(const TransactionsLoaded([], hasMore: false));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onWithdrawFunds(
    WithdrawFundsEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      // TODO: Implement withdraw funds
      // final withdrawal = await walletRepository.requestWithdrawal(
      //   amount: event.amount,
      //   bankName: event.bankName,
      //   accountNumber: event.accountNumber,
      // );
      emit(
        WithdrawalInitiated(withdrawalId: 'wd_123456', amount: event.amount),
      );
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onDepositFunds(
    DepositFundsEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      // TODO: Implement deposit funds (Chapa integration)
      // final paymentUrl = await walletRepository.initiateDeposit(event.amount);
      emit(
        DepositInitiated(
          paymentUrl: 'https://checkout.chapa.co/...',
          amount: event.amount,
        ),
      );
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}
