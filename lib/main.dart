import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/features/auth/presentation/pages/login_page.dart';
import 'package:used_tech_client/features/product/presentation/pages/product_detail_page.dart';
import 'package:used_tech_client/features/product/presentation/pages/search_page.dart';
import 'common/widgets/bottom_bar.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Used Tech Market',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const BottomBar(),
          '/search': (context) => const SearchPage(),
          '/product-detail': (context) => const ProductDetailPage(),
          '/login': (context) => const LoginPage(),
        },
        // home: const BottomBar(), // Remove this line if using routes
      ),
    );
  }
}
