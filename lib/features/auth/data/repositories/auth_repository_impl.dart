// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await remoteDataSource.login(email, password);
      final user = UserModel.fromJson(response['user']);
      await localDataSource.cacheToken(response['token']);
      await localDataSource.cacheUser(user);
      return Right({'user': user, 'token': response['token']});
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      return Right({
        'userId': response['userId'],
        'message': response['message'],
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyOtp(
    String userId,
    String otp,
  ) async {
    try {
      final response = await remoteDataSource.verifyOtp(userId, otp);
      final user = UserModel.fromJson(response['user']);
      await localDataSource.cacheToken(response['token']);
      await localDataSource.cacheUser(user);
      return Right({'user': user, 'token': response['token']});
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> checkAuthStatus() async {
    try {
      final token = await localDataSource.getLastToken();
      if (token != null && token.isNotEmpty) {
        final cachedUser = await localDataSource.getCachedUser();
        if (cachedUser != null) {
          return Right(cachedUser);
        }
        return await getUserProfile();
      } else {
        return Left(ServerFailure('No token found'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserProfile() async {
    try {
      final response = await remoteDataSource.getUserProfile();
      final user = UserModel.fromJson(response['data']);
      await localDataSource.cacheUser(user);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final response = await remoteDataSource.updateProfile(
        name: name,
        phone: phone,
      );
      final user = UserModel.fromJson(response['data']);
      await localDataSource.cacheUser(user);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String userId,
    required String token,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        userId: userId,
        token: token,
        newPassword: newPassword,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestVerification({
    required File imageFile,
  }) async {
    try {
      await remoteDataSource.requestVerification(imageFile: imageFile);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
