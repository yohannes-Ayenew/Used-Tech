// lib/features/wallet/domain/repositories/wallet_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';

abstract class WalletRepository {
  Future<Either<Failure, Map<String, double>>> getBalances();
  Future<Either<Failure, List<TransactionEntity>>> getTransactionHistory();
  Future<Either<Failure, Unit>> requestWithdrawal({
    required double amount,
    required String bankName,
    required String accountNumber,
  });
  Future<Either<Failure, String>> initializeDeposit(double amount);
}
