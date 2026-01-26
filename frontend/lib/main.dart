import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Construction Client',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Deep Indigo
          brightness: Brightness.light,
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFF00BFA5), // Teal Accent
          surface: const Color(0xFFF5F5F7),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1A237E),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black.withValues(alpha: 0.1),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
