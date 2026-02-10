import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/login_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final CheckAuthStatus checkAuthStatus; // <--- NEW

  AuthBloc({required this.loginUser, required this.checkAuthStatus})
    : super(AuthInitial()) {
    on<LoginRequestedEvent>(_onLoginRequested);
    on<AppStartedEvent>(_onAppStarted);
  }

  Future<void> _onLoginRequested(
    LoginRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUser(event.email, event.password);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  // ✅ NEW: Check token on startup
  Future<void> _onAppStarted(
    AppStartedEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await checkAuthStatus();
    result.fold(
      (failure) => emit(AuthGuest()), // Failed to get token -> Guest
      (user) => emit(AuthSuccess(user)), // Token found -> Success
    );
  }
}
