import 'package:flutter/material.dart';

import '../free_tips/free_tips_screen.dart';
import '../settings/settings_screen.dart';
import '../vip_tips/vip_tips_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int index = 0;

  final pages = const [
    FreeTipsScreen(),
    VipTipsScreen(),
    SettingsScreen(),
  ];

  final destinations = const [
    NavigationDestination(icon: Icon(Icons.lock_open), label: 'Free Tips'),
    NavigationDestination(icon: Icon(Icons.workspace_premium), label: 'VIP'),
    NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: destinations,
      ),
    );
  }
}
