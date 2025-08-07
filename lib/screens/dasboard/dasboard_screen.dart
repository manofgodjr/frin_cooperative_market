// lib/screens/dashboard_screen.dart

import 'package:cooperative_market/logs/logger/logs.dart';
import 'package:cooperative_market/logs/user_message_snackbar.dart';
import 'package:cooperative_market/screens/savings/savings_screen.dart';
import 'package:cooperative_market/state_management/appstate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

// The main dashboard screen for authenticated users. This is a StatefulWidget
// to handle navigation.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // List of screens for the BottomNavigationBar
  final List<Widget> _screens = [
    _DashboardContent(),
    SavingsScreen(),
    // Placeholder for other screens
    const Center(child: Text('Marketplace Screen')),
    const Center(child: Text('Profile Screen')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Dashboard' : 'Savings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => appState.logout(),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Savings'),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

// The content of the main dashboard, refactored into its own class
class _DashboardContent extends StatelessWidget {
  // Fetches user data (profile and transactions) from the Django backend API.
  Future<Map<String, dynamic>> _fetchUserData(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    const String baseUrl = 'http://127.0.0.1:8000/api';
    const String profileUrl = '$baseUrl/profile/';
    const String transactionsUrl = '$baseUrl/transactions/';

    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${appState.authToken}',
    };

    printLog('Fetching user data from $profileUrl');
    printLog('Fetching transactions from $transactionsUrl');

    try {
      final profileResponse = await http.get(
        Uri.parse(profileUrl),
        headers: headers,
      );
      final transactionsResponse = await http.get(
        Uri.parse(transactionsUrl),
        headers: headers,
      );

      if (!context.mounted) return {};

      printLog('Profile response status: ${profileResponse.statusCode}');
      printLog(
        'Transactions response status: ${transactionsResponse.statusCode}',
      );

      if (profileResponse.statusCode == 200 &&
          transactionsResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body);
        final transactionsData = jsonDecode(transactionsResponse.body);

        // Log the successful responses
        printLog('Profile data: $profileData');
        printLog('Transactions data: $transactionsData');

        return {
          'name': profileData['username'] ?? 'User',
          // Assuming a balance field is part of the profile or a separate API.
          // For now, we'll use a hardcoded value to avoid a separate call.
          'balance': 15000.50,
          'recentTransactions': transactionsData,
        };
      } else {
        // Handle API error case
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      if (!context.mounted) return {};
      printLog('Error fetching user data: $e');
      MessageSnackbar(
        message: 'Failed to connect to the server or load user data.',
        isError: true,
      );
      throw Exception('Failed to connect to the server or load user data.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchUserData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final userData = snapshot.data as Map<String, dynamic>;
          final recentTransactions =
              userData['recentTransactions'] as List<dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${userData['name']}!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                _buildBalanceCard(context, userData['balance']),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildRecentTransactions(context, recentTransactions),
              ],
            ),
          );
        }
        return const Center(child: Text('No data found.'));
      },
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance) {
    return Card(
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Balance',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '₦${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionCard(
              context,
              Icons.request_quote,
              'Apply for Loan',
              Colors.orange,
            ),
            _buildActionCard(
              context,
              Icons.history,
              'View Transactions',
              Colors.blue,
            ),
            _buildActionCard(
              context,
              Icons.account_balance_wallet,
              'View Savings',
              Colors.green,
            ),
            _buildActionCard(
              context,
              Icons.store,
              'Marketplace',
              Colors.yellow.shade700,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          MessageSnackbar(message: '$title not yet implemented');
        },
        child: Card(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 30),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    List<dynamic> transactions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Column(
            children:
                transactions.map((tx) {
                  return ListTile(
                    leading: Icon(
                      tx['amount'] > 0 ? Icons.add_circle : Icons.remove_circle,
                      color: tx['amount'] > 0 ? Colors.green : Colors.red,
                    ),
                    title: Text(tx['description']),
                    subtitle: Text(tx['date']),
                    trailing: Text(
                      '₦${tx['amount'].toStringAsFixed(2)}',
                      style: TextStyle(
                        color: tx['amount'] > 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
