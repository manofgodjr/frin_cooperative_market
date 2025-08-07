// lib/main.dart

import 'package:cooperative_market/screens/authentication/auth_screen.dart';
import 'package:cooperative_market/screens/dasboard/dasboard_screen.dart';
import 'package:cooperative_market/state_management/appstate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Main entry point of the Flutter application.
void main() {
  runApp(
    // Use a ChangeNotifierProvider to manage the global application state.
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const FRINCooperativeApp(),
    ),
  );
}

// The root widget for the application.
class FRINCooperativeApp extends StatelessWidget {
  const FRINCooperativeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FRIN Cooperative',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF22543D),
        scaffoldBackgroundColor: const Color(0xFFE2E8F0),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFF6E05E),
        ),
        fontFamily: 'Inter',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF22543D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1A202C),
        scaffoldBackgroundColor: const Color(0xFF1A202C),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
        ).copyWith(secondary: const Color(0xFFF6E05E)),
        fontFamily: 'Inter',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF22543D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2D3748),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoggedIn) {
            return const DashboardScreen();
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
