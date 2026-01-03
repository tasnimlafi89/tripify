import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/features/home/presentation/pages/notifications_page.dart';

class NotificationNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationNotifier() : super([
    NotificationItem(
      icon: Icons.waving_hand_rounded,
      type: NotificationType.primary,
      title: 'Welcome to TravelAI!',
      description: 'We are excited to have you on board. Start planning your next adventure today!',
      time: 'Just now',
      isUnread: true,
    ),
  ]);

  void markAsRead(NotificationItem notification) {
    state = [
      for (final item in state)
        if (item == notification)
          NotificationItem(
            icon: item.icon,
            type: item.type,
            title: item.title,
            description: item.description,
            time: item.time,
            isUnread: false,
          )
        else
          item
    ];
  }

  void markAllAsRead() {
    state = [
      for (final item in state)
        NotificationItem(
          icon: item.icon,
          type: item.type,
          title: item.title,
          description: item.description,
          time: item.time,
          isUnread: false,
        )
    ];
  }
  
  void addNotification(NotificationItem notification) {
    state = [notification, ...state];
  }
  
  int get unreadCount => state.where((n) => n.isUnread).length;
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<NotificationItem>>((ref) {
  return NotificationNotifier();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider);
  return notifications.where((n) => n.isUnread).length;
});
