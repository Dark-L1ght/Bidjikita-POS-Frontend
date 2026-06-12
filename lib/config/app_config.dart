/// Central configuration for the Bidjikita POS app.
///
/// Change [baseUrl] to match your server:
///   - Android Emulator  → http://10.0.2.2:5000
///   - iOS Simulator     → http://localhost:5000
///   - Physical device   → http://YOUR_MACHINE_IP:5000
class AppConfig {
  AppConfig._();

  static const String baseUrl = 'http://10.0.2.2:5000';
}
