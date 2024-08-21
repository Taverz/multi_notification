import 'dart:async';

abstract class NotificationService {
  /// Инициализирован только FirebaseCore,
  /// поддерживате ли устройство Firebase,
  /// для этого должен быть GMS сервис
  /// (Huawei устройства не содержат GMS, у этих устройств выскакивает ошибка)
  static bool _initService = false;
  bool get availableServiceDevice => _initService;

  /// Инициализировано все что нужно при старте приложения:
  /// permission, core, token, backgroundPush
  static bool _fullInit = false;
  bool get fullInit => _fullInit;

  /// Токен для уведомлений, который отправляется на сервер
  /// для отправки уведомлений конкретному пользователю
  static String? _tokenPush;
  String? get tokenPush => _tokenPush;

  final StreamController<dynamic> notificationStream;
  final StreamController<dynamic> tokenStream;
  const NotificationService(
    this.notificationStream,
    this.tokenStream,
  );

  /// Запустить Firebase при старте приложения
  @pragma('vm:entry-point')
  Future<bool> mainInit();

  /// Уведомеления ...
  Future<bool> backgroundNotification();

  ///////// -------------------------
  /// Получить токен Firebase при старте приложения
  Future<bool> tokenInitNotification();

  Future<bool> tokenUpdateNotification();

  ///////// -------------------------

  /// Уведомеления ...
  Future<bool> foregroundNotification();

  ///////// -------------------------
  /// Отключить работу уведомлений, первишен не будет отключен, но токен удалиться
  Future<bool> disableNotification();
}
