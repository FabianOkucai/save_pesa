import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';
import '../theme.dart';
import '../models/notification.dart';
import '../ai_service.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text('NOTIFICATIONS',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
        backgroundColor: AppColors.burgundy,
        foregroundColor: Colors.white,
        actions: [
          if (appState.notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                appState.markAllNotificationsRead();
              },
              child: Text('Mark all read',
                  style: GoogleFonts.plusJakartaSans(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
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
                  Icon(Icons.notifications_off_outlined,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No notifications yet',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  Text('We\'ll notify you about important updates',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── AI Advisor section ──
              FutureBuilder<String>(
                future: AIService.instance
                    .getFinancialAdvice(appState.transactions, appState.goals),
                builder: (context, snapshot) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E26),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.psychology_outlined,
                                  color: AppColors.gold, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'AI FINANCIAL ADVISOR',
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 1.5),
                            ),
                            const Spacer(),
                            const Icon(Icons.auto_awesome,
                                color: AppColors.gold, size: 14),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const Center(
                              child: Padding(
                            padding: EdgeInsets.all(20),
                            child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    color: AppColors.gold, strokeWidth: 2)),
                          ))
                        else
                          Text(
                            snapshot.data ?? 'Analyzing financial data...',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              Text('GENERAL UPDATES',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.grey)),
              const SizedBox(height: 16),
              ...appState.notifications
                  .map((notif) => _NotificationCard(notification: notif)),
              const SizedBox(height: 100),
            ],
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : AppColors.gold.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: notification.isRead
              ? AppColors.silver.withOpacity(0.5)
              : AppColors.gold.withOpacity(0.2),
          width: notification.isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.type.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(notification.type.icon,
              color: notification.type.color, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight:
                      notification.isRead ? FontWeight.w700 : FontWeight.w900,
                  fontSize: 14,
                  color: AppColors.burgundy,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              notification.message,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  height: 1.4),
            ),
            const SizedBox(height: 10),
            Text(
              _formatTime(notification.timestamp).toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5),
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
