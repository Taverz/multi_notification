import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:multi_notification/src/data_source/data/firebase_options.dart';
import 'package:multi_notification/src/data_source/notification_service.dart';
import 'package:multi_notification/src/model/notification_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class NotificationServiceFirebaseImpl implements NotificationService {
  /// Инициализирован только FirebaseCore,
  /// поддерживате ли устройство Firebase,
  /// для этого должен быть GMS сервис
  /// (Huawei устройства не содержат GMS, у этих устройств выскакивает ошибка)
  static bool _initService = false;
  @override
  bool get availableServiceDevice => _initService;

  /// Инициализировано все что нужно при старте приложения:
  /// permission, core, token, backgroundPush
  static bool _fullInit = false;
  @override
  bool get fullInit => _fullInit;

  /// Токен для уведомлений, который отправляется на сервер
  /// для отправки уведомлений конкретному пользователю
  @pragma('vm:entry-point')
  static String? _tokenPush;
  @override
  @pragma('vm:entry-point')
  String? get tokenPush => _tokenPush;

  @override
  final StreamController<dynamic> notificationStream;
  @override
  final StreamController<dynamic> tokenStream;
  const NotificationServiceFirebaseImpl(
    this.notificationStream,
    this.tokenStream,
  );

  @override
  @pragma('vm:entry-point')
  Future<bool> mainInit() async {
    /// initCore1 / initCore2 это специально из-за FirebaseMessaging.onBackgroundMessage
    // if (!Platform.isAndroid) {
    //   await _initAppCore();
    // }

    final initBackground = await backgroundNotification();
    final initCore2 = await _initAppCore();
    final accessPermission = await _requestPermission();
    final getToken = await tokenInitNotification();

    if (
        // initCore1 &&
        initCore2 && initBackground && accessPermission && getToken) {
      _fullInit = true;
      return true;
    }
    return false;
  }

  ///////// -------------------------

  /// 1
  Future<bool> _initAppCore() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initService = true;
      return true;
    } catch (e) {
      /// Если усторйство не поддерживает Firebase, нету GMS сервисов или по какойто другой причине
      _initService = false;
      return false;
    }
  }

  /// 2
  Future<bool> _requestPermission() async {
    try {
      if (!availableServiceDevice) {
        return false;
      }
      await FirebaseMessaging.instance.requestPermission();
      final status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 3
  @override
  Future<bool> tokenInitNotification() async {
    if (!availableServiceDevice) {
      return false;
    }
    try {
      final token = await FirebaseMessaging.instance.getToken();
      _tokenPush = token;
      await _tokenHandler(_tokenPush);
      _logPush(
          '\n \n Firebase Token main:[Lenght ${token?.length ?? 0}] { $token } \n \n ');
      FirebaseMessaging.instance.onTokenRefresh.listen((tokenRef) async {
        _tokenPush = tokenRef;
        await _tokenHandler(_tokenPush);
        _logPush(
            '\n \n Firebase Token refresh:[Lenght ${tokenRef.length}] { $tokenRef } \n \n');
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 3
  /// Delete old get new
  @override
  Future<bool> tokenUpdateNotification() async {
    // if (!availableServiceDevice) {
    //   return false;
    // }
    try {
      await FirebaseMessaging.instance.deleteToken();
      //TODO: возможно второй раз не надо вызывать может
      final token = await FirebaseMessaging.instance.getToken();
      _tokenPush = token;
      await _tokenHandler(_tokenPush);
      return true;
    } catch (e) {
      try {
        await Firebase.initializeApp();
        await FirebaseMessaging.instance.deleteToken();
        //TODO: возможно второй раз не надо вызывать может
        final token = await FirebaseMessaging.instance.getToken();
        _tokenPush = token;
        await _tokenHandler(_tokenPush);
        return true;
      } catch (e) {
        return false;
      }
    }
  }

  /// 4
  @pragma('vm:entry-point')
  @override
  Future<bool> backgroundNotification() async {
    if (!availableServiceDevice) {
      return false;
    }
    try {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  ///////// -------------------------
  @override
  @pragma('vm:entry-point')
  Future<bool> foregroundNotification() async {
    if (!availableServiceDevice) {
      return false;
    }
    try {
      await _startAppGetMessage();
      FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);

      FirebaseMessaging.onMessageOpenedApp
          .listen(_firebaseMessagingForegroundHandler);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _startAppGetMessage() async {
    await FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _firebaseMessagingForegroundHandler(message);
    });
  }

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    _logPush("\n \n Firebase Bacground Push { ${message.data} } \n \n");
    final Uuid uuid = Uuid();
    String idNotification = uuid.v4();
    if (message.data.containsKey('id')) {
      idNotification = message.data['id'].toString();
    }

    final model = NotificationModel(
      id: idNotification,
      data: message.data,
      messageType: message.messageType,
      title: null,
      notificationId: message.messageId ?? "",
      body: null,
    );
    notificationStream.add(model);
  }

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingForegroundHandler(
    RemoteMessage message,
  ) async {
    _logPush("\n \n Firebase Foreground Push { ${message.data} } \n \n");
    final Uuid uuid = Uuid();
    String idNotification = uuid.v4();
    if (message.data.containsKey('id')) {
      idNotification = message.data['id'].toString();
    }

    final model = NotificationModel(
      id: idNotification,
      data: message.data,
      messageType: message.messageType,
      title: null,
      notificationId: message.messageId ?? "",
      body: null,
      foreground: true,
    );
    notificationStream.add(model);
  }

  @pragma('vm:entry-point')
  Future<void> _tokenHandler(
    String? token,
  ) async {
    _logPush("\n \n Firebase token { " + token.toString() + " } \n \n");
    tokenStream.add(token);
  }

  ///////// -------------------------
  @override
  Future<bool> disableNotification() async {
    // if (!availableServiceDevice) {
    //   return false;
    // }
    try {
      await FirebaseMessaging.instance.deleteToken();
      return true;
    } catch (e) {
      return false;
    }
  }

  void _logPush(String message) {
    // ignore: prefer_asserts_with_message
    assert(() {
      // print(message);
      return true;
    }());
  }
}
