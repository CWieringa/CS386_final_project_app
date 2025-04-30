// filename: main.dart
// date: Apr 29, 2025
// author: Clay Wieringa
// description: main of app, run page

import 'package:flutter/material.dart';
import 'view/home_page.dart';

void main() {
  runApp(const MyApp()); // Starts the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout App', // Sets the title of the app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Sets the primary color for the app
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 73, 72, 72), // Sets colors
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const HomePage(), // Home page of the app
    );
  }
}
