// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:image_picker/image_picker.dart';

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/enums/kyc_status.dart';
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
  Future<Either<Failure, Map<String, dynamic>>> signInWithGoogle() async {
    try {
      final response = await remoteDataSource.signInWithGoogle();

      if (response.containsKey('token') && response.containsKey('user')) {
        final user = UserModel.fromJson(response['user']);
        await localDataSource.cacheToken(response['token']);
        await localDataSource.cacheUser(user);
        return Right({'user': user, 'token': response['token']});
      }
      return Left(ServerFailure('Invalid response from server'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await remoteDataSource.login(email, password);

      // If login successful with token
      if (response.containsKey('token') && response.containsKey('user')) {
        final user = UserModel.fromJson(response['user']);

        if (user.isEmailVerified) {
          await localDataSource.cacheToken(response['token']);
          await localDataSource.cacheUser(user);
        } else {
          // Don't cache token for unverified users
          return Right({
            'requiresVerification': true,
            'userId': user.id,
            'message': 'Please verify your email first',
          });
        }

        return Right({'user': user, 'token': response['token']});
      }

      // If email verification required
      if (response.containsKey('requiresVerification')) {
        return Right({
          'requiresVerification': true,
          'userId': response['userId'],
          'message': response['message'],
        });
      }

      return Left(ServerFailure('Unexpected response format'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await remoteDataSource.signup(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      // Registration successful - verification required
      if (response.containsKey('userId')) {
        return Right({
          'userId': response['userId'],
          'message': response['message'],
          'requiresVerification': true,
        });
      }

      return Left(ServerFailure('Unexpected response format'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyEmail(
    String userId,
    String otp,
  ) async {
    try {
      final response = await remoteDataSource.verifyEmail(userId, otp);

      if (response.containsKey('token') && response.containsKey('user')) {
        final user = UserModel.fromJson(response['user']);

        await localDataSource.cacheToken(response['token']);
        await localDataSource.cacheUser(user);

        return Right({'user': user, 'token': response['token']});
      }

      return Left(ServerFailure('Verification failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> resendOTP(String email) async {
    try {
      final response = await remoteDataSource.resendOTP(email);
      return Right({'message': response['message']});
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> forgotPassword(
    String email,
  ) async {
    try {
      final response = await remoteDataSource.forgotPassword(email);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await remoteDataSource.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      return Right(response);
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

        if (cachedUser != null && cachedUser.isEmailVerified) {
          return Right(cachedUser);
        } else if (cachedUser != null && !cachedUser.isEmailVerified) {
          // User exists but email not verified - clear token and force re-login
          await localDataSource.logout();
          return Left(ServerFailure('Email not verified'));
        }
      }
      return Left(ServerFailure('No authenticated user'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserProfile() async {
    try {
      final response = await remoteDataSource.getUserProfile();
      final user = UserModel.fromJson(response);
      
      // CRITICAL: Update the local cache with new data (Approved Status)
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
    XFile? profileImage,
  }) async {
    try {
      final response = await remoteDataSource.updateProfile(
        name: name,
        phone: phone,
        profileImage: profileImage,
      );
      final user = UserModel.fromJson(response);
      
      // Update local cache
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
      print('📝 AuthRepositoryImpl.changePassword called');
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      print('✅ Password changed successfully in repository');
      return const Right(null);
    } catch (e) {
      print('❌ Change password error in repository: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestVerification({
    required XFile frontImage,
    required XFile backImage,
    required XFile faceImage,
  }) async {
    try {
      await remoteDataSource.requestVerification(
        frontImage: frontImage,
        backImage: backImage,
        faceImage: faceImage,
      );

      // OPTIONAL: Update local cached user status to PENDING so UI updates immediately
      final currentUser = await localDataSource.getCachedUser();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(kycStatus: KycStatus.pending);
        await localDataSource.cacheUser(updatedUser as UserModel);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.logout();
      await remoteDataSource.logout();  
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
