import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/auth_guard.dart';
import '../../core/theme/theme_extensions.dart';
import '../../features/product/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/search_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/authenticated_profile_page.dart';
import '../../features/sell/presentation/pages/sell_page.dart';
import '../../features/inbox/presentation/pages/inbox_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class BottomBar extends StatefulWidget {
  static const String routeName = '/actual-home';
  final int? initialTab;

  const BottomBar({super.key, this.initialTab});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  late int _page;

  @override
  void initState() {
    super.initState();
    _page = widget.initialTab ?? 0;
    print('📱 BottomBar initialized with tab: $_page');
  }

  @override
  void didUpdateWidget(covariant BottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update tab if initialTab changes
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _page = widget.initialTab!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Wrap everything in BlocListener to listen for ONE-TIME events (Errors/Success)
    // This runs even if the Auth Bottom Sheet is closed.
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state is AuthSuccess) {
          // 💡 IMPROVEMENT: Only show "Welcome back" if we are the current route.
          // This prevents duplicate snackbars when EditProfilePage/etc are on top.
          if (ModalRoute.of(context)?.isCurrent == true) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Welcome back, ${state.user.name}!"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      listenWhen: (previous, current) {
        // 🚀 CRITICAL: Only fire "Welcome back" if we wasn't already logged in.
        // This prevents the snackbar from showing up on every profile update.
        if (current is AuthSuccess && previous is! AuthSuccess) {
          return true;
        }
        if (current is AuthFailure) return true;
        return false;
      },
      // 2. BlocBuilder handles building the UI based on state (Authenticated vs Guest)
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isAuthenticated = state is AuthSuccess;
          
          // Debug prints
          // print('🔍 BottomBar building - isAuthenticated: $isAuthenticated');
          // if (isAuthenticated) {
          //   final user = (state).user;
          //   print('👤 User: ${user.email}');
          // }

          return Scaffold(
            body: IndexedStack(
              index: _page,
              children: [
                const HomePage(),
                const SearchPage(),
                const SellPage(),
                const InboxPage(),
                isAuthenticated
                    ? const AuthenticatedProfilePage()
                    : const ProfilePage(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _page,
              selectedItemColor: context.primaryColor,
              unselectedItemColor: context.greyText,
              backgroundColor: context.cardBackground,
              iconSize: 24,
              onTap: (index) {
                // Protect Sell (2) and Inbox (3) tabs
                if (index == 2 || index == 3) {
                  authGuard(context, () {
                    setState(() {
                      _page = index;
                    });
                  });
                } else {
                  setState(() {
                    _page = index;
                  });
                }
              },
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  label: 'Sell',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_outlined),
                  label: 'Inbox',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}