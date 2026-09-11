import 'package:flutter/material.dart';

enum NotificationType { booking, reminder, system }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final NotificationType type;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = NotificationType.system,
  });
}

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'notif_1',
      title: 'Réservation confirmée !',
      message: 'Votre demande pour "Perceuse à percussion 18V" a été validée. Le matériel est prêt au point de retrait.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      isRead: false,
      type: NotificationType.booking,
    ),
    AppNotification(
      id: 'notif_2',
      title: 'Rappel de restitution',
      message: 'Votre location pour "Appareil photo 4K Master" se termine demain à 14h00. Pensez à planifier votre retour.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
      type: NotificationType.reminder,
    ),
    AppNotification(
      id: 'notif_3',
      title: 'Bienvenue sur RentIt !',
      message: 'Votre compte est prêt. Louez les meilleurs outils et équipements professionnels au meilleur tarif.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      type: NotificationType.system,
    ),
  ];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  void addNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.system,
  }) {
    _notifications.insert(
      0,
      AppNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        message: message,
        timestamp: DateTime.now(),
        isRead: false,
        type: type,
      ),
    );
    notifyListeners();
  }
}
