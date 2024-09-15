import 'dart:async';
import '../model/notification_model.dart';

abstract class NotificationIntegration {
  /// Gets the push token for notifications.
  String? get tokenPush;

  /// Stream of push tokens.
  Stream<String> get tokenStream;

  /// Stream of notifications.
  Stream<NotificationModel> get notificationStream;

  /// Indicates whether notifications are active and fully initialized.
  bool get active;

  /// Initializes the main notification system, optionally using Firebase.
  Future<void> initMain({bool useFirebase = false});

  /// Activates background notifications.
  Future<bool> backgroundNotificationActivate();

  /// Initializes the Firebase token for notifications.
  Future<bool> tokenInitNotification();

  /// Updates the Firebase token for notifications.
  Future<bool> tokenUpdateNotification();

  /// Activates foreground notifications.
  Future<bool> foregroundNotificationActivate();

  /// Disables notifications for the specified device.
  Future<bool> disableNotification({required String nameDevice});

  /// Activates notifications for the specified device.
  Future<bool> activeNotification({required String nameDevice});

  /// Updates the token for notifications.
  Future<void> updateTokenNotification();

  /// Closes all streams and resources.
  void closeAll();

  /// Registers the device for notifications with the specified name.
  Future<void> registerDevice({required String nameDevice});
}
