import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../search.dart';
import 'registration.dart';
import 'dart:convert';

class LoginScreen extends StatelessWidget {
  final bool clearFields;
  LoginScreen({super.key, this.clearFields = false});
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<Map<String, dynamic>?> _loginUser(BuildContext context) async {
    final username = nameController.text;
    final password = passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'username': username,
          'password': password,
          'scope': '',
          'client_id': '',
          'client_secret': '',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Успешный вход!')),
        );
        return {
          'access_token': responseData['access_token'],
          'token_type': responseData['token_type'] ?? 'Bearer',
        };
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${response.body}')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка соединения: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (clearFields) {
      nameController.clear();
      passwordController.clear();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Авторизация')),
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
                  hintText: 'Имя пользователя',
                ),
                controller: nameController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  hintText: 'Пароль',
                ),
                controller: passwordController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(),
              child: Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Регистрация',
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
                  onPressed: () async {
                    final authData = await _loginUser(context);
                    if (authData != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(
                            authToken: authData['access_token'],
                            baseUrl: 'http://10.0.2.2:8000',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Войти'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}