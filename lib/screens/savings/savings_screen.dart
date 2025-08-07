// lib/screens/savings_screen.dart

import 'package:cooperative_market/logs/logger/logs.dart';
import 'package:cooperative_market/logs/user_message_snackbar.dart';
import 'package:cooperative_market/state_management/appstate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

// New Savings Screen
class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  // A placeholder function to fetch savings goals from the backend
  Future<List<dynamic>> _fetchSavingsGoals(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    const String baseUrl = 'http://127.0.0.1:8000/api';
    const String savingsUrl = '$baseUrl/savings_goals/';

    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${appState.authToken}',
    };

    printLog('Fetching savings goals from $savingsUrl');

    try {
      final response = await http.get(Uri.parse(savingsUrl), headers: headers);
      if (!context.mounted) return [];
      printLog('Savings response status: ${response.statusCode}');
      printLog('Savings response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load savings goals');
      }
    } catch (e) {
      if (!context.mounted) return [];
      printLog('Error fetching savings goals: $e');
      MessageSnackbar(message: 'Failed to load savings goals.', isError: true);
      // Placeholder data in case of error
      return [
        {
          'id': 1,
          'goalName': 'New Car',
          'targetAmount': 500000.00,
          'savedAmount': 150000.00,
        },
        {
          'id': 2,
          'goalName': 'House Down Payment',
          'targetAmount': 2000000.00,
          'savedAmount': 25000.00,
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Action to add a new goal
          MessageSnackbar(message: 'Adding a new goal is not yet implemented');
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Goal', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder(
        future: _fetchSavingsGoals(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final goals = snapshot.data as List<dynamic>;
            if (goals.isEmpty) {
              return const Center(child: Text('No savings goals found.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return _buildSavingsGoalCard(context, goal);
              },
            );
          }
          return const Center(child: Text('No data found.'));
        },
      ),
    );
  }

  Widget _buildSavingsGoalCard(
    BuildContext context,
    Map<String, dynamic> goal,
  ) {
    final double progress = (goal['savedAmount'] / goal['targetAmount']).clamp(
      0.0,
      1.0,
    );
    final String progressText = '${(progress * 100).toStringAsFixed(0)}%';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal['goalName'],
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Target: ₦${goal['targetAmount'].toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Saved: ₦${goal['savedAmount'].toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                color: Theme.of(context).primaryColor,
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                progressText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
