import 'package:flutter/material.dart';
import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/screens/calender_screen.dart';

void main() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.blue.shade400,
        child: Center(
          child: Text(
            details.exception.toString(),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  };

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const HomeScreen(),
        '/calender': (context) => const CalenderScreen(tasks: [],),
      },
    );
  }
}
