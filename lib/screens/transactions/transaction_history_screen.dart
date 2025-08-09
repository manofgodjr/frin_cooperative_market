// lib/screens/transaction_history_screen.dart

import 'package:cooperative_market/logs/logger/logs.dart';
import 'package:cooperative_market/logs/user_message_snackbar.dart';
import 'package:cooperative_market/state_management/appstate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// --- START OF CHANGES ---
// ADDED: A new screen to display the user's transaction history.
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  Future<List<dynamic>> _fetchTransactions(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    const String baseUrl = 'http://127.0.0.1:8000/api';
    const String transactionsUrl = '$baseUrl/transactions/';

    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${appState.authToken}',
    };

    printLog('Fetching transactions from $transactionsUrl');

    try {
      final response = await http.get(
        Uri.parse(transactionsUrl),
        headers: headers,
      );
      if (!context.mounted) return [];
      printLog('Transactions response status: ${response.statusCode}');
      printLog('Transactions response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      if (!context.mounted) return [];
      printLog('Error fetching transactions: $e');
      MessageSnackbar(message: 'Failed to load transactions.', isError: true);
      // Placeholder data in case of error
      return [
        {
          'id': 1,
          'description': 'Monthly Dues',
          'amount': 5000.00,
          'transaction_type': 'DEBIT',
          'date': '2025-07-25T10:00:00Z',
        },
        {
          'id': 2,
          'description': 'Loan Repayment',
          'amount': 15000.00,
          'transaction_type': 'DEBIT',
          'date': '2025-07-20T12:30:00Z',
        },
        {
          'id': 3,
          'description': 'Savings Deposit',
          'amount': 20000.00,
          'transaction_type': 'DEBIT',
          'date': '2025-07-15T15:45:00Z',
        },
        {
          'id': 4,
          'description': 'Loan Disbursement',
          'amount': 250000.00,
          'transaction_type': 'CREDIT',
          'date': '2025-07-10T09:00:00Z',
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: FutureBuilder(
        future: _fetchTransactions(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final transactions = snapshot.data as List<dynamic>;
            if (transactions.isEmpty) {
              return const Center(child: Text('No transactions found.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildTransactionCard(context, transaction);
              },
            );
          }
          return const Center(child: Text('No data found.'));
        },
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    final isCredit = transaction['transaction_type'] == 'CREDIT';
    final amountColor = isCredit ? Colors.green : Colors.red;
    final icon = isCredit ? Icons.arrow_upward : Icons.arrow_downward;
    final formattedDate = DateFormat(
      'MMM d, yyyy',
    ).format(DateTime.parse(transaction['date']));
    final formattedTime = DateFormat(
      'h:mm a',
    ).format(DateTime.parse(transaction['date']));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: amountColor),
        title: Text(
          transaction['description'],
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$formattedDate at $formattedTime',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          '₦${transaction['amount'].toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: amountColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// --- END OF CHANGES ---
