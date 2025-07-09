import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final TextEditingController inputController = TextEditingController();
String _response = "";

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _isLoading = false;

  void fetchResponce(String text) async {
    setState(() {
      _isLoading = true;
      _response = "";
    });

    try {
      //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
      const apiKey = "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";
      final apiUrl =
          "https://router.huggingface.co/fireworks-ai/inference/v1/chat/completions";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "messages": [
            {"role": "user", "content": text},
          ],
          "model": "accounts/fireworks/models/deepseek-r1-0528",
        }),
      );

      final data = jsonDecode(response.body);
      setState(() {
        _response = data["choices"][0]["message"]["content"];
      });
    } catch (e) {
      setState(() {
        _response = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: inputController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search something',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => fetchResponce(inputController.text),
              child: _isLoading ? CircularProgressIndicator() : Text('Search'),
            ),
            const SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: Text(_response))),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }
}
