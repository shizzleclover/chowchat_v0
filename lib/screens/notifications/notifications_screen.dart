import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../config/app_color.dart';
import '../../widgets/empty_states/contextual_empty_states.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  
  // Mock notification data
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      type: NotificationType.like,
      title: 'John liked your post',
      message: '"Amazing jollof rice at the cafeteria!"',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      avatar: null,
    ),
    NotificationItem(
      id: '2',
      type: NotificationType.comment,
      title: 'Sarah commented on your post',
      message: 'Where exactly in the cafeteria did you get this?',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      avatar: null,
    ),
    NotificationItem(
      id: '3',
      type: NotificationType.follow,
      title: 'Mike started following you',
      message: '',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
      avatar: null,
    ),
    NotificationItem(
      id: '4',
      type: NotificationType.mention,
      title: 'You were mentioned in a post',
      message: 'Check out what @you might like at the new restaurant!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      avatar: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Tab Bar
            _buildTabBar(),
            
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllNotifications(),
                  _buildMentionsNotifications(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        border: Border(
          bottom: BorderSide(
            color: AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Activity',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.lightForeground,
            ),
          ),
          const Spacer(),
          if (_getUnreadCount() > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.lightCard,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.lightPrimary,
        unselectedLabelColor: AppColors.lightMutedForeground,
        indicatorColor: AppColors.lightPrimary,
        indicatorWeight: 2,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('All'),
                if (_getUnreadCount() > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.lightDestructive,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${_getUnreadCount()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: 'Mentions'),
        ],
      ),
    );
  }

  Widget _buildAllNotifications() {
    if (_notifications.isEmpty) {
      return const ContextualEmptyStates(
        type: EmptyStateType.feed, // Using feed as placeholder
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildMentionsNotifications() {
    final mentions = _notifications
        .where((n) => n.type == NotificationType.mention)
        .toList();

    if (mentions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.alternate_email_rounded,
              size: 64,
              color: AppColors.lightMutedForeground.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No mentions yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.lightMutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When someone mentions you in a post,\nyou\'ll see it here.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.lightMutedForeground.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: mentions.length,
      itemBuilder: (context, index) {
        final notification = mentions[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: notification.isRead 
            ? AppColors.lightCard 
            : AppColors.lightPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead 
              ? AppColors.lightBorder.withValues(alpha: 0.5)
              : AppColors.lightPrimary.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildNotificationIcon(notification.type),
        title: Text(
          notification.title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.lightForeground,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.message.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                notification.message,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.lightMutedForeground,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              timeago.format(notification.timestamp),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.lightMutedForeground.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            : null,
        onTap: () {
          _markAsRead(notification.id);
          // Handle notification tap (navigate to relevant content)
        },
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.like:
        icon = Icons.favorite_rounded;
        color = AppColors.lightDestructive;
        break;
      case NotificationType.comment:
        icon = Icons.comment_rounded;
        color = AppColors.lightPrimary;
        break;
      case NotificationType.follow:
        icon = Icons.person_add_rounded;
        color = AppColors.lightAccent;
        break;
      case NotificationType.mention:
        icon = Icons.alternate_email_rounded;
        color = AppColors.lightPrimary;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  int _getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
  }
}

enum NotificationType {
  like,
  comment,
  follow,
  mention,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? avatar;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.avatar,
  });

  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? avatar,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      avatar: avatar ?? this.avatar,
    );
  }
}