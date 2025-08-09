// lib/screens/auth_screen.dart

import 'package:cooperative_market/logs/user_message_snackbar.dart';
import 'package:cooperative_market/state_management/appstate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import '../../logs/logger/logs.dart';

// The authentication screen for logging in or registering.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _uniqueIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _uniqueIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // A placeholder function for handling authentication logic.
  // This will be replaced with actual API calls to the Django backend.
  Future<void> _handleAuth(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.setLoading(true);

      // --- Start of API call logic ---
      const String baseUrl = 'http://127.0.0.1:8000/api'; // Dummy endpoint
      final String endpoint = _isLogin ? '/login/' : '/register/';
      final String apiUrl = '$baseUrl$endpoint';

      printLog('Attempting to ${_isLogin ? 'log in' : 'register'} to $apiUrl');

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'username':
                _uniqueIdController.text, // Assuming unique ID is username
            'password': _passwordController.text,
            if (!_isLogin) 'confirm_password': _confirmPasswordController.text,
          }),
        );

        // Crucial: Check if the widget is still mounted after the async gap
        if (!mounted) return;

        printLog('API response status: ${response.statusCode}');
        printLog('API response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseBody = jsonDecode(response.body);
          final userId = responseBody['user_id'];
          final token = responseBody['token'];
          final username = _uniqueIdController.text;
          final user = User(id: userId, username: username);

          // If successful, log in and navigate to the dashboard
          appState.login(token, user);

          MessageSnackbar(
            message:
                _isLogin ? 'Login successful!' : 'Registration successful!',
          );
        } else {
          // Handle API errors
          final responseBody = jsonDecode(response.body);
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
      // --- End of API call logic ---
    }
  }

  // A placeholder function for Google Sign-In.
  Future<void> _handleGoogleAuth() async {
    // This will require integrating a Google Sign-In package.
    if (!mounted) return;
    MessageSnackbar(message: 'Google Sign-In not yet implemented.');
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
              Image.network(
                'https://placehold.co/100x100/22543D/FFFFFF?text=FRIN',
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 16),
              Text(
                _isLogin ? 'Welcome Back!' : 'Create an Account',
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
                      controller: _uniqueIdController,
                      decoration: const InputDecoration(
                        labelText: 'Card / IPPIS Number',
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your unique ID';
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
                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            appState.isLoading
                                ? null
                                : () => _handleAuth(context),
                        child:
                            appState.isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(_isLogin ? 'Sign In' : 'Register'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleGoogleAuth,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin
                      ? "Don't have an account? Create an Account"
                      : "Already have an account? Sign In",
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
