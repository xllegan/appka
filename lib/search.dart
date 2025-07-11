import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final String systemPrompt = """
    Ты - профессиональный медицинский помощник. Отвечай строго в следующем формате:
    
    Диагноз
    [Краткое описание предполагаемого диагноза]
    
    Рекомендации
    1. Препараты:
       - [Название]: [Дозировка] ([Форма выпуска])
       - *Примечание*: [Особенности применения]
    
    2. Действия:
       - [Шаг 1]
       - [Шаг 2]
    
    3. Когда обратиться к врачу:
       - [Симптомы, требующие срочной консультации]
    
    Отвечай только на медицинские темы. На другие вопросы отвечай: "Я могу помочь только с медицинскими вопросами".
    """;

  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;
  String _response = "";
  final List<Map<String, dynamic>> _conversationHistory = [];

  Future<void> _sendMessage() async {
    final message = _inputController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = "";
    });

    try {
      const apiKey = "nXS8Ypi7ckXDniw6LzqssYydlizcaM1R";
      const apiUrl = "https://api.mistral.ai/v1/chat/completions";

      // Добавляем новое сообщение в историю
      _conversationHistory.add({"role": "user", "content": message});

      final response = await http.post(
        Uri.parse("https://api.mistral.ai/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "mistral-medium-latest",
          "messages": [
            {
              "role": "system",
              "content": systemPrompt
            },
            {
              "role": "user",
              "content": _inputController.text
            }
          ],
          "temperature": 0.3,
          "max_tokens": 100,
          "top_p": 0.5
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantReply = data['choices'][0]['message']['content'];

        setState(() {
          _response = assistantReply;
          _conversationHistory.add({"role": "assistant", "content": assistantReply});
        });
      } else {
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _response = "Error: ${e.toString()}";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mistral AI Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _conversationHistory.length,
              itemBuilder: (context, index) {
                final message = _conversationHistory[index];
                return ListTile(
                  title: Text(message['content']),
                  subtitle: Text(message['role']),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: _isLoading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}