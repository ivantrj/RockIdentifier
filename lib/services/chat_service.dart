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

      // Create item details map with Snake-specific properties
      final itemDetails = {
        'commonName': item.commonName ?? 'Unknown',
        'scientificName': item.scientificName ?? 'Unknown',
        'family': item.family ?? 'Unknown',
        'genus': item.genus ?? 'Unknown',
        'confidence': '${(item.confidence * 100).toStringAsFixed(1)}%',
        'venomousStatus': item.venomousStatus ?? 'Unknown',
        'habitat': item.habitat ?? 'Unknown',
        'geographicRange': item.geographicRange ?? 'Unknown',
        'averageLength': item.averageLength ?? 'Unknown',
        'averageWeight': item.averageWeight ?? 'Unknown',
        'behavior': item.behavior ?? 'Unknown',
        'diet': item.diet ?? 'Unknown',
        'conservationStatus': item.conservationStatus ?? 'Unknown',
        'safetyInformation': item.safetyInformation ?? 'Unknown',
        'similarSpecies': item.similarSpecies ?? 'Unknown',
        'interestingFacts': item.interestingFacts ?? 'Unknown',
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

  /// Determine the Snake type based on the item's properties
  String _determineSnakeType(IdentifiedItem item) {
    // Check if it's explicitly categorized
    if (item.category != null) {
      return item.category!;
    }

    // Check the result text for common Snake keywords
    String result = item.result.toLowerCase();

    // Venomous snakes
    if (result.contains('venomous') ||
        result.contains('poisonous') ||
        result.contains('cobra') ||
        result.contains('viper') ||
        result.contains('rattlesnake') ||
        result.contains('mamba') ||
        result.contains('taipan')) {
      return 'venomous_snakes';
    }

    // Constrictor snakes
    if (result.contains('python') ||
        result.contains('boa') ||
        result.contains('constrictor') ||
        result.contains('anaconda')) {
      return 'constrictor_snakes';
    }

    // Colubrid snakes
    if (result.contains('colubrid') ||
        result.contains('garter') ||
        result.contains('rat snake') ||
        result.contains('corn snake') ||
        result.contains('king snake')) {
      return 'colubrid_snakes';
    }

    // Elapid snakes
    if (result.contains('elapid') ||
        result.contains('coral') ||
        result.contains('krait') ||
        result.contains('sea snake')) {
      return 'elapid_snakes';
    }

    // Viper snakes
    if (result.contains('viper') ||
        result.contains('pit viper') ||
        result.contains('rattlesnake') ||
        result.contains('copperhead') ||
        result.contains('cottonmouth')) {
      return 'viper_snakes';
    }

    // Water snakes
    if (result.contains('water') || result.contains('aquatic') || result.contains('sea') || result.contains('marine')) {
      return 'water_snakes';
    }

    // Tree snakes
    if (result.contains('tree') || result.contains('arboreal') || result.contains('vine') || result.contains('twig')) {
      return 'tree_snakes';
    }

    // Desert snakes
    if (result.contains('desert') || result.contains('sand') || result.contains('arid') || result.contains('xeric')) {
      return 'desert_snakes';
    }

    // Tropical snakes
    if (result.contains('tropical') ||
        result.contains('rainforest') ||
        result.contains('jungle') ||
        result.contains('amazon')) {
      return 'tropical_snakes';
    }

    // Default to general snakes if no specific category is found
    return 'general_snakes';
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
