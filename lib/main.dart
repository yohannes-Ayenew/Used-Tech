import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';  
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'common/widgets/bottom_bar.dart';
import 'common/widgets/splash_screen.dart';
import 'core/theme/theme_bloc.dart';
import 'core/theme/app_themes.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/product/presentation/bloc/favorites_bloc.dart';
import 'features/product/presentation/bloc/favorites_event.dart';
import 'features/sell/presentation/bloc/sell_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/auth/presentation/pages/email_verification_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/profile/presentation/pages/settings_page.dart';
import 'features/sell/presentation/pages/sell_page.dart';
import 'features/sell/presentation/pages/edit_product_page.dart';
import 'features/sell/presentation/pages/success_page.dart';
import 'features/product/domain/entities/product_entity.dart';
import 'features/product/presentation/pages/collections_page.dart';
import 'features/product/presentation/pages/product_detail_page.dart';
import 'features/product/presentation/pages/favorites_page.dart';
import 'package:used_tech_client/features/order/presentation/pages/active_orders_page.dart';
import 'package:used_tech_client/features/order/presentation/pages/order_details_page.dart';
import 'package:used_tech_client/features/order/presentation/bloc/order_bloc.dart';
import 'features/inbox/presentation/bloc/chat_bloc.dart';
import 'core/services/notification_service.dart';
import 'core/services/connectivity_service.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // 🌐 WEB CONFIGURATION (Using keys you provided)
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCIJH5XcrBuFYU-vvHEK0QmWGzV9QgP7eo",
          authDomain: "used-tech-market.firebaseapp.com",
          projectId: "used-tech-market",
          storageBucket: "used-tech-market.firebasestorage.app",
          messagingSenderId: "440923132786",
          appId: "1:440923132786:web:b11e21908ee28e0817c3eb",
          measurementId: "G-B06BQ79C5V",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  await di.init();
  
  // ⚡ OPTIMIZATION: Initialize non-critical services asynchronously 
  // to prevent blocking the main thread and skipping frames.
  Future.microtask(() async {
    try {
      di.sl<ConnectivityService>().init();
      di.sl<NotificationService>().init();
      print('🚀 Background services (Connectivity/Push) initialized');
    } catch (e) {
      print('⚠️ Error during background initialization: $e');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(AppStartedEvent())),
        BlocProvider(create: (_) => di.sl<ProductBloc>()),
        BlocProvider(create: (_) => di.sl<FavoritesBloc>()..add(LoadFavorites())),
        BlocProvider(create: (_) => di.sl<SellBloc>()),
        BlocProvider(create: (_) => di.sl<ChatBloc>()),
        BlocProvider(create: (_) => di.sl<OrderBloc>()),
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
                final args = ModalRoute.of(context)?.settings.arguments;
                int initialTab = 0;

                if (args != null && args is Map<String, dynamic>) {
                  initialTab = args['initialTab'] ?? 0;
                }

                return BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (previous, current) {
                    // 🚀 MORE ROBUST: Never rebuild the root to SplashScreen if we are already logged in
                    // and just doing a background task (AuthLoading).
                    if (previous is AuthSuccess && current is AuthLoading) {
                      return false;
                    }
                    // Rebuild for fresh login, logout, or initial load
                    return true;
                  },
                  builder: (context, state) {
                    if (state is AuthInitial ||
                        state is AuthLoading && ModalRoute.of(context)?.isCurrent == true) {
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
              // Fixed Reset Password Route logic
              '/reset-password': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                
                if (args is Map<String, dynamic>) {
                  return ResetPasswordPage(
                    userId: args['userId'] ?? '',
                    token: args['token'] ?? '',
                    email: args['email'] ?? '',
                  );
                }
                
                return const ResetPasswordPage(
                  userId: '',
                  token: '',
                  email: '',
                );
              },
              '/settings': (context) => const SettingsPage(),
              '/success': (context) => const SuccessPage(),
              '/collections': (context) => BlocProvider(
                create: (context) => di.sl<ProductBloc>(),
                child: const CollectionsPage(),
              ),
              '/favorites': (context) => const FavoritesPage(),
              '/active-orders': (context) => const ActiveOrdersPage(),
              '/order-details': (context) {
                final orderId = ModalRoute.of(context)!.settings.arguments as String;
                return OrderDetailsPage(orderId: orderId);
              },
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
              // Fallback for reset password if pushNamed is used differently
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
              // Product Detail Route
              if (settings.name == '/product-detail' && settings.arguments != null) {
                final productId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => di.sl<ProductBloc>()..add(GetProductDetailsEvent(productId: productId)),
                    child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                        if (state is ProductLoading) {
                          return const Scaffold(body: Center(child: CircularProgressIndicator()));
                        }
                        if (state is ProductDetailsLoaded) {
                          return ProductDetailPage(product: state.product);
                        }
                        if (state is ProductError) {
                          return Scaffold(body: Center(child: Text(state.message)));
                        }
                        return const Scaffold(body: Center(child: CircularProgressIndicator()));
                      },
                    ),
                  ),
                );
              }
              // Edit Product Route
              if (settings.name == '/edit-product' && settings.arguments != null) {
                final product = settings.arguments as ProductEntity;
                return MaterialPageRoute(
                  builder: (context) => EditProductPage(product: product),
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