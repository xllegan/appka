import 'package:flutter/material.dart';
import 'search.dart';

String password = "";
String username = "";
final TextEditingController nameController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

class AuthForm extends StatelessWidget {
  const AuthForm({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
            child: SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                  side: WidgetStateProperty.all<BorderSide>(
                    const BorderSide(color: Colors.black, width: 0.8),
                  ),
                ),

                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(passwordController.text)),
                  );
                  if (authCheck(nameController.text, passwordController.text)) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  }
                },
                child: const Text('Login'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

bool authCheck(String username, String password) {
  return password == "123";
}
