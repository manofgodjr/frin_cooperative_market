// lib/utils/logger.dart

import 'package:flutter/foundation.dart';

// A simple logging function that only prints in debug mode.
void printLog(dynamic message) {
  if (kDebugMode) {
    debugPrint(message.toString());
  }
}
