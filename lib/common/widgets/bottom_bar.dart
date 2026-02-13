// lib/common/widgets/bottom_bar.dart

import 'package:flutter/material.dart';
import '../../core/utils/auth_guard.dart';
import '../../core/constants/global_variables.dart';
import '../../features/product/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/search_page.dart'; // Import Search Page

class BottomBar extends StatefulWidget {
  static const String routeName = '/actual-home';
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _page = 0;

  // List of Screens
  List<Widget> pages = [
    const HomePage(), // Index 0: Home
    const SearchPage(), // Index 1: Search (Replaces Cart)
    const Center(child: Text('Account Page')), // Index 2: Account
  ];

  void updatePage(int page) {
    // Account page (Index 2) requires Login
    if (page == 2) {
      authGuard(context, () {
        setState(() {
          _page = page;
        });
      });
    } else {
      // Home and Search are Public/Guest friendly
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
        iconSize: 28,
        onTap: updatePage,
        type: BottomNavigationBarType.fixed,
        items: const [
          // HOME
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          // SEARCH
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          // ACCOUNT
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
