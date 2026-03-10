import 'dart:async';
import 'package:flutter/material.dart';

class SystemNotification {
  final String message;
  final DateTime timestamp;

  SystemNotification(this.message, this.timestamp);
}

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final List<SystemNotification> _notifications = [];

  List<SystemNotification> get notifications => _notifications;
  bool get hasUnread => _notifications.isNotEmpty;

  void addNotification(String message) {
    final notif = SystemNotification(message, DateTime.now());
    _notifications.insert(0, notif);
    notifyListeners();

    // Remove notification automatically after 1 minute
    Timer(const Duration(minutes: 1), () {
      if (_notifications.contains(notif)) {
        _notifications.remove(notif);
        notifyListeners();
      }
    });
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
