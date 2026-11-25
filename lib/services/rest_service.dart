import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/conversation.dart';

class RestService {
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static Future<String> sendMessage(
    String token,
    String prompt,
    List<ChatMessage> history,
  ) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/chat'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'message': prompt,
            'history': history.map((item) => item.toJson()).toList(),
          }),
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('API REST (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['reply'] as String;
  }

  static Future<List<Conversation>> getConversations(String token) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/api/conversations'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Chargement MongoDB (${response.statusCode})');
    }
    final items = jsonDecode(response.body) as List<dynamic>;
    return items
        .map(
          (item) =>
              Conversation.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  static Future<Conversation> createConversation(
    String token,
    Conversation conversation,
  ) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/conversations'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(conversation.toJson()),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 201) {
      throw Exception('Création MongoDB (${response.statusCode})');
    }
    return Conversation.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
  }

  static Future<void> updateConversation(
    String token,
    Conversation conversation,
  ) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/api/conversations/${conversation.id}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(conversation.toJson()),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Mise à jour MongoDB (${response.statusCode})');
    }
  }

  static Future<void> deleteConversation(
    String token,
    String conversationId,
  ) async {
    final response = await http
        .delete(
          Uri.parse('$_baseUrl/api/conversations/$conversationId'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 204) {
      throw Exception('Suppression MongoDB (${response.statusCode})');
    }
  }
}
