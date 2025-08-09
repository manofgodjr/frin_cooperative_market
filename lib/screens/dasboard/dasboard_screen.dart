// lib/screens/dashboard_screen.dart

import 'package:cooperative_market/logs/logger/logs.dart';
import 'package:cooperative_market/logs/user_message_snackbar.dart';
import 'package:cooperative_market/state_management/appstate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- START OF CHANGES ---
  // UPDATED: A function to fetch dashboard data from the new backend API endpoint.
  Future<Map<String, dynamic>> _fetchDashboardData(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    const String baseUrl = 'http://127.0.0.1:8000/api';
    const String dashboardUrl = '$baseUrl/dashboard_summary/';

    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${appState.authToken}',
    };

    printLog('Fetching dashboard data from $dashboardUrl');

    try {
      final response = await http.get(
        Uri.parse(dashboardUrl),
        headers: headers,
      );
      if (!context.mounted) return {};
      printLog('Dashboard response status: ${response.statusCode}');
      printLog('Dashboard response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      if (!context.mounted) return {};
      printLog('Error fetching dashboard data: $e');
      MessageSnackbar(message: 'Failed to load dashboard data.', isError: true);
      // Placeholder data in case of an error during API call
      return {
        'balance': 0.00,
        'total_savings': 0.00,
        'last_transaction': {'description': 'No transactions', 'amount': 0.00},
      };
    }
  }
  // --- END OF CHANGES ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: FutureBuilder(
        future: _fetchDashboardData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data as Map<String, dynamic>;
            final balance = data['balance'] as double;
            final totalSavings = data['total_savings'] as double;
            final lastTransaction =
                data['last_transaction'] as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Balance',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₦${balance.toStringAsFixed(2)}',
                            style: Theme.of(
                              context,
                            ).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Savings',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₦${totalSavings.toStringAsFixed(2)}',
                            style: Theme.of(
                              context,
                            ).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Transaction',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${lastTransaction['description']}: ₦${lastTransaction['amount'].toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No data found.'));
        },
      ),
    );
  }
}
