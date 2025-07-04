import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:JewelryID/data/models/identified_item.dart';

class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        message: json['message'] as String,
        isUser: json['isUser'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };
}

class ChatService {
  static const String _baseUrl = 'https://own-ai-backend-dev.fly.dev';

  /// Send a message to the AI about a specific jewelry item
  Future<String> sendMessage({
    required String itemId,
    required String message,
    required IdentifiedItem item,
    List<ChatMessage>? chatHistory,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/chat-jewelry');

      // Convert chat history to the format expected by the server
      List<Map<String, dynamic>>? history;
      if (chatHistory != null && chatHistory.isNotEmpty) {
        history = chatHistory
            .map((msg) => {
                  'role': msg.isUser ? 'user' : 'model',
                  'parts': [
                    {'text': msg.message}
                  ]
                })
            .toList();
      }

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'itemId': itemId,
          'message': message,
          'chatHistory': history,
          'itemDetails': {
            'type': item.result,
            'material': item.material,
            'brandOrMaker': item.brandOrMaker,
            'eraOrStyle': item.eraOrStyle,
            'authenticity': item.authenticity,
            'condition': item.condition,
            'estimatedPrice': item.estimatedPrice,
            'description': item.details['Description'],
            'gemstoneDetails': item.details['Gemstones'],
            'careTips': item.details['Care Tips'],
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['response'] as String;
        } else {
          throw Exception(data['error'] ?? 'Failed to get response from AI');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  /// Get chat history for an item (for future use)
  Future<List<ChatMessage>> getChatHistory(String itemId) async {
    try {
      final uri = Uri.parse('$_baseUrl/chat-history/$itemId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> history = data['history'] ?? [];
          return history.map((msg) => ChatMessage.fromJson(msg)).toList();
        }
      }
      return [];
    } catch (e) {
      // Return empty list if there's an error
      return [];
    }
  }
}
