import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  final String authToken;
  final String baseUrl;

  const SearchScreen({
    super.key,
    required this.authToken,
    required this.baseUrl,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;
  String _response = "";
  final List<Map<String, dynamic>> _conversationHistory = [];
  final List<Map<String, dynamic>> _queryHistory = [];

  Future<void> _sendMessage() async {
    final message = _inputController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = "Отправка запроса...";
    });

    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/ai/chat'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.authToken}",
          "accept": "application/json",
        },
        body: jsonEncode({"message": message}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _response = data['response'] ?? "Пустой ответ от сервера";
          _conversationHistory.addAll([
            {"role": "user", "content": message},
            {"role": "assistant", "content": data['response']}
          ]);

          _queryHistory.add({
            'query': message,
            'response': data['response'],
            'time': DateFormat('HH:mm').format(DateTime.now()),
          });
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _response = "Ошибка: Требуется повторная авторизация";
        });
        // Можно добавить автоматический переход на экран логина
      } else {
        throw Exception("Ошибка API: ${response.statusCode}\n${response.body}");
      }
    } catch (e) {
      setState(() {
        _response = "Ошибка: ${e.toString()}";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('История запросов'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _queryHistory.length,
            itemBuilder: (ctx, index) {
              final item = _queryHistory[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(item['query']),
                  subtitle: Text(item['time']),
                  onTap: () {
                    setState(() {
                      _inputController.text = item['query'];
                      _response = item['response'];
                    });
                    Navigator.pop(ctx);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: [
          if (_queryHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => _showHistoryDialog(context),
              tooltip: 'История запросов',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Markdown(
              data: _response.isNotEmpty
                  ? _response
                  : _isLoading
                  ? "Загрузка..."
                  : "Здесь будет ответ...",
              padding: const EdgeInsets.all(16),
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
                      hintText: "Введите ваше сообщение...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
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