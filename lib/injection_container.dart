// lib/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:used_tech_client/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:used_tech_client/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:used_tech_client/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:used_tech_client/features/auth/domain/repositories/auth_repository.dart';

// Use Cases
import 'package:used_tech_client/features/auth/domain/usecases/login_user.dart';
import 'package:used_tech_client/features/auth/domain/usecases/signup_user.dart';
import 'package:used_tech_client/features/auth/domain/usecases/verify_email.dart';
import 'package:used_tech_client/features/auth/domain/usecases/resend_otp.dart';
import 'package:used_tech_client/features/auth/domain/usecases/check_auth_status.dart';
import 'package:used_tech_client/features/auth/domain/usecases/forgot_password.dart';
import 'package:used_tech_client/features/auth/domain/usecases/reset_password.dart';
import 'package:used_tech_client/features/auth/domain/usecases/update_profile.dart';
import 'package:used_tech_client/features/auth/domain/usecases/change_password.dart';
import 'package:used_tech_client/features/auth/domain/usecases/request_verification.dart';
import 'package:used_tech_client/features/auth/domain/usecases/get_user_profile.dart';

// Bloc
import 'package:used_tech_client/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
     () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => SignupUser(sl()));
  sl.registerLazySingleton(() => VerifyEmail(sl()));
  sl.registerLazySingleton(() => ResendOTP(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => ChangePassword(sl()));
  sl.registerLazySingleton(() => RequestVerification(sl()));
  sl.registerLazySingleton(() => GetUserProfile(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUser: sl(),
      signupUser: sl(),
      verifyEmail: sl(),
      resendOTP: sl(),
      checkAuthStatus: sl(),
      forgotPassword: sl(),
      resetPassword: sl(),
    ),
  );
}