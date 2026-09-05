import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:async';
import 'dart:io';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/chat_controller.dart';
import 'models/message.dart';
import 'models/conversation.dart';
import 'package:bd_shope_combined/common_wigdets/glass_card.dart';
import 'package:bd_shope_combined/route/app_pages.dart';

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({Key? key}) : super(key: key);

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final ChatController _controller = Get.find<ChatController>();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final RxBool _showSearchLocal = false.obs;
  final FocusNode _focusNode = FocusNode();

  // Simulated voice recording state
  final RxBool _isRecordingVoice = false.obs;
  final RxInt _recordingSeconds = 0.obs;
  Timer? _voiceRecordTimer;

  // Custom Emoji List
  final List<String> _emojis = [
    '😀', '😂', '😍', '😊', '👍', '🔥', '🎉', '❤️', 
    '🙌', '👏', '🤔', '😎', '💡', '🌟', '🛒', '📦',
    '💰', '📱', '💻', '👜', '🚀', '💯', '✨', '🤝'
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _voiceRecordTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100.h,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _startVoiceRecording() {
    _focusNode.unfocus();
    _isRecordingVoice.value = true;
    _recordingSeconds.value = 0;
    _voiceRecordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingSeconds.value++;
    });
  }

  void _stopVoiceRecording({required bool mustSend}) {
    _voiceRecordTimer?.cancel();
    _isRecordingVoice.value = false;
    if (mustSend && _recordingSeconds.value > 0) {
      _controller.sendVoiceMessage(Duration(seconds: _recordingSeconds.value));
    }
    _recordingSeconds.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    // Schedule scroll to bottom once messages build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7953CA),
              Color(0xFF5369CA),
              Color(0xFF53A4CA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Chat Header
              _buildAppBar(),

              // Local Search Box
              Obx(() => _showSearchLocal.value ? _buildLocalSearchField() : SizedBox.shrink()),

              // Messages List
              Expanded(
                child: Obx(() {
                  final active = _controller.activeConversation.value;
                  if (active == null) {
                    return Center(child: Text('No active conversation', style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54)));
                  }

                  // If searching, filter locally
                  List<MessageModel> listToRender = active.messages;
                  if (_controller.chatSearchQuery.value.trim().isNotEmpty) {
                    listToRender = _controller.activeChatSearchResults;
                  }

                  if (listToRender.isEmpty) {
                    return _buildEmptyChatState();
                  }

                  // Auto scroll when list size changes
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: listToRender.length,
                    itemBuilder: (context, index) {
                      final msg = listToRender[index];
                      final isMe = msg.senderId == _controller.currentUserId;
                      return _buildMessageRow(msg, isMe, active);
                    },
                  );
                }),
              ),

              // Typing Indicator
              Obx(() {
                final active = _controller.activeConversation.value;
                if (active != null && active.isTyping) {
                  return _buildTypingIndicator(active);
                }
                return SizedBox.shrink();
              }),

              // Input Bar & Action Triggers
              _buildInputArea(),

              // Custom Emoji Drawer
              Obx(() => _controller.showEmojiPicker.value ? _buildEmojiPicker() : SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Obx(() {
      final active = _controller.activeConversation.value;
      if (active == null) return SizedBox.shrink();

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.12), width: 1),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
              onPressed: () => Get.back(),
            ),
            // Audio Call button
            GestureDetector(
              onTap: () => _showUserProfilePreview(active),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage: NetworkImage(active.otherUserAvatar),
                  ),
                  if (active.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10.r,
                        height: 10.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.greenAccent,
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: GestureDetector(
                onTap: () => _showUserProfilePreview(active),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      active.otherUserName,
                      style: GoogleFonts.outfit(
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      active.isBlocked 
                          ? 'Blocked' 
                          : (active.isOnline ? 'Online now' : 'Offline'),
                      style: GoogleFonts.poppins(
                        color: active.isBlocked 
                            ? Colors.redAccent
                            : (active.isOnline ? Colors.greenAccent : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search, color: _showSearchLocal.value ? const Color(0xFF53A4CA) : Colors.white),
              onPressed: () {
                _showSearchLocal.toggle();
                if (!_showSearchLocal.value) {
                  _controller.chatSearchQuery.value = '';
                }
              },
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
              color: const Color(0xFF1E1435),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              onSelected: (val) {
                switch (val) {
                  case 'audio_call':
                    _startCall(false);
                    break;

                  case 'video_call':
                    _startCall(true);
                    break;

                  case 'block':
                    _controller.blockOrUnblockUser();
                    break;

                  case 'archive':
                    _controller.toggleArchiveConversation(active.id);
                    break;
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'audio_call',
                  child: Row(
                    children: [
                      Icon(Icons.call, color: Colors.green),
                      SizedBox(width: 10),
                      Text(
                        'Audio Call',
                        style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                      ),
                    ],
                  ),
                ),

                PopupMenuItem(
                  value: 'video_call',
                  child: Row(
                    children: [
                      Icon(Icons.videocam, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        'Video Call',
                        style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                      ),
                    ],
                  ),
                ),

                PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text(
                        active.isBlocked ? 'Unblock User' : 'Block & Report',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),

                PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(Icons.archive, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                      SizedBox(width: 10),
                      Text(
                        active.isArchived ? 'Move to Inbox' : 'Archive Chat',
                        style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLocalSearchField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: Colors.black.withOpacity(0.2),
      child: TextField(
        onChanged: (val) => _controller.chatSearchQuery.value = val,
        style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search messages inside this chat...',
          hintStyle: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45, fontSize: 13),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(Icons.close, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45, size: 18),
            onPressed: () {
              _showSearchLocal.value = false;
              _controller.chatSearchQuery.value = '';
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMessageRow(MessageModel msg, bool isMe, ConversationModel active) {
    if (msg.isDeleted) {
      return _buildDeletedMessage(isMe);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Reply Preview Bubble if message is replying to another message
            if (msg.replyToId != null)
              Container(
                margin: EdgeInsets.only(bottom: 2.h, left: isMe ? 40.w : 0, right: isMe ? 0 : 40.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'Replying to ${msg.replyToSenderName}: ${msg.replyToContent}',
                  style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, fontSize: 9.sp, fontStyle: FontStyle.italic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Forwarded Tag
            if (msg.isForwarded)
              Padding(
                padding: EdgeInsets.only(left: 6.w, bottom: 2.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.forward, size: 10.r, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54),
                    SizedBox(width: 4.w),
                    Text('Forwarded', style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, fontSize: 9.sp)),
                  ],
                ),
              ),

            // Main Bubble Gesture
            GestureDetector(
              onLongPress: () => _showMessageActionsBottomSheet(msg, active),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isMe) ...[
                    CircleAvatar(
                      radius: 12.r,
                      backgroundImage: NetworkImage(active.otherUserAvatar),
                    ),
                    SizedBox(width: 6.w),
                  ],
                  Flexible(
                    child: _buildBubbleContent(msg, isMe),
                  ),
                ],
              ),
            ),

            // Status Indicator Row (Only for me)
            SizedBox(height: 3.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.white30, fontSize: 8.sp),
                ),
                if (isMe) ...[
                  SizedBox(width: 4.w),
                  _buildMessageStatusIcon(msg.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubbleContent(MessageModel msg, bool isMe) {
    final bubbleColor = isMe 
        ? const Color(0xFF5369CA).withOpacity(0.85)
        : Colors.white.withOpacity(0.12);

    switch (msg.type) {
      case MessageType.text:
        return GlassCard(
          borderRadius: 16.r,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          color: bubbleColor,
          child: Text(
            msg.content,
            style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 13.sp),
          ),
        );
      case MessageType.image:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.file(
              File(msg.content),
              width: 200.w,
              height: 200.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.network(
                'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
                width: 200.w,
                height: 200.h,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      case MessageType.file:
        return GlassCard(
          borderRadius: 16.r,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          color: bubbleColor,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insert_drive_file, color: const Color(0xFF53A4CA), size: 28.r),
              SizedBox(width: 8.w),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.attachmentName ?? 'File',
                      style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      msg.attachmentSize ?? 'Unknown size',
                      style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case MessageType.voice:
        return _buildVoicePlayerBubble(msg, bubbleColor);
    }
  }

  Widget _buildVoicePlayerBubble(MessageModel msg, Color color) {
    // Simulated Voice player
    final RxBool isPlaying = false.obs;
    final RxDouble sliderProgress = 0.0.obs;
    Timer? playTimer;

    return GlassCard(
      borderRadius: 16.r,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      color: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => IconButton(
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            icon: Icon(isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, size: 30.r),
            onPressed: () {
              isPlaying.toggle();
              if (isPlaying.value) {
                playTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
                  sliderProgress.value += 0.05;
                  if (sliderProgress.value >= 1.0) {
                    sliderProgress.value = 0.0;
                    isPlaying.value = false;
                    timer.cancel();
                  }
                });
              } else {
                playTimer?.cancel();
              }
            },
          )),
          SizedBox(width: 6.w),
          // Custom simulated waveform slider
          SizedBox(
            width: 110.w,
            child: Obx(() => SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: SliderComponentShape.noThumb,
                trackHeight: 2,
                activeTrackColor: Colors.white,
                inactiveTrackColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
              ),
              child: Slider(
                value: sliderProgress.value,
                onChanged: (val) {
                  sliderProgress.value = val;
                },
              ),
            )),
          ),
          SizedBox(width: 4.w),
          Text(
            '${msg.voiceDuration?.inSeconds ?? 0}s',
            style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildDeletedMessage(bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        child: GlassCard(
          borderRadius: 16.r,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, color: Colors.white30, size: 14.r),
              SizedBox(width: 6.w),
              Text(
                'This message was deleted',
                style: GoogleFonts.poppins(
                  color: Colors.white30,
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icon(Icons.check_circle_outline, color: Colors.white30, size: 10.r);
      case MessageStatus.delivered:
        return Icon(Icons.check_circle, color: Colors.white30, size: 10.r);
      case MessageStatus.seen:
        return Obx(() {
          final active = _controller.activeConversation.value;
          return CircleAvatar(
            radius: 5.r,
            backgroundImage: NetworkImage(active?.otherUserAvatar ?? ''),
          );
        });
    }
  }

  Widget _buildTypingIndicator(ConversationModel active) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 8.r, backgroundImage: NetworkImage(active.otherUserAvatar)),
          SizedBox(width: 6.w),
          Text(
            'typing...',
            style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 10.sp, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Obx(() {
      final active = _controller.activeConversation.value;
      if (active == null) return SizedBox.shrink();

      if (active.isBlocked) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          color: Colors.black26,
          child: Center(
            child: Text(
              'You have blocked this user. Unblock to resume chat.',
              style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, fontSize: 12.sp),
            ),
          ),
        );
      }

      return Container(
        padding: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 8.h, top: 4.h),
        decoration: BoxDecoration(
          color: Colors.black12,
          border: Border(top: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.08))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply Preview Header in bar
            if (_controller.replyingTo.value != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.05),
                child: Row(
                  children: [
                    Icon(Icons.reply, color: const Color(0xFF53A4CA), size: 14.r),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Replying to: ${_controller.replyingTo.value!.content}',
                        style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, size: 16),
                      onPressed: () => _controller.setReplyingTo(null),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.emoji_emotions_outlined, color: _controller.showEmojiPicker.value ? const Color(0xFF53A4CA) : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54),
                  onPressed: () {
                    _controller.showEmojiPicker.toggle();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.attach_file, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54),
                  onPressed: () => _controller.pickAndSendFile(),
                ),
                
                // Text Field / Voice recorder slider
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: _isRecordingVoice.value 
                        ? _buildVoiceRecordingSlider()
                        : TextField(
                            focusNode: _focusNode,
                            controller: _textController,
                            style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 14),
                            onTap: () {
                              _controller.showEmojiPicker.value = false;
                            },
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Colors.white30),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                            ),
                          ),
                  ),
                ),

                // Voice Recording trigger or Send Button
                Obx(() {
                  final textEmpty = _textController.text.trim().isEmpty;
                  
                  if (textEmpty && !_isRecordingVoice.value) {
                    return GestureDetector(
                      onLongPress: () => _startVoiceRecording(),
                      onLongPressUp: () => _stopVoiceRecording(mustSend: true),
                      child: IconButton(
                        icon: Icon(Icons.mic, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54),
                        onPressed: () {
                          Get.snackbar('Tip', 'Press and hold microphone to record voice messages', backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12);
                        },
                      ),
                    );
                  }

                  if (_isRecordingVoice.value) {
                    return IconButton(
                      icon: Icon(Icons.send, color: Colors.greenAccent),
                      onPressed: () => _stopVoiceRecording(mustSend: true),
                    );
                  }

                  return IconButton(
                    icon: Icon(Icons.send, color: Color(0xFF53A4CA)),
                    onPressed: () {
                      _controller.sendMessage(_textController.text);
                      _textController.clear();
                    },
                  );
                }),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildVoiceRecordingSlider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 16),
          SizedBox(width: 8.w),
          Obx(() => Text(
            'Recording: ${_recordingSeconds.value}s',
            style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 13),
          )),
          const Spacer(),
          GestureDetector(
            onTap: () => _stopVoiceRecording(mustSend: false),
            child: Text('Cancel', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return Container(
      height: 180.h,
      color: Colors.black.withOpacity(0.2),
      child: GridView.builder(
        padding: EdgeInsets.all(12.r),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: _emojis.length,
        itemBuilder: (ctx, idx) {
          final emo = _emojis[idx];
          return GestureDetector(
            onTap: () {
              _textController.text = _textController.text + emo;
            },
            child: Center(
              child: Text(emo, style: TextStyle(fontSize: 26.r)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12, size: 48.r),
          SizedBox(height: 12.h),
          Text(
            'No messages inside this chat',
            style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6.h),
          Text(
            'Send an emoji, file, voice note, or text to start.',
            style: GoogleFonts.poppins(color: Colors.white30, fontSize: 11.sp),
          ),
        ],
      ),
    );
  }

  void _showMessageActionsBottomSheet(MessageModel msg, ConversationModel active) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1435).withOpacity(0.95),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
          border: Border.all(color: const Color(0xFF53A4CA).withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12, borderRadius: BorderRadius.circular(2.r))),
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(Icons.reply, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
              title: Text('Reply', style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black)),
              onTap: () {
                _controller.setReplyingTo(msg);
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.forward, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
              title: Text('Forward', style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black)),
              onTap: () {
                Get.back();
                _showForwardSelectionSheet(msg);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.redAccent),
              title: Text('Delete Message', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                _controller.deleteMessage(msg.id);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showForwardSelectionSheet(MessageModel msg) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1435).withOpacity(0.95),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Forward message to:', style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            Expanded(
              child: ListView.builder(
                itemCount: _controller.conversations.length,
                itemBuilder: (ctx, idx) {
                  final c = _controller.conversations[idx];
                  if (c.id == _controller.activeConversation.value?.id) return SizedBox.shrink();
                  return ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(c.otherUserAvatar)),
                    title: Text(c.otherUserName, style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black)),
                    onTap: () {
                      _controller.forwardMessage(msg, c.id);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserProfilePreview(ConversationModel active) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1435).withOpacity(0.98),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
          border: Border.all(color: const Color(0xFF53A4CA).withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40.r,
              backgroundImage: NetworkImage(active.otherUserAvatar),
            ),
            SizedBox(height: 12.h),
            Text(active.otherUserName, style: GoogleFonts.outfit(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold)),
            Text(active.otherUserRole, style: GoogleFonts.poppins(color: const Color(0xFF53A4CA), fontSize: 11.sp, fontWeight: FontWeight.w600)),
            if (active.storeName.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(active.storeName, style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54, fontSize: 13.sp)),
            ],
            SizedBox(height: 16.h),
            Divider(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4.w),
                        Text('4.9', style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('Rating', style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45, fontSize: 10.sp)),
                  ],
                ),
                Column(
                  children: [
                    Text('150+', style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    Text('Products', style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45, fontSize: 10.sp)),
                  ],
                ),
                Column(
                  children: [
                    Text('24h', style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    Text('Avg Reply', style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45, fontSize: 10.sp)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      // Perform simulated Call action
                      _controller.sendMessage('Starting audio call...', type: MessageType.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5369CA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('Call Seller'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                      _controller.blockOrUnblockUser();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(active.isBlocked ? 'Unblock' : 'Block User', style: TextStyle(color: Colors.redAccent)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _startCall(bool isVideo) {
    final active = _controller.activeConversation.value;
    if (active == null) return;
    Get.toNamed(Routes.CALL, arguments: {
      'conversationId': active.id,
      'isVideo': isVideo,
    });
  }
}
