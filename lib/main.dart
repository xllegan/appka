import 'package:flutter/material.dart';
import "auth.dart";

void main() {
  runApp(const MainScreen());
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: const AuthForm()));
  }
}
