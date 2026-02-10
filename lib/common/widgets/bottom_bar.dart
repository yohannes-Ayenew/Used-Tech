import 'package:flutter/material.dart';
import '../../core/utils/auth_guard.dart'; // Import AuthGuard

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _page = 0;

  // Placeholder pages for now
  List<Widget> pages = [
    const Center(child: Text('Home (Public)')),
    const Center(child: Text('Cart (Private)')),
    const Center(child: Text('Account (Private)')),
  ];

  void updatePage(int page) {
    // Index 1 (Cart) and 2 (Account) require Login
    if (page == 1 || page == 2) {
      authGuard(context, () {
        setState(() {
          _page = page;
        });
      });
    } else {
      // Home is free
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
        onTap: updatePage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_outlined),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
