import 'package:app/auth/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class RegistrationScreen extends StatelessWidget {
  RegistrationScreen({super.key});
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();

  Future<bool> _registerUser(BuildContext context) async {
    final username = nameController.text;
    final password = passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': nameController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('OK')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(clearFields: true),
          ),
        );
        return true;
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${response.body}')));
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connection error: $e')));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  hintText: 'Username',
                ),
                controller: nameController,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  hintText: 'Password',
                ),
                controller: passwordController,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  hintText: 'Repeat password',
                ),
                controller: repeatPasswordController,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(),
              child: Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all<Color>(
                      Colors.black,
                    ),
                    side: WidgetStateProperty.all<BorderSide>(
                      const BorderSide(color: Colors.black, width: 0.8),
                    ),
                  ),
                  onPressed: () {
                    if (passwordController.text ==
                        repeatPasswordController.text) {
                      _registerUser(context);
                    }
                  },
                  child: const Text('Create'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
