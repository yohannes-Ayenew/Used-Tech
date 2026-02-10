import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await remoteDataSource.login(email, password);
      await localDataSource.cacheToken(user.token);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ✅ NEW: Check if user is already logged in
  @override
  Future<Either<Failure, UserEntity>> checkAuthStatus() async {
    try {
      final token = await localDataSource.getLastToken();
      if (token != null && token.isNotEmpty) {
        // For MVP, we recreate a minimal user entity with the token.
        // In a real app, you might call an API '/users/me' here to get full details.
        return Right(
          UserEntity(id: '', name: '', email: '', role: '', token: token),
        );
      } else {
        return Left(ServerFailure('No token found'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
