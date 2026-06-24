import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerNavBar extends StatelessWidget {
  const CustomerNavBar({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        switch (i) {
          case 0:
            context.go('/customer/home');
          case 1:
            context.go('/customer/search');
          case 2:
            context.go('/customer/queue');
          case 3:
            context.go('/customer/profile');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
          icon: Icon(Icons.hourglass_top_outlined),
          label: 'Queue',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
