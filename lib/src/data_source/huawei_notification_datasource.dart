// import 'dart:async';

// import 'package:multi_notification/src/data_source/notification_service.dart';
// import 'package:permission_handler/permission_handler.dart';

// import 'package:flutter/foundation.dart';
// import 'package:huawei_push/huawei_push.dart';

// class HuaweiNotificationService implements NotificationService {
//   /// Инициализирован только huaweiCore,
//   /// поддерживате ли устройство huawei,
//   /// для этого должен быть GMS сервис
//   /// (Huawei устройства не содержат GMS, у этих устройств выскакивает ошибка)
//   static bool _initService = false;
//   bool get availableServiceDevice => _initService;

//   /// Инициализировано все что нужно при старте приложения:
//   /// permission, core, token, backgroundPush
//   static bool _fullInit = false;
//   bool get fullInit => _fullInit;

//   /// Токен для уведомлений, который отправляется на сервер
//   /// для отправки уведомлений конкретному пользователю
//   @pragma('vm:entry-point')
//   static String? _tokenPush;
//   @pragma('vm:entry-point')
//   String? get tokenPush => _tokenPush;

//   final StreamController<dynamic> notificationStream;
//   final StreamController<dynamic> tokenStream;
//   const HuaweiNotificationService(
//     this.notificationStream,
//     this.tokenStream,
//   );

//   @pragma('vm:entry-point')
//   Future<bool> mainInit() async {
//     if (kDebugMode) {
//       await Push.enableLogger();
//     }else{
//       await Push.disableLogger();
//     }
//     final accessPermission = await _requestPermission();

//     /// initCore1 / initCore2 это специально из-за FirebaseMessaging.onBackgroundMessage
//     final initCore1 = await _initAppCore();
//     final initBackground = await backgroundNotification();

//     final getToken = await tokenInitNotification();

//     if (initCore1 && initBackground && accessPermission && getToken) {
//       _fullInit = true;
//       return true;
//     }
//     return false;
//   }

//   // @override
//   // @pragma('vm:entry-point')
//   // Future<bool> mainInit() async {
//   //   if (kDebugMode) {
//   //     await Push.enableLogger();
//   //   }

//   //   // Push.getIntentStream.listen((String intent) {
//   //   //   print("Intent: $intent");
//   //   // });
//   //   // await Push.registerBackgroundMessageHandler(_backgroundMessageHandler);
//   // }

//   /// 2
//   Future<bool> _requestPermission() async {
//     try {
//       if (!availableServiceDevice) {
//         return false;
//       }
//       final status = await Permission.notification.status;
//       if (status.isDenied) {
//         await Permission.notification.request();
//       }
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   /// 1
//   Future<bool> _initAppCore() async {
//     try {
//       await Push.turnOnPush();
//       _initService = true;
//       return true;
//     } catch (e) {
//       /// Если усторйство не поддерживает Firebase, нету GMS сервисов или по какойто другой причине
//       _initService = false;
//       return false;
//     }
//   }

//   @override
//   @pragma('vm:entry-point')
//   Future<bool> foregroundNotification() async {
//     // Push.onMessageReceivedStream.listen((RemoteMessage message) {
//     //   final remoteMessage = message.toRemoteMessage();
//     //   onMessage(remoteMessage);
//     //   saveNotification(remoteMessage);
//     // });
//     if (!availableServiceDevice) {
//       return false;
//     }
//     try {
//       Push.onMessageReceivedStream.listen(_huaweiMessagingForegroundHandler);
//       Push.onNotificationOpenedApp.listen(_huaweiMessagingForegroundHandler);
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   @override
//   @pragma('vm:entry-point')
//   Future<bool> backgroundNotification() async {
//     if (!availableServiceDevice) {
//       return false;
//     }
//     try {
//       await Push.registerBackgroundMessageHandler(
//           _huaweiMessagingBackgroundHandler);
//       // Push.getIntentStream.listen((String intent) {
//       //   print("Intent: $intent");
//       // });

//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   /// 3
//   @override
//   Future<bool> tokenInitNotification() async {
//     if (!availableServiceDevice) {
//       return false;
//     }
//     try {
//       Push.getTokenStream.listen((String token) {
//         _tokenHandler(token);
//       });
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   @pragma('vm:entry-point')
//   Future<void> _huaweiMessagingBackgroundHandler(
//     dynamic message,
//   ) async {
//     if (message is RemoteMessage) {
//       _logPush("\n \n Huawei Bacground Push { " +
//           message.data.toString() +
//           " } \n \n");
//     } else {
//       _logPush(
//           "\n \n Huawei Bacground Push { " + message.toString() + " } \n \n");
//     }
//     notificationStream.add(message);
//   }

//   @pragma('vm:entry-point')
//   Future<void> _huaweiMessagingForegroundHandler(
//     dynamic message,
//   ) async {
//     if (message is RemoteMessage) {
//       _logPush("\n \n Huawei Foreground Push { " +
//           message.data.toString() +
//           " } \n \n");
//     } else {
//       _logPush(
//           "\n \n Huawei Foreground Push { " + message.toString() + " } \n \n");
//     }
//     notificationStream.add(message);
//   }

//   @pragma('vm:entry-point')
//   Future<void> _tokenHandler(
//     String? token,
//   ) async {
//     _logPush("\n \n Huawei token { " + token.toString() + " } \n \n");
//     tokenStream.add(token);
//   }

//   void _logPush(String message) {
//     // ignore: prefer_asserts_with_message
//     assert(() {
//       print(message);
//       return true;
//     }());
//   }

//   @override
//   Future<bool> disableNotification() async {
//     try {
//       await Push.turnOffPush();
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   @override
//   Future<bool> tokenUpdateNotification() async {
//     try {
//       // await Push.getToken();
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
// }
