// lib/presentation/screens/09_chat/clinical_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class ClinicalChatScreen extends StatefulWidget {
  const ClinicalChatScreen({super.key});

  @override
  State<ClinicalChatScreen> createState() => _ClinicalChatScreenState();
}

class _ClinicalChatScreenState extends State<ClinicalChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialMessages() {
    setState(() {
      _messages.addAll([
        ChatMessage(
          text:
          "Hello Sarah, I'm your Al-Derma Assistant. Do you have any questions about your Eczema assessment result?",
          isUser: false,
          time: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        ChatMessage(
          text: "What are the main triggers for Eczema?",
          isUser: true,
          time: DateTime.now().subtract(const Duration(minutes: 4)),
        ),
        ChatMessage(
          text: "",
          isUser: false,
          isDetailed: true,
          time: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
      ]);
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = ChatMessage(
      text: _messageController.text,
      isUser: true,
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // محاكاة رد الـ AI
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text:
              "I understand your concern. Based on your question, I recommend consulting with a dermatologist for a proper examination.",
              isUser: false,
              time: DateTime.now(),
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surface,
              AppColors.surfaceContainerLow,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Decorations
            _buildBackgroundDecorations(),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Messages List
                  Expanded(
                    child: _buildMessagesList(),
                  ),

                  // Typing Indicator
                  if (_isTyping) _buildTypingIndicator(),

                  // Input Area
                  _buildInputArea(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BACKGROUND DECORATIONS
  // ============================================================
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
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryContainer.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
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
              gradient: RadialGradient(
                colors: [
                  AppColors.secondaryContainer.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
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
                    'AL-DERMA IDENTITY',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryContainer.withOpacity(0.2),
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/100?img=5',
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

  // ============================================================
  // MESSAGES LIST
  // ============================================================
  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      itemCount: _messages.length + 1, // +1 for date divider
      itemBuilder: (context, index) {
        if (index == 0) {
          return FadeIn(
            child: _buildDateDivider(),
          );
        }

        final message = _messages[index - 1];
        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: message.isUser
              ? _buildUserMessage(message)
              : message.isDetailed
              ? _buildDetailedAIMessage()
              : _buildAIMessage(message),
        );
      },
    );
  }

  // ============================================================
  // DATE DIVIDER
  // ============================================================
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
            color: AppColors.outline,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AI MESSAGE
  // ============================================================
  Widget _buildAIMessage(ChatMessage message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
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
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              '${DateFormat('hh:mm a').format(message.time)} • AI Assistant',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAILED AI MESSAGE
  // ============================================================
  Widget _buildDetailedAIMessage() {
    final triggers = [
      {
        'icon': Icons.science_rounded,
        'text': 'Allergens (Pollen, Pet Dander)',
      },
      {
        'icon': Icons.psychology_rounded,
        'text': 'Emotional Stress & Anxiety',
      },
      {
        'icon': Icons.water_drop_rounded,
        'text': 'Dry Skin (Low Humidity)',
      },
    ];

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(24),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border(
                left: BorderSide(
                  color: AppColors.primary,
                  width: 4,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'COMMON ECZEMA TRIGGERS',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Eczema (atopic dermatitis) often flares up due to specific environmental and internal factors. Based on your profile, here are the primary triggers to watch for:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),

                // Triggers List
                ...triggers.map((trigger) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            trigger['icon'] as IconData,
                            color: AppColors.secondary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            trigger['text'] as String,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Footer Note
                Text(
                  'Would you like me to recommend a moisturizing routine for your specific skin type?',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              '${DateFormat('hh:mm a').format(DateTime.now())} • Verified AI Clinical Guidance',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // USER MESSAGE
  // ============================================================
  Widget _buildUserMessage(ChatMessage message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primaryContainer,
                  AppColors.primary,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
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
              style: AppTextStyles.caption.copyWith(
                color: AppColors.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TYPING INDICATOR
  // ============================================================
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
            children: [
              _buildTypingDot(0),
              const SizedBox(width: 4),
              _buildTypingDot(1),
              const SizedBox(width: 4),
              _buildTypingDot(2),
            ],
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
        return Transform.translate(
          offset: Offset(0, -4 * (1 - (animValue - 0.5).abs() * 2)),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.4 + animValue * 0.4),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  // ============================================================
  // INPUT AREA
  // ============================================================
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
              // Attachment Button
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_rounded),
                color: AppColors.outline,
              ),

              const SizedBox(width: 8),

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
                      hintText: 'Ask about triggers, treatment, or your results...',
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.outline.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Send Button
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
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
}

// ============================================================
// CHAT MESSAGE MODEL
// ============================================================
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isDetailed;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.isDetailed = false,
  });
}