// lib/screens/register_screen.dart

import 'package:cooperative_market/logs/user_message_snackbar.dart';
import 'package:cooperative_market/models/user/user_model.dart';
import 'package:cooperative_market/route/routes.dart';
import 'package:cooperative_market/state_management/appstate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import '../../logs/logger/logs.dart';

// The registration screen for new users.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    _genderController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // Handles the registration logic with the API.
  Future<void> _handleRegister(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.setLoading(true);

      const String baseUrl = 'http://127.0.0.1:8000/api/users';
      const String apiUrl = '$baseUrl/register/';

      printLog('Attempting to register to $apiUrl');

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'card_number': _cardNumberController.text,
            'email': _emailController.text,
            'first_name': _firstnameController.text,
            'last_name': _lastnameController.text,
            'password': _passwordController.text,
            'confirm_password': _confirmPasswordController.text,
            'gender': _genderController.text,
            'phone_number': _phoneNumberController.text,
            'username': _usernameController.text,
          }),
        );

        if (!mounted) return;

        printLog('API response status: ${response.statusCode}');
        printLog('API response body: ${response.body}');

        final responseBody = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // The backend response is successful, so we can parse the body.
          // Note: Assuming your backend returns 'token' and a successful message.
          final token = responseBody['token'];
          final username = _usernameController.text;

          if (token != null) {
            // A correct User object should be created with the data needed for the app.
            // Using the new `User` model from your other code.
            final user = User(username: username);

            // If successful, log in using the AppState provider
            appState.login(token, user);
            MessageSnackbar(message: 'Registration successful! Logging in...');

            // Navigate to the dashboard and remove the registration screen from the stack
            if (!context.mounted) return;

            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          } else {
            // Handle the case where the backend returns a success status but no token.
            MessageSnackbar(
              message:
                  'Registration successful, but no token received. Please try logging in.',
              isError: true,
            );
          }
        } else {
          // Handle API errors based on the response body
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
      appBar: AppBar(title: const Text('Create an Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/coop.png', height: 100, width: 100),
              const SizedBox(height: 16),
              Text(
                'Create an Account',
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
                      controller: _cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your unique card number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _firstnameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastnameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_pin_circle_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
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
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password', // Corrected label
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneNumberController,
                      keyboardType:
                          TextInputType.phone, // Use phone keyboard type
                      decoration: const InputDecoration(
                        labelText: 'Phone Number', // Corrected label
                        prefixIcon: Icon(Icons.phone), // Changed icon to phone
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _genderController,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(
                          Icons.person_outline,
                        ), // Changed icon to person
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a gender';
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
                                : () => _handleRegister(context),
                        child:
                            appState.isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text('Register'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Navigate back to the login screen using the named route
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                },
                child: Text(
                  "Already have an account? Sign In",
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
