// lib/features/wallet/presentation/bloc/wallet_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc({required this.walletRepository}) : super(WalletInitial()) {
    on<GetWalletDataEvent>(_onGetWalletData);
    on<RequestWithdrawalEvent>(_onRequestWithdrawal);
    on<InitializeDepositEvent>(_onInitializeDeposit);
  }

  Future<void> _onGetWalletData(
    GetWalletDataEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final balanceResult = await walletRepository.getBalances();
    final transactionResult = await walletRepository.getTransactionHistory();

    balanceResult.fold(
      (failure) => emit(WalletError(failure.message)),
      (balances) {
        transactionResult.fold(
          (failure) => emit(WalletError(failure.message)),
          (transactions) => emit(WalletLoaded(
            availableBalance: balances['available'] ?? 0,
            escrowBalance: balances['escrow'] ?? 0,
            transactions: transactions,
          )),
        );
      },
    );
  }

  Future<void> _onRequestWithdrawal(
    RequestWithdrawalEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final result = await walletRepository.requestWithdrawal(
      amount: event.amount,
      bankName: event.bankName,
      accountNumber: event.accountNumber,
    );

    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (_) {
        emit(const WithdrawalSuccess("Withdrawal request submitted successfully"));
        add(GetWalletDataEvent()); // Refresh data
      },
    );
  }

  Future<void> _onInitializeDeposit(
    InitializeDepositEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final result = await walletRepository.initializeDeposit(event.amount);

    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (checkoutUrl) {
        emit(InitializeDepositSuccess(checkoutUrl));
      },
    );
  }
}
