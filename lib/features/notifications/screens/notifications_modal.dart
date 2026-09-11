import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/notification_provider.dart';

class NotificationsModal extends StatelessWidget {
  const NotificationsModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsModal(),
    );
  }

  String _formatTime(DateTime dt, bool isFrench) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return isFrench ? 'Il y a ${diff.inMinutes} min' : '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return isFrench ? 'Il y a ${diff.inHours} h' : '${diff.inHours}h ago';
    } else {
      return isFrench ? 'Il y a ${diff.inDays} j' : '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final lang = context.watch<LanguageProvider>();
    final notifications = notifProvider.notifications;
    final isFr = lang.isFrench;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    color: Color(0xFF2563EB),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            lang.t('notif_title'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (notifProvider.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${notifProvider.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        isFr ? 'Vos alertes et mises à jour en direct' : 'Your alerts and live updates',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                if (notifProvider.unreadCount > 0)
                  TextButton(
                    onPressed: notifProvider.markAllAsRead,
                    child: Text(
                      isFr ? 'Tout lire' : 'Read all',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // List of notifications or empty state
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 56,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            lang.t('notif_empty'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (ctx, index) {
                      final n = notifications[index];
                      Color iconColor;
                      Color iconBg;
                      IconData iconData;

                      switch (n.type) {
                        case NotificationType.booking:
                          iconColor = const Color(0xFF10B981);
                          iconBg = const Color(0xFFECFDF5);
                          iconData = Icons.check_circle_outline;
                          break;
                        case NotificationType.reminder:
                          iconColor = const Color(0xFFF59E0B);
                          iconBg = const Color(0xFFFFFBEB);
                          iconData = Icons.alarm;
                          break;
                        case NotificationType.system:
                          iconColor = const Color(0xFF2563EB);
                          iconBg = const Color(0xFFEFF6FF);
                          iconData = Icons.info_outline;
                          break;
                      }

                      return Dismissible(
                        key: Key(n.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                        ),
                        onDismissed: (_) => notifProvider.deleteNotification(n.id),
                        child: InkWell(
                          onTap: () => notifProvider.markAsRead(n.id),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: n.isRead ? Colors.white : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: n.isRead ? const Color(0xFFE2E8F0) : const Color(0xFFBFDBFE),
                                width: n.isRead ? 1 : 1.5,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: iconBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(iconData, color: iconColor, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              n.title,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                                                color: const Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            _formatTime(n.timestamp, isFr),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF94A3B8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.message,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!n.isRead) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2563EB),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (notifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: notifProvider.clearAll,
                  icon: const Icon(Icons.clear_all, size: 18, color: Color(0xFF94A3B8)),
                  label: Text(
                    lang.t('notif_clear'),
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
