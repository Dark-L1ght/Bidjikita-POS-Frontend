import 'package:flutter/foundation.dart';

/// Simple structured logger that prints to console.
/// In production, replace with your crash-reporting service.
void logError(String context, Object error, [StackTrace? stack]) {
  debugPrint('[ERROR] $context: $error');
  if (stack != null) debugPrint('$stack');
}

void logWarn(String message) {
  debugPrint('[WARN] $message');
}
