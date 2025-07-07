import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bug_id/data/models/identified_item.dart';
import 'package:bug_id/services/logging_service.dart';

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

  /// Send a message to the AI about a specific item (bug, plant, or any other type)
  Future<String> sendMessage({
    required String itemId,
    required String message,
    required IdentifiedItem item,
    List<ChatMessage>? chatHistory,
  }) async {
    try {
      LoggingService.apiOperation('Sending chat message',
          details: 'itemId: $itemId, message length: ${message.length}');
      final uri = Uri.parse('$_baseUrl/chat');

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

      // Determine item type based on the result or category
      String itemType = _determineItemType(item);

      // Build item details for the new endpoint
      Map<String, dynamic> itemDetails = {
        'name': item.result,
        'type': itemType,
        'subtitle': item.subtitle,
        'confidence': '${(item.confidence * 100).toStringAsFixed(1)}%',
        'description': item.details['Description'] ?? 'No description available',
        'species': item.species ?? 'Unknown',
        'family': item.family ?? 'Unknown',
        'order': item.order ?? 'Unknown',
        'habitat': item.habitat ?? 'Unknown',
        'dangerLevel': item.dangerLevel ?? 'Unknown',
        'commonName': item.commonName ?? 'Unknown',
        'distribution': item.distribution ?? 'Unknown',
        'size': item.size ?? 'Unknown',
        'color': item.color ?? 'Unknown',
        'lifeCycle': item.lifeCycle ?? 'Unknown',
        'feedingHabits': item.feedingHabits ?? 'Unknown',
        'conservationStatus': item.conservationStatus ?? 'Unknown',
      };

      // Add Wikipedia link if available
      if (item.details['Wikipedia'] != null) {
        itemDetails['wikipedia'] = item.details['Wikipedia'];
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
          'itemDetails': itemDetails,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          LoggingService.apiOperation('Chat message sent successfully', details: 'itemId: $itemId');
          return data['response'] as String;
        } else {
          final error = data['error'] ?? 'Failed to get response from AI';
          LoggingService.error('Chat API error', error: Exception(error), tag: 'ChatService');
          throw Exception(error);
        }
      } else {
        LoggingService.error('Chat API server error',
            error: Exception('Status: ${response.statusCode}'), tag: 'ChatService');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('Chat message failed', error: e, tag: 'ChatService');
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  /// Determine the item type based on the item's properties
  String _determineItemType(IdentifiedItem item) {
    // Check if it's explicitly categorized
    if (item.category != null) {
      return item.category!;
    }

    // Check the result text for common keywords
    String result = item.result.toLowerCase();

    // Bug/insect keywords
    if (result.contains('bug') ||
        result.contains('insect') ||
        result.contains('beetle') ||
        result.contains('ant') ||
        result.contains('bee') ||
        result.contains('wasp') ||
        result.contains('fly') ||
        result.contains('mosquito') ||
        result.contains('moth') ||
        result.contains('butterfly') ||
        result.contains('spider') ||
        result.contains('arachnid') ||
        result.contains('caterpillar') ||
        result.contains('larva') ||
        result.contains('dragonfly') ||
        result.contains('grasshopper') ||
        result.contains('cricket') ||
        result.contains('mantis') ||
        result.contains('roach') ||
        result.contains('termite')) {
      return 'bug';
    }

    // Plant keywords (optional, keep for future expansion)
    if (result.contains('plant') ||
        result.contains('flower') ||
        result.contains('tree') ||
        result.contains('cactus') ||
        result.contains('succulent') ||
        result.contains('herb') ||
        result.contains('leaf')) {
      return 'plant';
    }

    // Default to the result as the type
    return item.result;
  }

  /// Get chat history for an item (for future use)
  Future<List<ChatMessage>> getChatHistory(String itemId) async {
    try {
      LoggingService.apiOperation('Getting chat history', details: 'itemId: $itemId');
      final uri = Uri.parse('$_baseUrl/chat-history/$itemId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> history = data['history'] ?? [];
          LoggingService.apiOperation('Chat history retrieved',
              details: 'itemId: $itemId, messages: ${history.length}');
          return history.map((msg) => ChatMessage.fromJson(msg)).toList();
        }
      }
      LoggingService.warning('No chat history found', tag: 'ChatService');
      return [];
    } catch (e) {
      // Return empty list if there's an error
      LoggingService.error('Failed to get chat history', error: e, tag: 'ChatService');
      return [];
    }
  }
}
