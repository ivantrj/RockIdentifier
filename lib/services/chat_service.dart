import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rock_id/data/models/identified_item.dart';
import 'package:rock_id/services/logging_service.dart';

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

      // Create item details map with rock-specific properties
      final itemDetails = {
        'name': item.name,
        'commonName': item.commonName,
        'confidence': item.confidence,
        'classification_type': item.classification.type,
        'classification_category': item.classification.category,
        'classification_group': item.classification.group,
        'characteristics_color': item.characteristics.color,
        'characteristics_texture': item.characteristics.texture,
        'characteristics_hardness': item.characteristics.hardness,
        'characteristics_luster': item.characteristics.luster,
        'characteristics_transparency': item.characteristics.transparency,
        'characteristics_crystalForm': item.characteristics.crystalForm,
        'composition': item.composition,
        'formation': item.formation,
        'age': item.age,
        'location': item.location,
        'uses': item.uses,
        'value_estimatedValue': item.value.estimatedValue,
        'value_rarity': item.value.rarity,
        'value_factors': item.value.factors,
        'careAndStorage': item.careAndStorage,
        'safety': item.safety,
        'interestingFacts': item.interestingFacts,
      };

      // Add Wikipedia link if available
      if (item.wikiLink != null) {
        itemDetails['wikiLink'] = item.wikiLink!;
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

  /// Determine the rock type based on the item's properties
  String _determineRockType(IdentifiedItem item) {
    // Check if it's explicitly categorized
    if (item.classification.category != null) {
      return item.classification.category;
    }

    // Check the result text for common rock keywords
    String result = item.name.toLowerCase();

    // Igneous rocks
    if (result.contains('granite') ||
        result.contains('basalt') ||
        result.contains('pumice') ||
        result.contains('obsidian')) {
      return 'igneous_rocks';
    }

    // Sedimentary rocks
    if (result.contains('sandstone') ||
        result.contains('limestone') ||
        result.contains('shale') ||
        result.contains('conglomerate')) {
      return 'sedimentary_rocks';
    }

    // Metamorphic rocks
    if (result.contains('marble') ||
        result.contains('slate') ||
        result.contains('gneiss') ||
        result.contains('schist')) {
      return 'metamorphic_rocks';
    }

    // Gemstones
    if (result.contains('diamond') ||
        result.contains('ruby') ||
        result.contains('sapphire') ||
        result.contains('emerald')) {
      return 'gemstones';
    }

    // Minerals
    if (result.contains('quartz') ||
        result.contains('feldspar') ||
        result.contains('mica') ||
        result.contains('calcite')) {
      return 'minerals';
    }

    // Default to general rock if no specific category is found
    return 'general_rocks';
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
