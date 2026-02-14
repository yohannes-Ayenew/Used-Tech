// lib/common/widgets/bottom_bar.dart

import 'package:flutter/material.dart';
import '../../core/utils/auth_guard.dart';
import '../../core/constants/global_variables.dart';
import '../../features/product/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/search_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart'; // Import Profile Page

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
    const SearchPage(), // Index 1: Search
    const Center(child: Text('Sell Page')), // Index 2: Sell (Placeholder)
    const Center(child: Text('Inbox Page')), // Index 3: Inbox (Placeholder)
    const ProfilePage(), // Index 4: Profile (Guest Mode)
  ];

  void updatePage(int page) {
    // Inbox (Index 3) might require login - you can adjust based on your needs
    if (page == 3) {
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
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Sell',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
