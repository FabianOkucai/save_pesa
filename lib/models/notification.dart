import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType {
  transaction,
  goal,
  achievement,
  reminder,
  alert,
}

extension NotificationTypeExt on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.transaction:
        return Icons.receipt_long;
      case NotificationType.goal:
        return Icons.flag;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.reminder:
        return Icons.notifications_active;
      case NotificationType.alert:
        return Icons.warning_amber_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.transaction:
        return Colors.blue;
      case NotificationType.goal:
        return Colors.green;
      case NotificationType.achievement:
        return Colors.amber;
      case NotificationType.reminder:
        return Colors.purple;
      case NotificationType.alert:
        return Colors.red;
    }
  }
}
