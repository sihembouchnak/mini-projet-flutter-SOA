import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/conversation.dart';

class GeminiService {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const isConfigured = _apiKey != '';

  static Future<String> sendMessage(
    String prompt,
    List<ChatMessage> history,
  ) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Clé Gemini absente. Lancez avec --dart-define=GEMINI_API_KEY=VOTRE_CLE.',
      );
    }
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey',
    );
    final contents = history
        .map(
          (message) => {
            'role': message.role == 'user' ? 'user' : 'model',
            'parts': [
              {'text': message.content},
            ],
          },
        )
        .toList();
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'contents': contents}),
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('API Gemini (${response.statusCode}): ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      return 'Je n’ai pas reçu de réponse valide.';
    }
    final content = candidates.first['content'] as Map<String, dynamic>;
    final parts = content['parts'] as List<dynamic>;
    return parts.map((part) => part['text'] as String).join('\n');
  }
}
