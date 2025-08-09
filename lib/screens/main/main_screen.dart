// lib/screens/main_screen.dart

import 'package:cooperative_market/screens/dasboard/dasboard_screen.dart';
import 'package:cooperative_market/screens/market/market_place.dart';
import 'package:cooperative_market/screens/profile/profile_screen.dart';
import 'package:cooperative_market/screens/savings/savings_screen.dart';
import 'package:cooperative_market/screens/transactions/transaction_history_screen.dart';
import 'package:cooperative_market/state_management/appstate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // --- START OF CHANGES ---
  // UPDATED: Added the new DashboardScreen to the list of screens as the first item
  static final List<Widget> _screens = <Widget>[
    const DashboardScreen(),
    const SavingsScreen(),
    const MarketplaceScreen(),
    const TransactionHistoryScreen(),
    const ProfileScreen(),
  ];
  // --- END OF CHANGES ---

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final String currentUserName = appState.currentUser?.username ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $currentUserName'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              appState.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // --- START OF CHANGES ---
          // UPDATED: New bottom navigation item for Dashboard
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          // --- END OF CHANGES ---
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Savings'),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
