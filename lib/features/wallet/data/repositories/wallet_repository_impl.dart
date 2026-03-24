// lib/features/wallet/data/repositories/wallet_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, double>>> getBalances() async {
    try {
      final balances = await remoteDataSource.getBalances();
      return Right(balances);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionHistory() async {
    try {
      final maps = await remoteDataSource.getTransactionHistory();
      // For now we map empty or simulated data
      final transactions = maps.map((json) => TransactionEntity(
        id: json['id'] ?? '',
        type: _parseType(json['type']),
        status: _parseStatus(json['status']),
        amount: (json['amount'] ?? 0).toDouble(),
        description: json['description'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
      )).toList();
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> requestWithdrawal({
    required double amount,
    required String bankName,
    required String accountNumber,
  }) async {
    try {
      await remoteDataSource.requestWithdrawal(
        amount: amount,
        bankName: bankName,
        accountNumber: accountNumber,
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> initializeDeposit(double amount) async {
    try {
      final checkoutUrl = await remoteDataSource.initializeDeposit(amount);
      return Right(checkoutUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  TransactionType _parseType(String? type) {
    switch (type) {
      case 'DEPOSIT': return TransactionType.deposit;
      case 'WITHDRAWAL': return TransactionType.withdrawal;
      case 'SALE': return TransactionType.saleEarning;
      default: return TransactionType.deposit;
    }
  }

  TransactionStatus _parseStatus(String? status) {
    switch (status) {
      case 'SUCCESS': return TransactionStatus.success;
      case 'FAILED': return TransactionStatus.failed;
      default: return TransactionStatus.pending;
    }
  }
}
