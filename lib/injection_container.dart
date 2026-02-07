import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- Feature: Auth ---

  // Bloc
  sl.registerFactory(() => AuthBloc(loginUser: sl()));

  // Use Cases
  sl.registerLazySingleton(() => LoginUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  // --- External ---
  sl.registerLazySingleton(() => http.Client());
}
