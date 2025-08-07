// A widget that displays a message to the user.
import 'package:flutter/material.dart';

class MessageSnackbar extends StatelessWidget {
  final String message;
  final bool isError;
  const MessageSnackbar({
    super.key,
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
    );
  }
}
