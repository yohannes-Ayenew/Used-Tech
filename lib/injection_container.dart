// lib/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:used_tech_client/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:used_tech_client/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:used_tech_client/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:used_tech_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:used_tech_client/features/product/data/datasources/product_remote_data_source.dart';
import 'package:used_tech_client/features/sell/presentation/bloc/sell_bloc.dart';
// Use Cases
import 'package:used_tech_client/features/auth/domain/usecases/login_user.dart';
import 'package:used_tech_client/features/auth/domain/usecases/signin_with_google.dart';
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
import 'package:used_tech_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_bloc.dart';
import 'package:used_tech_client/features/product/presentation/bloc/favorites_bloc.dart';
import 'package:used_tech_client/features/inbox/data/datasources/chat_remote_data_source.dart';
import 'package:used_tech_client/features/inbox/data/repositories/chat_repository_impl.dart';
import 'package:used_tech_client/features/inbox/domain/repositories/chat_repository.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_bloc.dart';
import 'package:used_tech_client/core/services/socket_service.dart';
import 'package:used_tech_client/core/services/notification_service.dart';
import 'package:used_tech_client/core/services/connectivity_service.dart';

// Product Feature Imports
import 'package:used_tech_client/features/product/data/repositories/product_repository_impl.dart';
import 'package:used_tech_client/features/product/domain/repositories/product_repository.dart';
import 'package:used_tech_client/features/product/domain/usecases/create_product.dart';
import 'package:used_tech_client/features/product/domain/usecases/update_product.dart';

// Order Feature Imports
import 'package:used_tech_client/features/order/domain/repositories/order_repository.dart';
import 'package:used_tech_client/features/order/data/repositories/order_repository_impl.dart';
import 'package:used_tech_client/features/order/presentation/bloc/order_bloc.dart';

// Sell Feature Imports

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
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(client: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(client: sl(), sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(),
  );

  // Services
  sl.registerLazySingleton(() => SocketService());
  sl.registerLazySingleton(() => NotificationService(chatRepository: sl()));
  sl.registerLazySingleton(() => ConnectivityService(client: sl()));

  // Use Cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => SignupUser(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => VerifyEmail(sl()));
  sl.registerLazySingleton(() => ResendOTP(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => ChangePassword(sl()));
  sl.registerLazySingleton(() => RequestVerification(sl()));
  sl.registerLazySingleton(() => GetUserProfile(sl()));

  // Product Use Cases
  sl.registerLazySingleton(() => CreateProduct(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));

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
      changePassword: sl(),
      authRepository: sl(),
      socketService: sl(),
    ),
  );

  // Sell Feature
  sl.registerFactory(
    () => SellBloc(
      createProductUseCase: sl(),
      updateProductUseCase: sl(),
    ),
  );

  // Product Bloc
  sl.registerFactory(() => ProductBloc(productRepository: sl()));
  sl.registerFactory(() => FavoritesBloc());
  sl.registerFactory(() => ChatBloc(chatRepository: sl(), socketService: sl()));
  sl.registerFactory(() => OrderBloc(orderRepository: sl()));
}
