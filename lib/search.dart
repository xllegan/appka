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
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;
  String _response = "";
  final List<Map<String, String>> _history = [];

  Future<void> _fetchResponse(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = "";
    });

    try {
      const apiKey = "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";
      const apiUrl =
          "https://router.huggingface.co/fireworks-ai/inference/v1/chat/completions";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "messages": [
            {
              "role": "system",
              "content":
              "Ты медицинский помощник. Дай список препаратов с дозировками в виде массива. "
                  "Отвечай на русском языке.",
            },
            {"role": "user", "content": text},
          ],
          "model": "accounts/fireworks/models/deepseek-r1-0528",
          "temperature": 0.7,
        }),
      );

      final data = jsonDecode(response.body);
      final result = data["choices"][0]["message"]["content"];

      setState(() {
        _response = result;
        _history.insert(0, {
          'query': text,
          'response': result,
          'time': DateTime.now().toString().substring(0, 16),
        });
      });
    } catch (e) {
      setState(() {
        _response =
        "Ошибка соединения. Пожалуйста, проверьте интернет и попробуйте снова.\n\n$e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Медицинский советник'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => _showHistoryDialog(context),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Поле ввода
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: 'Опишите симптомы или заболевание',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _isLoading
                      ? null
                      : () => _fetchResponse(_inputController.text),
                ),
              ),
              maxLines: 3,
              onSubmitted: (_) => _fetchResponse(_inputController.text),
            ),
            const SizedBox(height: 16),

            // Кнопка поиска
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.medical_services),
                label: Text(
                  _isLoading ? 'Обработка запроса...' : 'Получить рекомендации',
                ),
                onPressed: _isLoading
                    ? null
                    : () => _fetchResponse(_inputController.text),
              ),
            ),
            const SizedBox(height: 16),

            // Результаты
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _response.isEmpty
                    ? const Center(
                  child: Text(
                    'Введите симптомы для получения рекомендаций',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : Markdown(
                  data: _response,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 16),
                    h2: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    listBullet: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Очистить историю',
        onPressed: _clearHistory,
        child: const Icon(Icons.delete),
      ),
    );
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
            itemCount: _history.length,
            itemBuilder: (ctx, i) => Card(
              child: ListTile(
                title: Text(_history[i]['query']!),
                subtitle: Text(
                  _history[i]['time']!,
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  setState(() => _response = _history[i]['response']!);
                  Navigator.pop(ctx);
                },
              ),
            ),
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
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}