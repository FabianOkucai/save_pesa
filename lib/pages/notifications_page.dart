import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../models/notification.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.burgundy,
        foregroundColor: Colors.white,
        actions: [
          if (appState.notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                appState.markAllNotificationsRead();
              },
              child: const Text('Mark all read', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          if (appState.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('We\'ll notify you about important updates', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appState.notifications.length,
            itemBuilder: (context, index) {
              final notif = appState.notifications[index];
              return _NotificationCard(notification: notif);
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const _NotificationCard({required this.notification});

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : AppColors.gold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead ? Colors.grey[200]! : AppColors.gold.withOpacity(0.3),
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: notification.type.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(notification.type.icon, color: notification.type.color, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.burgundy,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              notification.message,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(notification.timestamp),
              style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w600),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            appState.markNotificationRead(notification.id);
          }
        },
      ),
    );
  }
}
