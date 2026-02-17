// lib/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Auth Imports
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/signup_user.dart';
import 'features/auth/domain/usecases/verify_otp.dart';
import 'features/auth/domain/usecases/check_auth_status.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- Feature: Auth ---

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUser: sl<LoginUser>(),
      signupUser: sl<SignupUser>(),
      verifyOtp: sl<VerifyOtp>(),
      checkAuthStatus: sl<CheckAuthStatus>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<LoginUser>(() => LoginUser(sl<AuthRepository>()));
  sl.registerLazySingleton<SignupUser>(() => SignupUser(sl<AuthRepository>()));
  sl.registerLazySingleton<VerifyOtp>(() => VerifyOtp(sl<AuthRepository>()));
  sl.registerLazySingleton<CheckAuthStatus>(
    () => CheckAuthStatus(sl<AuthRepository>()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl<http.Client>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<http.Client>(() => http.Client());
}
