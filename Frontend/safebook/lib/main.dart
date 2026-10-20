import 'package:flutter/material.dart';
import 'package:safebook/screens/add_service_screen.dart';
import 'package:safebook/screens/authentication_screen.dart';
import 'package:safebook/screens/date_time_selection_screen.dart';
import 'package:safebook/screens/user_home_page.dart';
import 'package:safebook/screens/services_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 235, 240, 252),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 235, 240, 252),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 37, 99, 235),
          brightness: Brightness.light,
        ).copyWith(primaryContainer: const Color.fromARGB(255, 37, 99, 235)),

        textTheme: TextTheme(
          bodySmall: TextStyle(fontSize: 18),

          bodyMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      home: AuthenticationScreen(),
    );
  }
}
