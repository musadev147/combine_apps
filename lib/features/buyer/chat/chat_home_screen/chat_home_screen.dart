import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bd_shope_combined/features/buyer/chat/controllers/chat_controller.dart';
import 'package:bd_shope_combined/features/buyer/chat/models/conversation.dart';
import 'package:bd_shope_combined/features/buyer/chat/models/message.dart';
import 'package:bd_shope_combined/common_wigdets/glass_card.dart';
import 'package:bd_shope_combined/route/app_pages.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({Key? key}) : super(key: key);

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  final ChatController _controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.1), width: 1),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Messages',
              style: GoogleFonts.outfit(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 22.sp,
              ),
            ),
            actions: [
              Obx(() => IconButton(
                icon: Icon(
                  _controller.showArchived.value ? Icons.archive : Icons.archive_outlined,
                  color: _controller.showArchived.value ? const Color(0xFF53A4CA) : Colors.white,
                ),
                onPressed: () {
                  _controller.showArchived.toggle();
                },
                tooltip: 'Archived Chats',
              )),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            _buildSearchField(),
            
            // Active users horizontal list (Only show when not looking at archived and list has online users)
            Obx(() {
              if (_controller.showArchived.value) return SizedBox.shrink();
              final onlineUsers = _controller.conversations.where((c) => c.isOnline).toList();
              if (onlineUsers.isEmpty) return SizedBox.shrink();
              return _buildActiveUsersList(onlineUsers);
            }),

            // Chat lists
            Expanded(
              child: Obx(() {
                final list = _controller.filteredConversations;
                if (list.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final conv = list[index];
                    return _buildConversationTile(conv);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12.withOpacity(0.06),
          border: Border.all(
            color: const Color(0xFF53A4CA).withOpacity(0.25),
            width: 1,
          ),
        ),
        child: TextField(
          onChanged: (val) => _controller.searchQuery.value = val,
          style: GoogleFonts.poppins(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 13.sp),
          decoration: InputDecoration(
            hintText: 'Search chats or sellers...',
            hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 13.sp),
            prefixIcon: Icon(Icons.search, color: Colors.white30, size: 20.r),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveUsersList(List<ConversationModel> onlineUsers) {
    return Container(
      height: 85.h,
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: onlineUsers.length,
        itemBuilder: (context, index) {
          final conv = onlineUsers[index];
          return GestureDetector(
            onTap: () {
              _controller.selectConversation(conv);
              Get.toNamed(Routes.CHAT);
            },
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 26.r,
                        backgroundImage: NetworkImage(conv.otherUserAvatar),
                        backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 2.w,
                        child: Container(
                          width: 12.r,
                          height: 12.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.greenAccent,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  SizedBox(
                    width: 60.w,
                    child: Text(
                      conv.otherUserName.split(' ').first,
                      style: GoogleFonts.poppins(
                        color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.8),
                        fontSize: 10.sp,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(ConversationModel conv) {
    final lastMsg = conv.lastMessage;
    String previewText = 'No messages yet';
    String timeText = '';
    
    if (lastMsg != null) {
      if (lastMsg.isDeleted) {
        previewText = 'Message was deleted';
      } else {
        switch (lastMsg.type) {
          case MessageType.text:
            previewText = lastMsg.content;
            break;
          case MessageType.image:
            previewText = '📷 Photo';
            break;
          case MessageType.file:
            previewText = '📁 File: ${lastMsg.attachmentName}';
            break;
          case MessageType.voice:
            previewText = '🎤 Voice note';
            break;
        }
      }

      // Format time
      final diff = DateTime.now().difference(lastMsg.timestamp);
      if (diff.inMinutes < 1) {
        timeText = 'Just now';
      } else if (diff.inHours < 1) {
        timeText = '${diff.inMinutes}m ago';
      } else if (diff.inDays < 1) {
        timeText = '${diff.inHours}h ago';
      } else {
        timeText = '${lastMsg.timestamp.day}/${lastMsg.timestamp.month}';
      }
    }

    return Dismissible(
      key: Key(conv.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Icon(Icons.archive_outlined, color: Colors.redAccent, size: 24.r),
      ),
      confirmDismiss: (dir) async {
        _controller.toggleArchiveConversation(conv.id);
        return false; // dismiss handeled manually via reactive list
      },
      child: GestureDetector(
        onTap: () {
          _controller.selectConversation(conv);
          Get.toNamed(Routes.CHAT);
        },
        child: GlassCard(
          borderRadius: 18.r,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          color: conv.unreadCount > 0 
              ? const Color(0xFF5369CA).withOpacity(0.08)
              : Colors.white.withOpacity(0.04),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26.r,
                    backgroundImage: NetworkImage(conv.otherUserAvatar),
                    backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12,
                  ),
                  if (conv.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 11.r,
                        height: 11.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.greenAccent,
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              // Content details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conv.otherUserName,
                            style: GoogleFonts.outfit(
                              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                              fontSize: 14.sp,
                              fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          timeText,
                          style: GoogleFonts.poppins(
                            color: Colors.white30,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      conv.storeName.isNotEmpty ? conv.storeName : conv.otherUserRole,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF53A4CA).withOpacity(0.7),
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Expanded(
                          child: conv.isTyping 
                              ? Text(
                                  'typing...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.greenAccent,
                                    fontSize: 12.sp,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : Text(
                                  previewText,
                                  style: GoogleFonts.poppins(
                                    color: conv.unreadCount > 0 
                                        ? Colors.white
                                        : Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54,
                                    fontSize: 12.sp,
                                    fontWeight: conv.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                        // Unread count badge
                        if (conv.unreadCount > 0)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF7953CA), Color(0xFF53A4CA)],
                              ),
                            ),
                            child: Text(
                              '${conv.unreadCount}',
                              style: TextStyle(
                                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF53A4CA).withOpacity(0.1),
            ),
            child: Icon(
              _controller.showArchived.value ? Icons.archive : Icons.chat_bubble_outline,
              color: const Color(0xFF53A4CA),
              size: 48.r,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            _controller.showArchived.value ? 'Archive is empty' : 'No messages yet',
            style: GoogleFonts.outfit(
              color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              _controller.showArchived.value 
                  ? 'Swipe a conversation to archive it and clean up your messages inbox.'
                  : 'Start searching for sellers and products to start a conversation.',
              style: GoogleFonts.poppins(
                color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45,
                fontSize: 11.5.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
