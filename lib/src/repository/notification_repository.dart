import 'dart:async';

import '../model/notification_model.dart';

abstract class NotificationIntegration {
  /// Токен для уведомлений, который отправляется на сервер
  /// для отправки уведомлений конкретному пользователю
  static String? _tokenPush;
  String? get tokenPush => _tokenPush;

  static final StreamController<String> _tokenStream =
      StreamController.broadcast();
  StreamController<String> get tokenStream => _tokenStream;

  static final StreamController<NotificationModel> _notificationStream =
      StreamController.broadcast();
  StreamController<NotificationModel> get notificationStream =>
      _notificationStream;

  static bool _active = true;
  static bool _fullInit = true;
  bool get active => _active && _fullInit;

  /// Запустить Firebase при старте приложения
  Future<void> initMain({bool useFirebase = false});

  /// Уведомеления ...
  Future<bool> backgroundNotificationActivate();

  ///////// -------------------------
  /// Получить токен Firebase при старте приложения
  Future<bool> tokenInitNotification();

  Future<bool> tokenUpdateNotification();

  ///////// -------------------------

  /// Уведомеления ...
  Future<bool> foregroundNotificationActivate();

  ///////// -------------------------
  /// <вместе с запросом на сервер> Отключить работу уведомлений, пермишен не будет отключен, но токен удалиться
  Future<bool> disableNotification({required String nameDevice});

  /// <вместе с запросом на сервер> Включить работу уведомлений
  Future<bool> activeNotification({required String nameDevice});

  Future<void> updateTokenNotification();

  void closeAll();

  Future<void> registerDevice({required String nameDevice});
}
