import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bd_shope_combined/features/buyer/chat/models/message.dart';
import 'package:bd_shope_combined/features/buyer/chat/models/conversation.dart';

class ChatController extends GetxController {
  final _storage = GetStorage();
  final String currentUserId = 'current_user_123';
  final String currentUserName = 'John (You)';

  final conversations = <ConversationModel>[].obs;
  final activeConversation = Rxn<ConversationModel>();
  final isSearching = false.obs;
  final searchQuery = ''.obs;
  final chatSearchQuery = ''.obs;
  final showArchived = false.obs;
  
  // Typing indicators
  final typingTimer = Rxn<Timer>();
  
  // For replying to messages
  final replyingTo = Rxn<MessageModel>();

  // Emoji picker visibility
  final showEmojiPicker = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  void loadConversations() {
    // Attempt to load from storage
    final storedData = _storage.read<String>('chat_conversations');
    if (storedData != null) {
      // For simplicity, we can load mock data or deserialization.
      // Let's initialize default mock conversations for a premium experience
      _initMockConversations();
    } else {
      _initMockConversations();
    }
  }

  void _initMockConversations() {
    conversations.assignAll([
      ConversationModel(
        id: 'conv_support',
        otherUserId: 'user_support',
        otherUserName: 'Customer Support Bot',
        otherUserAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
        otherUserRole: 'Support Specialist',
        storeName: 'BD-Shope Support',
        isOnline: true,
        unreadCount: 0,
        messages: [
          MessageModel(
            id: 'ms1',
            senderId: 'user_support',
            receiverId: currentUserId,
            content: 'Welcome to BD-Shope Customer Support! How can we help you today?',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            status: MessageStatus.seen,
          ),
        ],
      ),
      ConversationModel(
        id: 'conv_1',
        otherUserId: 'user_emma',
        otherUserName: 'Emma Watson',
        otherUserAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        otherUserRole: 'Diamond Seller',
        storeName: 'Emma Boutique',
        isOnline: true,
        unreadCount: 2,
        messages: [
          MessageModel(
            id: 'm1',
            senderId: 'user_emma',
            receiverId: currentUserId,
            content: 'Hello! I noticed you were looking at our luxury bags.',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
            status: MessageStatus.seen,
          ),
          MessageModel(
            id: 'm2',
            senderId: 'user_emma',
            receiverId: currentUserId,
            content: 'We currently have a 10% discount on first orders. Let me know if you have any questions!',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(minutes: 29)),
            status: MessageStatus.seen,
          ),
        ],
      ),
      ConversationModel(
        id: 'conv_2',
        otherUserId: 'user_alex',
        otherUserName: 'Alex Rivers',
        otherUserAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        otherUserRole: 'Platinum Seller',
        storeName: 'Rivers Tech Store',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
        messages: [
          MessageModel(
            id: 'm3',
            senderId: currentUserId,
            receiverId: 'user_alex',
            content: 'Is the iPhone 15 Pro Max in stock?',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            status: MessageStatus.seen,
          ),
          MessageModel(
            id: 'm4',
            senderId: 'user_alex',
            receiverId: currentUserId,
            content: 'Yes! We have 2 units left in Titanium Gray.',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 58)),
            status: MessageStatus.seen,
          ),
        ],
      ),
      ConversationModel(
        id: 'conv_3',
        otherUserId: 'user_sophia',
        otherUserName: 'Sophia Loren',
        otherUserAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        otherUserRole: 'Gold Seller',
        storeName: 'Organic Harvest',
        isOnline: true,
        unreadCount: 0,
        messages: [
          MessageModel(
            id: 'm5',
            senderId: 'user_sophia',
            receiverId: currentUserId,
            content: 'Sure! Here is the wholesale catalog.',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            status: MessageStatus.seen,
          ),
        ],
      ),
    ]);
  }

  // Get total unread count
  int get totalUnreadCount {
    return conversations.where((c) => !c.isArchived).fold(0, (sum, c) => sum + c.unreadCount);
  }

  // Filtered conversations based on search query and archived tab
  List<ConversationModel> get filteredConversations {
    return conversations.where((c) {
      final matchesSearch = c.otherUserName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          c.storeName.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesArchive = c.isArchived == showArchived.value;
      return matchesSearch && matchesArchive;
    }).toList();
  }

  // Select conversation
  void selectConversation(ConversationModel conv) {
    activeConversation.value = conv;
    // Mark as read
    final index = conversations.indexWhere((c) => c.id == conv.id);
    if (index != -1) {
      final updated = conversations[index].copyWith(unreadCount: 0);
      for (var msg in updated.messages) {
        if (msg.senderId != currentUserId && msg.status != MessageStatus.seen) {
          msg.status = MessageStatus.seen;
        }
      }
      conversations[index] = updated;
      activeConversation.value = updated;
    }
  }

  // Send message
  void sendMessage(String content, {MessageType type = MessageType.text, String? attachmentName, String? attachmentSize, Duration? voiceDuration}) {
    final active = activeConversation.value;
    if (active == null) return;
    if (active.isBlocked) {
      Get.snackbar('Blocked', 'You cannot send messages to a blocked user.',
          backgroundColor: Colors.redAccent.withOpacity(0.8), colorText: Colors.white);
      return;
    }

    final newMsg = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUserId,
      receiverId: active.otherUserId,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      replyToId: replyingTo.value?.id,
      replyToContent: replyingTo.value?.content,
      replyToSenderName: replyingTo.value?.senderId == currentUserId ? currentUserName : active.otherUserName,
      attachmentName: attachmentName,
      attachmentSize: attachmentSize,
      voiceDuration: voiceDuration,
    );

    // Add message locally
    final index = conversations.indexWhere((c) => c.id == active.id);
    if (index != -1) {
      final updatedMessages = List<MessageModel>.from(conversations[index].messages)..add(newMsg);
      final updated = conversations[index].copyWith(messages: updatedMessages);
      conversations[index] = updated;
      activeConversation.value = updated;
      
      // Reset reply state
      replyingTo.value = null;

      // Simulate status transition: Sent -> Delivered -> Seen
      _simulateDeliveryReceipts(convId: active.id, msgId: newMsg.id);

      // Trigger automatic simulation reply after delay
      _triggerSimulationReply(active.id, content, type);
    }
  }

  void _simulateDeliveryReceipts({required String convId, required String msgId}) {
    Timer(const Duration(milliseconds: 600), () {
      final cIdx = conversations.indexWhere((c) => c.id == convId);
      if (cIdx != -1) {
        final messages = conversations[cIdx].messages;
        final mIdx = messages.indexWhere((m) => m.id == msgId);
        if (mIdx != -1 && messages[mIdx].status == MessageStatus.sent) {
          messages[mIdx].status = MessageStatus.delivered;
          conversations[cIdx] = conversations[cIdx].copyWith(messages: List.from(messages));
          if (activeConversation.value?.id == convId) {
            activeConversation.value = conversations[cIdx];
          }
        }
      }
    });

    Timer(const Duration(milliseconds: 1500), () {
      final cIdx = conversations.indexWhere((c) => c.id == convId);
      if (cIdx != -1) {
        final messages = conversations[cIdx].messages;
        final mIdx = messages.indexWhere((m) => m.id == msgId);
        if (mIdx != -1 && messages[mIdx].status == MessageStatus.delivered) {
          messages[mIdx].status = MessageStatus.seen;
          conversations[cIdx] = conversations[cIdx].copyWith(messages: List.from(messages));
          if (activeConversation.value?.id == convId) {
            activeConversation.value = conversations[cIdx];
          }
        }
      }
    });
  }

  void _triggerSimulationReply(String convId, String userMessage, MessageType type) {
    final cIdx = conversations.indexWhere((c) => c.id == convId);
    if (cIdx == -1) return;

    final conv = conversations[cIdx];
    
    // Simulate other user typing indicator after 1 second
    Timer(const Duration(seconds: 1), () {
      final idx = conversations.indexWhere((c) => c.id == convId);
      if (idx != -1) {
        conversations[idx] = conversations[idx].copyWith(isTyping: true);
        if (activeConversation.value?.id == convId) {
          activeConversation.value = conversations[idx];
        }
      }
    });

    // Simulate other user sending message after 3 seconds
    Timer(const Duration(seconds: 3), () {
      final idx = conversations.indexWhere((c) => c.id == convId);
      if (idx != -1) {
        // Stop typing
        conversations[idx] = conversations[idx].copyWith(isTyping: false);

        String replyContent = 'That sounds great! How can I help you further?';
        MessageType replyType = MessageType.text;
        String? attachName;
        String? attachSize;

        if (convId == 'conv_support') {
          if (type == MessageType.image) {
            replyContent = 'I have received the screenshot/image. Let me forward this to our technical support team for review.';
          } else if (type == MessageType.voice) {
            replyContent = 'Received your voice note. I am playing it now to understand the issue.';
          } else if (userMessage.toLowerCase().contains('order')) {
            replyContent = 'You can track all order updates in the "My Orders" tab on your home screen or contact the seller directly via chat.';
          } else if (userMessage.toLowerCase().contains('refund') || userMessage.toLowerCase().contains('return')) {
            replyContent = 'To request a refund, please send us the order ID. Refund processing usually takes 3-5 business days once approved.';
          } else if (userMessage.toLowerCase().contains('payment') || userMessage.toLowerCase().contains('bkash') || userMessage.toLowerCase().contains('nagad')) {
            replyContent = 'If your payment was deducted but the order status has not updated, please share the Transaction ID (TxnID) here.';
          } else if (userMessage.toLowerCase().contains('hello') || userMessage.toLowerCase().contains('hi')) {
            replyContent = 'Hi there! I am the BD-Shope Customer Support assistant. How can I help you today?';
          } else {
            replyContent = 'Thanks for describing the issue. Our support agent has been notified and will connect with you shortly.';
          }
        } else {
          if (type == MessageType.image) {
            replyContent = 'Wow! Thanks for sharing the product image. I will check its availability.';
          } else if (type == MessageType.voice) {
            replyContent = 'Got your voice message. I will review it shortly.';
          } else if (userMessage.toLowerCase().contains('price') || userMessage.toLowerCase().contains('discount')) {
            replyContent = 'We offer wholesale discounts starting from 20% on orders above \$500!';
          } else if (userMessage.toLowerCase().contains('ship') || userMessage.toLowerCase().contains('deliver')) {
            replyContent = 'We ship via DHL/FedEx. Delivery usually takes 2-3 business days.';
          } else if (userMessage.toLowerCase().contains('hello') || userMessage.toLowerCase().contains('hi')) {
            replyContent = 'Hello there! Let me know if you would like to start an audio or video call.';
          }
        }

        final replyMsg = MessageModel(
          id: 'msg_reply_${DateTime.now().millisecondsSinceEpoch}',
          senderId: conv.otherUserId,
          receiverId: currentUserId,
          content: replyContent,
          type: replyType,
          timestamp: DateTime.now(),
          status: MessageStatus.seen,
          attachmentName: attachName,
          attachmentSize: attachSize,
        );

        final updatedMsgs = List<MessageModel>.from(conversations[idx].messages)..add(replyMsg);
        
        // If not looking at the conversation, increment unreadCount
        final bool isCurrent = activeConversation.value?.id == convId;
        final unreadInc = isCurrent ? 0 : 1;

        conversations[idx] = conversations[idx].copyWith(
          messages: updatedMsgs,
          unreadCount: conversations[idx].unreadCount + unreadInc,
        );

        if (isCurrent) {
          activeConversation.value = conversations[idx];
        } else {
          // Trigger a simulated push notification
          _triggerMockPushNotification(conv.otherUserName, replyContent);
        }
      }
    });
  }

  void _triggerMockPushNotification(String sender, String content) {
    Get.snackbar(
      sender,
      content,
      icon: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: CircleAvatar(
          backgroundColor: Color(0xFF5369CA),
          child: Icon(Icons.message, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, size: 20),
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black.withOpacity(0.75),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
      borderRadius: 16,
      borderColor: const Color(0xFF53A4CA).withOpacity(0.3),
      borderWidth: 1,
    );
  }

  // Delete message
  void deleteMessage(String msgId) {
    final active = activeConversation.value;
    if (active == null) return;

    final index = conversations.indexWhere((c) => c.id == active.id);
    if (index != -1) {
      final messages = conversations[index].messages;
      final mIdx = messages.indexWhere((m) => m.id == msgId);
      if (mIdx != -1) {
        messages[mIdx].isDeleted = true;
        conversations[index] = conversations[index].copyWith(messages: List.from(messages));
        activeConversation.value = conversations[index];
      }
    }
  }

  // Reply message trigger
  void setReplyingTo(MessageModel? msg) {
    replyingTo.value = msg;
  }

  // Forward message to another user/conversation
  void forwardMessage(MessageModel msg, String targetConvId) {
    final targetIdx = conversations.indexWhere((c) => c.id == targetConvId);
    if (targetIdx == -1) return;

    final target = conversations[targetIdx];
    final forwardedMsg = MessageModel(
      id: 'msg_fwd_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUserId,
      receiverId: target.otherUserId,
      content: msg.content,
      type: msg.type,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      isForwarded: true,
      attachmentName: msg.attachmentName,
      attachmentSize: msg.attachmentSize,
      voiceDuration: msg.voiceDuration,
    );

    final updatedMsgs = List<MessageModel>.from(target.messages)..add(forwardedMsg);
    conversations[targetIdx] = target.copyWith(messages: updatedMsgs);
    
    _simulateDeliveryReceipts(convId: targetConvId, msgId: forwardedMsg.id);
    
    Get.snackbar(
      'Forwarded',
      'Message forwarded to ${target.otherUserName}',
      backgroundColor: const Color(0xFF53A4CA).withOpacity(0.2),
      colorText: Colors.white,
    );
  }

  // File picker upload simulation
  Future<void> pickAndSendFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final platformFile = result.files.single;
        final name = platformFile.name;
        final sizeKb = (platformFile.size / 1024).toStringAsFixed(1);
        final ext = platformFile.extension?.toLowerCase() ?? '';

        final isImage = ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext);
        final type = isImage ? MessageType.image : MessageType.file;

        sendMessage(
          platformFile.path!,
          type: type,
          attachmentName: name,
          attachmentSize: '$sizeKb KB',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file: $e', backgroundColor: Colors.redAccent);
    }
  }

  // Send simulated voice message
  void sendVoiceMessage(Duration duration) {
    sendMessage(
      'voice_recording_placeholder.mp3',
      type: MessageType.voice,
      voiceDuration: duration,
    );
  }

  // Block and report user
  void blockOrUnblockUser() {
    final active = activeConversation.value;
    if (active == null) return;

    final index = conversations.indexWhere((c) => c.id == active.id);
    if (index != -1) {
      final newBlockedStatus = !active.isBlocked;
      conversations[index] = conversations[index].copyWith(
        isBlocked: newBlockedStatus,
        isOnline: newBlockedStatus ? false : active.isOnline,
      );
      activeConversation.value = conversations[index];
      
      Get.snackbar(
        newBlockedStatus ? 'Blocked' : 'Unblocked',
        'You have ${newBlockedStatus ? 'blocked' : 'unblocked'} ${active.otherUserName}',
        backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
        colorText: Colors.white,
      );
    }
  }

  // Toggle archive
  void toggleArchiveConversation(String convId) {
    final index = conversations.indexWhere((c) => c.id == convId);
    if (index != -1) {
      final isArchived = !conversations[index].isArchived;
      conversations[index] = conversations[index].copyWith(isArchived: isArchived);
      
      // If we archive active, close it
      if (activeConversation.value?.id == convId) {
        activeConversation.value = null;
      }

      Get.snackbar(
        isArchived ? 'Archived' : 'Unarchived',
        'Conversation is ${isArchived ? 'moved to archive' : 'restored'}',
        backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
        colorText: Colors.white,
      );
    }
  }

  // Search inside messages of the active chat
  List<MessageModel> get activeChatSearchResults {
    final active = activeConversation.value;
    if (active == null || chatSearchQuery.value.trim().isEmpty) return [];

    return active.messages.where((m) {
      if (m.isDeleted) return false;
      return m.content.toLowerCase().contains(chatSearchQuery.value.toLowerCase());
    }).toList();
  }
}
