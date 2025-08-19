import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:antique_id/data/models/identified_item.dart';
import 'package:antique_id/services/logging_service.dart';

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

  /// Send a chat message about a specific identified item
  Future<String> sendMessage(String itemId, String message, List<Map<String, String>> history) async {
    try {
      LoggingService.apiOperation('Sending chat message', details: 'itemId: $itemId', tag: 'ChatService');

      final uri = Uri.parse('$_baseUrl/chat');
      final item = await _getItemById(itemId);

      if (item == null) {
        throw Exception('Item not found');
      }

      // Create item details map with antique-specific properties
      final itemDetails = {
        'itemType': item.itemType ?? 'Unknown',
        'specificCategory': item.specificCategory ?? 'Unknown',
        'confidence': '${(item.confidence * 100).toStringAsFixed(1)}%',
        'estimatedAge': item.estimatedAge ?? 'Unknown',
        'origin': item.origin ?? 'Unknown',
        'makerOrManufacturer': item.makerOrManufacturer ?? 'Unknown',
        'materials': item.materials ?? 'Unknown',
        'style': item.style ?? 'Unknown',
        'condition': item.condition ?? 'Unknown',
        'authenticity': item.authenticity ?? 'Unknown',
        'rarity': item.rarity ?? 'Unknown',
        'estimatedValue': item.estimatedValue ?? 'Unknown',
        'provenance': item.provenance ?? 'Unknown',
        'historicalContext': item.historicalContext ?? 'Unknown',
        'careInstructions': item.careInstructions ?? 'Unknown',
        'investmentPotential': item.investmentPotential ?? 'Unknown',
        'marketDemand': item.marketDemand ?? 'Unknown',
      };

      // Add Wikipedia link if available
      if (item.wikiLink != null) {
        itemDetails['wikipedia'] = item.wikiLink!;
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

    // Antique keywords
    if (result.contains('furniture') ||
        result.contains('chair') ||
        result.contains('table') ||
        result.contains('desk') ||
        result.contains('cabinet') ||
        result.contains('dresser') ||
        result.contains('sofa') ||
        result.contains('bed') ||
        result.contains('mirror') ||
        result.contains('lamp')) {
      return 'furniture';
    }

    if (result.contains('vase') ||
        result.contains('pottery') ||
        result.contains('ceramic') ||
        result.contains('porcelain') ||
        result.contains('china') ||
        result.contains('plate') ||
        result.contains('bowl') ||
        result.contains('cup') ||
        result.contains('saucer')) {
      return 'ceramics';
    }

    if (result.contains('glass') ||
        result.contains('crystal') ||
        result.contains('bottle') ||
        result.contains('decanter') ||
        result.contains('goblet') ||
        result.contains('wine glass')) {
      return 'glassware';
    }

    if (result.contains('painting') ||
        result.contains('artwork') ||
        result.contains('portrait') ||
        result.contains('landscape') ||
        result.contains('oil') ||
        result.contains('watercolor') ||
        result.contains('print') ||
        result.contains('etching')) {
      return 'artwork';
    }

    if (result.contains('coin') ||
        result.contains('currency') ||
        result.contains('medal') ||
        result.contains('token')) {
      return 'numismatics';
    }

    if (result.contains('book') ||
        result.contains('manuscript') ||
        result.contains('document') ||
        result.contains('letter') ||
        result.contains('map')) {
      return 'books_documents';
    }

    if (result.contains('jewelry') ||
        result.contains('ring') ||
        result.contains('necklace') ||
        result.contains('bracelet') ||
        result.contains('earring') ||
        result.contains('brooch')) {
      return 'jewelry';
    }

    if (result.contains('textile') ||
        result.contains('fabric') ||
        result.contains('rug') ||
        result.contains('carpet') ||
        result.contains('tapestry') ||
        result.contains('quilt')) {
      return 'textiles';
    }

    if (result.contains('tool') ||
        result.contains('instrument') ||
        result.contains('equipment') ||
        result.contains('machine')) {
      return 'tools_equipment';
    }

    if (result.contains('toy') || result.contains('doll') || result.contains('game') || result.contains('puzzle')) {
      return 'toys_games';
    }

    if (result.contains('musical') ||
        result.contains('instrument') ||
        result.contains('piano') ||
        result.contains('violin') ||
        result.contains('guitar') ||
        result.contains('flute')) {
      return 'musical_instruments';
    }

    // Default to antique if no specific category is found
    return 'antique';
  }

  /// Get item by ID (placeholder - implement based on your data storage)
  Future<IdentifiedItem?> _getItemById(String itemId) async {
    // This should be implemented based on how you store and retrieve items
    // For now, return null as a placeholder
    return null;
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
