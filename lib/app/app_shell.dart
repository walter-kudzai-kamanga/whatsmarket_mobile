import 'package:flutter/material.dart';

import '../core/auth/session.dart';
import '../features/auth/auth_screen.dart';
import '../features/history/history_screen.dart';
import '../features/home/home_screen.dart';
import '../features/marketplace/marketplace_screen.dart';
import '../features/profile/profile_screen.dart';
import '../widgets/app_bottom_nav_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final Session _session = Session();
  bool _checking = true;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final t = await _session.token;
    if (!mounted) return;
    setState(() {
      _signedIn = t != null;
      _checking = false;
    });
  }

  void _handleSignedIn() {
    setState(() {
      _signedIn = true;
      _currentIndex = 0;
    });
  }

  void _handleLoggedOut() {
    setState(() {
      _signedIn = false;
      _currentIndex = 0;
    });
  }

  void _handleTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_signedIn) {
      return AuthScreen(onSignedIn: _handleSignedIn);
    }

    final pages = <Widget>[
      const HomeScreen(),
      const MarketplaceScreen(),
      const HistoryScreen(),
      ProfileScreen(onLoggedOut: _handleLoggedOut),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _handleTabSelected,
      ),
    );
  }
}
