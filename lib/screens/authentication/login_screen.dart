// lib/screens/login_screen.dart

import 'package:cooperative_market/logs/user_message_snackbar.dart';
import 'package:cooperative_market/models/user/user_model.dart';
import 'package:cooperative_market/route/routes.dart';
import 'package:cooperative_market/state_management/appstate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import '../../logs/logger/logs.dart';

// The login screen for existing users.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handles the login logic with the API.
  Future<void> _handleLogin(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.setLoading(true);

      const String baseUrl = 'http://127.0.0.1:8000/api/users';
      const String apiUrl = '$baseUrl/login/';

      printLog('Attempting to log in to $apiUrl');

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'username': _usernameController.text,
            'password': _passwordController.text,
          }),
        );

        if (!mounted) return;

        printLog('API response status: ${response.statusCode}');
        printLog('API response body: ${response.body}');

        final responseBody = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final token = responseBody['token'];
          final username = _usernameController.text;

          if (token != null) {
            // A correct User object should be created with valid data
            final user = User(username: username);

            // If successful, log in and navigate to the dashboard
            appState.login(token, user);
            MessageSnackbar(message: 'Login successful!');

            // Navigate to the home screen and remove all previous routes
            if (!context.mounted) return;
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          } else {
            // Token is missing from the API response
            MessageSnackbar(
              message: 'Login failed. Token not received.',
              isError: true,
            );
          }
        } else {
          // Handle API errors
          final errorMessage =
              responseBody['error'] ?? 'An unknown error occurred.';
          MessageSnackbar(message: errorMessage, isError: true);
        }
      } catch (e) {
        if (!mounted) return;
        printLog('Error during API call: $e');
        MessageSnackbar(
          message: 'Failed to connect to the server.',
          isError: true,
        );
      } finally {
        if (!mounted) return;
        appState.setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/cooperate.jpg',
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome Back!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            appState.isLoading
                                ? null
                                : () => _handleLogin(context),
                        child:
                            appState.isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text('Sign In'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Use named routes for better navigation management
                  Navigator.of(context).pushNamed('/register');
                },
                child: Text(
                  "Don't have an account? Create an Account",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
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
