import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:snake_id/data/models/identified_item.dart';
import 'package:snake_id/services/logging_service.dart';

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

      // Create item details map with coin-specific properties
      final itemDetails = {
        'coinType': item.coinType ?? 'Unknown',
        'denomination': item.denomination ?? 'Unknown',
        'confidence': '${(item.confidence * 100).toStringAsFixed(1)}%',
        'mintYear': item.mintYear ?? 'Unknown',
        'country': item.country ?? 'Unknown',
        'mintMark': item.mintMark ?? 'Unknown',
        'metalComposition': item.metalComposition ?? 'Unknown',
        'weight': item.weight ?? 'Unknown',
        'diameter': item.diameter ?? 'Unknown',
        'condition': item.condition ?? 'Unknown',
        'authenticity': item.authenticity ?? 'Unknown',
        'rarity': item.rarity ?? 'Unknown',
        'estimatedValue': item.estimatedValue ?? 'Unknown',
        'historicalContext': item.historicalContext ?? 'Unknown',
        'designDescription': item.designDescription ?? 'Unknown',
        'edgeType': item.edgeType ?? 'Unknown',
        'designer': item.designer ?? 'Unknown',
        'mintage': item.mintage ?? 'Unknown',
        'investmentPotential': item.investmentPotential ?? 'Unknown',
        'marketDemand': item.marketDemand ?? 'Unknown',
        'storageRecommendations': item.storageRecommendations ?? 'Unknown',
        'cleaningInstructions': item.cleaningInstructions ?? 'Unknown',
        'similarCoins': item.similarCoins ?? 'Unknown',
        'insuranceValue': item.insuranceValue ?? 'Unknown',
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

  /// Determine the coin type based on the item's properties
  String _determineCoinType(IdentifiedItem item) {
    // Check if it's explicitly categorized
    if (item.category != null) {
      return item.category!;
    }

    // Check the result text for common coin keywords
    String result = item.result.toLowerCase();

    // Ancient coins
    if (result.contains('roman') ||
        result.contains('greek') ||
        result.contains('byzantine') ||
        result.contains('ancient') ||
        result.contains('bc') ||
        result.contains('ad')) {
      return 'ancient_coins';
    }

    // Medieval coins
    if (result.contains('medieval') ||
        result.contains('middle ages') ||
        result.contains('crusader') ||
        result.contains('gothic')) {
      return 'medieval_coins';
    }

    // Modern coins (1800s-1900s)
    if (result.contains('1800') ||
        result.contains('1900') ||
        result.contains('victorian') ||
        result.contains('edwardian') ||
        result.contains('georgian')) {
      return 'modern_coins';
    }

    // Contemporary coins (2000s+)
    if (result.contains('2000') ||
        result.contains('2020') ||
        result.contains('contemporary') ||
        result.contains('modern')) {
      return 'contemporary_coins';
    }

    // Gold coins
    if (result.contains('gold') ||
        result.contains('sovereign') ||
        result.contains('eagle') ||
        result.contains('krugerrand')) {
      return 'gold_coins';
    }

    // Silver coins
    if (result.contains('silver') ||
        result.contains('morgan') ||
        result.contains('peace') ||
        result.contains('walking liberty')) {
      return 'silver_coins';
    }

    // Commemorative coins
    if (result.contains('commemorative') ||
        result.contains('anniversary') ||
        result.contains('celebration') ||
        result.contains('special')) {
      return 'commemorative_coins';
    }

    // Error coins
    if (result.contains('error') ||
        result.contains('misprint') ||
        result.contains('double') ||
        result.contains('off-center')) {
      return 'error_coins';
    }

    // Proof coins
    if (result.contains('proof') || result.contains('mint state') || result.contains('uncirculated')) {
      return 'proof_coins';
    }

    // World coins
    if (result.contains('foreign') || result.contains('international') || result.contains('world')) {
      return 'world_coins';
    }

    // US coins
    if (result.contains('penny') ||
        result.contains('nickel') ||
        result.contains('dime') ||
        result.contains('quarter') ||
        result.contains('half dollar') ||
        result.contains('dollar') ||
        result.contains('us') ||
        result.contains('american')) {
      return 'us_coins';
    }

    // British coins
    if (result.contains('pound') ||
        result.contains('shilling') ||
        result.contains('pence') ||
        result.contains('farthing') ||
        result.contains('british') ||
        result.contains('uk')) {
      return 'british_coins';
    }

    // Default to general coin if no specific category is found
    return 'general_coins';
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
