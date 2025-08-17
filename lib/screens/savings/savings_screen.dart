// lib/screens/savings_screen.dart

import 'package:cooperative_market/logs/logger/logs.dart';
import 'package:cooperative_market/logs/user_message_snackbar.dart';
import 'package:cooperative_market/state_management/appstate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

// New Savings Screen
class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
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

  // --- START OF CHANGES ---
  // ADDED: A method to create a new savings goal via an API call
  Future<void> _addSavingsGoal(String goalName, double targetAmount) async {
    final appState = Provider.of<AppState>(context, listen: false);
    const String baseUrl = 'http://127.0.0.1:8000/api/transactions';
    const String savingsUrl = '$baseUrl/savings_goals/';

    try {
      final response = await http.post(
        Uri.parse(savingsUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token ${appState.authToken}',
        },
        body: jsonEncode({
          'goal_name': goalName,
          'target_amount': targetAmount,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        MessageSnackbar(message: 'Savings goal created successfully!');
        // UPDATED: Call setState to refresh the list of goals
        setState(() {});
      } else {
        final error = jsonDecode(response.body);
        MessageSnackbar(message: error.toString(), isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      printLog('Error adding savings goal: $e');

      MessageSnackbar(message: 'Failed to add savings goal.', isError: true);
    }
  }

  // ADDED: A method to update an existing savings goal by adding funds to it.
  Future<void> _addFundsToGoal(int goalId, double amountToAdd) async {
    final appState = Provider.of<AppState>(context, listen: false);
    const String baseUrl = 'http://127.0.0.1:8000/api/transactions';
    final String savingsUrl = '$baseUrl/savings_goals/$goalId/';

    try {
      final response = await http.patch(
        Uri.parse(savingsUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token ${appState.authToken}',
        },
        body: jsonEncode({
          'saved_amount':
              amountToAdd, // The backend should handle the logic to add this to the current saved_amount.
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        MessageSnackbar(message: 'Funds added successfully!');
        setState(() {}); // Refresh the list of goals
      } else {
        final error = jsonDecode(response.body);
        MessageSnackbar(message: error.toString(), isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      printLog('Error adding funds to goal: $e');
      MessageSnackbar(message: 'Failed to add funds to goal.', isError: true);
    }
  }

  // ADDED: A dialog to add a new savings goal
  void _showAddGoalDialog() {
    final formKey = GlobalKey<FormState>();
    final TextEditingController goalNameController = TextEditingController();
    final TextEditingController targetAmountController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Savings Goal'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: goalNameController,
                  decoration: const InputDecoration(labelText: 'Goal Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a goal name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: targetAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target Amount (₦)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a target amount.';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final goalName = goalNameController.text;
                  final targetAmount = double.parse(
                    targetAmountController.text,
                  );
                  _addSavingsGoal(goalName, targetAmount);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Goal'),
            ),
          ],
        );
      },
    );
  }

  // ADDED: A dialog to add funds to an existing savings goal.
  void _showAddFundsDialog(
    int goalId,
    String goalName,
    double currentSavedAmount,
  ) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Funds to $goalName'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Saved Amount: ₦${currentSavedAmount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount to Add (₦)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount.';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final amountToAdd = double.parse(_amountController.text);
                  _addFundsToGoal(goalId, currentSavedAmount + amountToAdd);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Funds'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ADDED: A Floating Action Button to open the dialog
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalDialog,
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

    return GestureDetector(
      onTap: () {
        _showAddFundsDialog(
          goal['id'],
          goal['goalName'],
          goal['savedAmount'].toDouble(),
        );
      },
      child: Card(
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
      ),
    );
  }
}

// --- END OF CHANGES ---
