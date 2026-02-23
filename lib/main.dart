// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'common/widgets/bottom_bar.dart';
import 'common/widgets/splash_screen.dart';
import 'core/theme/theme_bloc.dart';
import 'core/theme/app_themes.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/auth/presentation/pages/email_verification_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/profile/presentation/pages/settings_page.dart';
import 'features/sell/presentation/pages/sell_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(AppStartedEvent())),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Used Tech Market',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: context.read<ThemeCubit>().themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) {
                // Get initial tab from arguments
                final args = ModalRoute.of(context)?.settings.arguments;
                int initialTab = 0;

                if (args != null && args is Map<String, dynamic>) {
                  initialTab = args['initialTab'] ?? 0;
                }

                return BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const SplashScreen();
                    }
                    return BottomBar(initialTab: initialTab);
                  },
                );
              },
              '/login': (context) => const LoginPage(),
              '/signup': (context) => const SignupPage(),
              '/sell': (context) => const SellPage(),
              '/email-verification': (context) => const EmailVerificationPage(
                userId: '',
                email: '',
                message: '',
              ),
              '/forgot-password': (context) => const ForgotPasswordPage(),
              '/reset-password': (context) {
                // Get arguments from route settings
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;

                if (args != null) {
                  return ResetPasswordPage(
                    userId: args['userId'] ?? '',
                    token: args['token'] ?? '',
                    email: args['email'] ?? '',
                  );
                }

                // Fallback if no arguments provided
                return const ResetPasswordPage(
                  userId: '',
                  token: '',
                  email: '',
                );
              },
              '/settings': (context) => const SettingsPage(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/email-verification' &&
                  settings.arguments != null) {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => EmailVerificationPage(
                    userId: args['userId'],
                    email: args['email'],
                    message: args['message'],
                  ),
                );
              }
              if (settings.name == '/reset-password' &&
                  settings.arguments != null) {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => ResetPasswordPage(
                    userId: args['userId'] ?? '',
                    token: args['token'] ?? '',
                    email: args['email'] ?? '',
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
