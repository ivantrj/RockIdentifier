import 'dart:io';
import 'package:flutter/services.dart';
import 'package:rock_id/data/models/identified_item.dart';
import 'package:flutter/material.dart';
import 'package:rock_id/services/chat_service.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:rock_id/core/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final IdentifiedItem item;
  const ChatScreen({super.key, required this.item});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: "Ask me anything about this snake",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await _chatService.sendMessage(
        widget.item.id,
        message,
        _messages.map((m) => {'role': m.isUser ? 'user' : 'model', 'content': m.message}).toList(),
      );

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(
          id: 'error',
          message: "Sorry, I encountered an error. Please try again.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: isDarkMode ? AppTheme.nearBlack : AppTheme.lightBackground,
        appBar: _buildModernAppBar(context),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Snake info card at the top
              _buildSnakeInfoCard(context),

              // Messages list
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return _buildModernTypingIndicator();
                      }
                      return _buildModernMessage(_messages[index]);
                    },
                  ),
                ),
              ),

              // Input area
              _buildModernInputArea(theme),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle:
          Theme.of(context).brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: Icon(
          HugeIcons.strokeRoundedArrowLeft01,
          color: isDarkMode ? Colors.white : Colors.black87,
          size: 24,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Expert Chat',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.item.result,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [],
    );
  }

  Widget _buildSnakeInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkStone : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Snake image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(widget.item.imagePath),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppTheme.sandstone.withValues(alpha: 0.2)
                          : AppTheme.sandstone.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      HugeIcons.strokeRoundedAbacus,
                      size: 32,
                      color: isDarkMode ? AppTheme.sandstone : AppTheme.sandstone,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Snake info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.result,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.item.scientificName ?? widget.item.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInputArea(ThemeData theme) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkStone : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text input field
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Ask about this Snake...',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.black38,
                ),
                border: InputBorder.none,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          // Send button
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.sandstone : AppTheme.sandstone,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      HugeIcons.strokeRoundedMessage01,
                      color: Colors.white,
                      size: 20,
                    ),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMessage(ChatMessage message) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser)
              Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 12, top: 4),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.sandstone : AppTheme.sandstone,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  HugeIcons.strokeRoundedBot,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            Flexible(
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isUser
                          ? (isDarkMode ? AppTheme.sandstone : AppTheme.sandstone)
                          : (isDarkMode ? AppTheme.darkStone : Colors.white),
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                        bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _cleanMessage(message.message),
                      style: TextStyle(
                        color: isUser ? Colors.white : (isDarkMode ? Colors.white : Colors.black87),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(message.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDarkMode ? Colors.white54 : Colors.black38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isUser)
              Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(left: 12, top: 4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTypingIndicator() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 12, top: 4),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.sandstone : AppTheme.sandstone,
              shape: BoxShape.circle,
            ),
            child: Icon(
              HugeIcons.strokeRoundedBot,
              color: Colors.white,
              size: 20,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkStone : Colors.white,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? AppTheme.sandstone : AppTheme.sandstone,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  String _cleanMessage(String message) {
    return message
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')
        .replaceAll(RegExp(r'`(.*?)`'), r'$1')
        .replaceAll(RegExp(r'#{1,6}\s'), '')
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1')
        .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '• ')
        .replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '')
        .trim();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Assuming ChatMessage class is defined elsewhere
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
}
