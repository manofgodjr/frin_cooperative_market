// lib/screens/auth_screen.dart

import 'package:cooperative_market/screens/authentication/login_screen.dart';
import 'package:cooperative_market/screens/dasboard/dasboard_screen.dart';
import 'package:cooperative_market/state_management/appstate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib/screens/auth_wrapper.dart

// This widget decides which screen to show based on the authentication state.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // If the user is logged in, show the Dashboard.
    // Otherwise, show the LoginScreen.
    if (appState.isLoggedIn) {
      return const DashboardScreen(); // Replace with your actual dashboard screen
    } else {
      return const LoginScreen();
    }
  }
}
