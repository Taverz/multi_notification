import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../model/notification_model.dart';

abstract class NotificationSaveLocalDataSource {
  Future<void> saveNotification(NotificationModel message);
  Future<void> saveAllNotification(Set<NotificationModel> message);
  Future<void> deleteNotification(NotificationModel message);
  Future<void> updateNotificationStatus(NotificationModel message, bool status);
  Future<List<NotificationModel>> getAllNotifications();
  Future<void> clearAllNotifications();
}

class SecureStorageNotificationDataSource
    implements NotificationSaveLocalDataSource {
  static const String _notificationsKey = 'notifications_secure';
  final FlutterSecureStorage secureStorage;

  SecureStorageNotificationDataSource({required this.secureStorage});

  @override
  Future<void> saveNotification(NotificationModel message) async {
    final notifications = (await getAllNotifications()).toSet();
    notifications.add(message);

    final encodedNotifications = notifications
        .map((notification) => jsonEncode(notification.toMap()))
        .toList();

    await secureStorage.write(
      key: _notificationsKey,
      value: jsonEncode(encodedNotifications),
    );
    _log('Notification saved: ${message.title}');
  }

  @override
  Future<void> saveAllNotification(Set<NotificationModel> message) async {
    final notifications = (await getAllNotifications()).toSet();
    notifications.addAll(message);

    final encodedNotifications = notifications
        .map((notification) => jsonEncode(notification.toMap()))
        .toList();

    await secureStorage.write(
      key: _notificationsKey,
      value: jsonEncode(encodedNotifications),
    );
    _log('Notification saved: ${message.toString()}');
  }

  @override
  Future<void> deleteNotification(NotificationModel message) async {
    final notifications = await getAllNotifications();
    notifications.removeWhere(
      (notification) => notification.notificationId == message.notificationId,
    );

    final encodedNotifications = notifications
        .map((notification) => jsonEncode(notification.toMap()))
        .toList();

    await secureStorage.write(
      key: _notificationsKey,
      value: jsonEncode(encodedNotifications),
    );
    _log('Notification deleted: ${message.data}');
  }

  @override
  Future<void> updateNotificationStatus(
    NotificationModel message,
    bool status,
  ) async {
    final notifications = (await getAllNotifications());
    final index = notifications.indexWhere(
      (notification) =>
          // notification.notificationId == message.notificationId ||
          notification.id == message.id,
    );

    if (index != -1) {
      notifications[index] = message.copyWith(readed: status);
      final encodedNotifications = notifications
          .map((notification) => jsonEncode(notification.toMap()))
          .toList();

      await secureStorage.write(
        key: _notificationsKey,
        value: jsonEncode(encodedNotifications),
      );
      _log('Notification status updated: ${message.title}');
    }
  }

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    final encodedNotifications =
        await secureStorage.read(key: _notificationsKey);
    if (encodedNotifications == null) return [];

    final decodedList = jsonDecode(encodedNotifications) as List<dynamic>;
    return decodedList
        .map(
          (encoded) => NotificationModel.fromMap(
            jsonDecode(encoded) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<void> clearAllNotifications() async {
    await secureStorage.delete(key: _notificationsKey);
    _log('All notifications cleared');
  }

  void _log(String message) {
    // ignore: prefer_asserts_with_message
    assert(() {
      print(message);
      return true;
    }());
  }
}
