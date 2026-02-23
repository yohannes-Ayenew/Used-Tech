// lib/common/widgets/bottom_bar.dart

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

// lib/common/widgets/bottom_bar.dart

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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is AuthSuccess;

        print('🔐 BottomBar building - isAuthenticated: $isAuthenticated');
        if (isAuthenticated) {
          final user = (state).user;
          print('👤 User: ${user.email}, verified: ${user.isEmailVerified}');
        }

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
    );
  }
}
