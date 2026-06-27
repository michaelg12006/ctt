import 'package:ctt/pages/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:ctt/pages/register_page.dart';
import 'package:ctt/pages/home_page.dart';
import 'package:ctt/pages/admin/admin_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ctt',

      initialRoute: '/home',
      routes: {
        '/login': (context) => const SignInPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/adminHome': (context) => const AdminDashboard(),
      },

      theme: ThemeData(
        fontFamily: 'Poppins',

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD97941),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontFamily: 'Poppins',
          ),
        ),

        scaffoldBackgroundColor: const Color(0xFFFFFAF6),

        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(
            color: Color(0xFF423F33),
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF423F33),
            fontSize: 14,
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFFD97941),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 199, 108, 55),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade800, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD97941),
            foregroundColor: const Color(0xFFFFFCE3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}