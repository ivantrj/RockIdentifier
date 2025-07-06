import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jewelry_id/data/models/identified_item.dart';

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

  /// Send a message to the AI about a specific item (jewelry, plant, or any other type)
  Future<String> sendMessage({
    required String itemId,
    required String message,
    required IdentifiedItem item,
    List<ChatMessage>? chatHistory,
  }) async {
    try {
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
        'estimatedPrice': item.estimatedPrice ?? 'Unknown',
      };

      // Add type-specific details
      if (itemType.toLowerCase() == 'jewelry') {
        itemDetails.addAll({
          'careGuide': item.details['Care Tips'] ?? 'No care guide available',
          'material': item.material ?? 'Unknown',
          'gemstoneDetails': item.gemstones ?? 'No gemstone details available',
          'brandOrMaker': item.brandOrMaker ?? 'Unknown',
          'eraOrStyle': item.eraOrStyle ?? 'Unknown',
          'authenticity': item.authenticity ?? 'Unknown',
          'condition': item.condition ?? 'Unknown',
        });
      } else if (itemType.toLowerCase() == 'plant') {
        itemDetails.addAll({
          'careGuide': item.details['Care Guide'] ?? 'No care guide available',
          'toxicity': item.details['Toxicity'] ?? 'No toxicity information available',
          'watering': item.details['Watering'] ?? 'No watering information available',
          'lighting': item.details['Lighting'] ?? 'No lighting information available',
        });
      }

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

  /// Determine the item type based on the item's properties
  String _determineItemType(IdentifiedItem item) {
    // Check if it's explicitly categorized
    if (item.category != null) {
      return item.category!;
    }

    // Check the result text for common keywords
    String result = item.result.toLowerCase();

    // Jewelry keywords
    if (result.contains('ring') ||
        result.contains('necklace') ||
        result.contains('bracelet') ||
        result.contains('earring') ||
        result.contains('pendant') ||
        result.contains('diamond') ||
        result.contains('gold') ||
        result.contains('silver') ||
        result.contains('jewelry') ||
        result.contains('gemstone')) {
      return 'jewelry';
    }

    // Plant keywords
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
