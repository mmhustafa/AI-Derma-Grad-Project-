// lib/presentation/screens/09_chat/clinical_chat_screen.dart
//
// Chat screen connected to the real AI backend.
// On init: GET /api/Chat/welcome  → sessionId + first message
// On send: POST /api/Chat         → { sessionId, message, condition }

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/chat_model.dart';

class ClinicalChatScreen extends StatefulWidget {
  /// Optional disease condition passed from the result screen
  final String? condition;

  const ClinicalChatScreen({super.key, this.condition});

  @override
  State<ClinicalChatScreen> createState() => _ClinicalChatScreenState();
}

class _ClinicalChatScreenState extends State<ClinicalChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  String? _sessionId;
  bool _isTyping = false;
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── API Calls ───────────────────────────────────────────────────────────────

  Future<void> _initChat() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final welcome = await ApiService.getChatWelcome();
      if (!mounted) return;
      setState(() {
        _sessionId = welcome.sessionId;
        _messages.add(_ChatMessage(
          text: welcome.reply,
          isUser: false,
          time: DateTime.now(),
        ));
        _isInitializing = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not connect to the AI assistant.';
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sessionId == null) return;

    final userMsg = _ChatMessage(
      text: text,
      isUser: true,
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
      _errorMessage = null;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final request = ChatRequest(
        sessionId: _sessionId!,
        message: text,
        condition: widget.condition ?? '',
      );
      final response = await ApiService.sendChatMessage(request);

      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: response.reply,
            isUser: false,
            time: DateTime.now(),
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: 'Sorry, I could not process your request. ${e.message}',
            isUser: false,
            time: DateTime.now(),
            isError: true,
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: 'An unexpected error occurred. Please try again.',
            isUser: false,
            time: DateTime.now(),
            isError: true,
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.surface, AppColors.surfaceContainerLow],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundDecorations(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  if (_isInitializing)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else if (_errorMessage != null && _messages.isEmpty)
                    Expanded(child: _buildInitError())
                  else ...[
                    Expanded(child: _buildMessagesList()),
                    if (_isTyping) _buildTypingIndicator(),
                    _buildInputArea(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clinical Assistant',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _sessionId != null ? 'Connected' : 'Connecting...',
                    style: AppTextStyles.caption.copyWith(
                      color: _sessionId != null
                          ? AppColors.tertiary
                          : AppColors.secondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Status dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _sessionId != null
                    ? AppColors.tertiary
                    : AppColors.outlineVariant,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
              color: AppColors.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Init Error ───────────────────────────────────────────────────────────────

  Widget _buildInitError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 72, color: AppColors.outlineVariant.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _initChat,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reconnect'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Messages List ────────────────────────────────────────────────────────────

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      itemCount: _messages.length + 1, // +1 for date divider
      itemBuilder: (context, index) {
        if (index == 0) {
          return FadeIn(child: _buildDateDivider());
        }
        final message = _messages[index - 1];
        return FadeInUp(
          delay: Duration(milliseconds: 50 * index),
          child: message.isUser
              ? _buildUserMessage(message)
              : _buildAIMessage(message),
        );
      },
    );
  }

  Widget _buildDateDivider() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          'Today, ${DateFormat('MMM d').format(DateTime.now())}',
          style: AppTextStyles.caption.copyWith(
              color: AppColors.outline, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildAIMessage(_ChatMessage message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85),
            decoration: BoxDecoration(
              color: message.isError
                  ? AppColors.error.withOpacity(0.08)
                  : AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: message.isError
                  ? Border.all(color: AppColors.error.withOpacity(0.2))
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: message.isError
                    ? AppColors.error
                    : AppColors.onSurface,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              '${DateFormat('hh:mm a').format(message.time)} • AI Assistant',
              style: AppTextStyles.caption.copyWith(color: AppColors.outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(_ChatMessage message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryContainer, AppColors.primary],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x26006874),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 16),
            child: Text(
              DateFormat('hh:mm a').format(message.time),
              style: AppTextStyles.caption.copyWith(color: AppColors.outline),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Typing Indicator ─────────────────────────────────────────────────────────

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => _buildTypingDot(i)),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = ((value - delay) * 2).clamp(0.0, 1.0);
        return Padding(
          padding: EdgeInsets.only(right: index < 2 ? 4 : 0),
          child: Transform.translate(
            offset: Offset(0, -4 * (1 - (animValue - 0.5).abs() * 2)),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color:
                    AppColors.primary.withOpacity(0.4 + animValue * 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
  }

  // ─── Input Area ───────────────────────────────────────────────────────────────

  Widget _buildInputArea() {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Text Field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about your condition...',
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.outline.withOpacity(0.7)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.onSurface),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    enabled: _sessionId != null && !_isTyping,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Send Button
              GestureDetector(
                onTap: (_sessionId != null && !_isTyping) ? _sendMessage : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: (_sessionId != null && !_isTyping)
                        ? AppColors.primaryGradient
                        : null,
                    color: (_sessionId == null || _isTyping)
                        ? AppColors.surfaceContainerHigh
                        : null,
                    shape: BoxShape.circle,
                    boxShadow: (_sessionId != null && !_isTyping)
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: (_sessionId != null && !_isTyping)
                        ? Colors.white
                        : AppColors.outlineVariant,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Background ───────────────────────────────────────────────────────────────

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              gradient: RadialGradient(colors: [
                AppColors.primaryContainer.withOpacity(0.05),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(colors: [
                AppColors.secondaryContainer.withOpacity(0.1),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Chat Message Model ───────────────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isError;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.isError = false,
  });
}