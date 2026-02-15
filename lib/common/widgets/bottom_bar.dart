// lib/common/widgets/bottom_bar.dart

import 'package:flutter/material.dart';
import '../../core/utils/auth_guard.dart';
import '../../core/constants/global_variables.dart';
import '../../features/product/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/search_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/sell/presentation/pages/sell_page.dart';
import '../../features/inbox/presentation/pages/inbox_page.dart';

class BottomBar extends StatefulWidget {
  static const String routeName = '/actual-home';
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _page = 0;

  List<Widget> pages = [
    const HomePage(), // Index 0: Home
    const SearchPage(), // Index 1: Search
    const SellPage(), // Index 2: Sell
    const InboxPage(), // Index 3: Inbox
    const ProfilePage(), // Index 4: Profile
  ];

  void updatePage(int page) {
    // Pages that require login: Sell (2) and Inbox (3)
    if (page == 2 || page == 3) {
      authGuard(context, () {
        setState(() {
          _page = page;
        });
      });
    } else {
      setState(() {
        _page = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_page],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        selectedItemColor: GlobalVariables.primaryTeal,
        unselectedItemColor: GlobalVariables.greyText,
        backgroundColor: Colors.white,
        iconSize: 24,
        onTap: updatePage,
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
  }
}
