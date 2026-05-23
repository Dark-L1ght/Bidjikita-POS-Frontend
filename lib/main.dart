import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; // -> Tambahkan import ini
import 'screens/pos_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bidjikita Coffee Roastery POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const PosDashboardScreen(),
    );
  }
}