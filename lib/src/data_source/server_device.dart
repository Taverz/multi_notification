import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_notification/src/data_source/notiofication_server_repository.dart';
import 'package:multi_notification/src/model/notification_server_entity.dart';

class ServerNotificationRegisterDevice {
  Future<void> registerDevice(
    NotificationServerRepository notificationServerRepository,
    String tokenNotification,
    bool active,
    String nameDevice,
  ) async {
    final notificationPlatform = Platform.isAndroid
        ? NotificationCurrentPlatform.android
        : Platform.isIOS
            ? NotificationCurrentPlatform.ios
            : NotificationCurrentPlatform.web;

    final deviceInfo = DeviceInfoPlugin();
    String? idDevice;
    if (Platform.isIOS) {
      final iosDeviceInfo = await deviceInfo.iosInfo;
      idDevice = iosDeviceInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      final androidDeviceInfo = await deviceInfo.androidInfo;
      idDevice = androidDeviceInfo.id;
    }
    final utcTime = DateTime.now().toUtc();
    final name = nameDevice; //'usertest';
    final model = NotificationEntity(
      registrationId: tokenNotification,
      type: notificationPlatform,
      id: UniqueKey().hashCode,
      deviceId: idDevice,
      name: name,
      dateCreated: utcTime,
      active: active,
    );

    /// From no visible logs in release version
    assert(() {
      // print(
      //   "\n\n NOTIFICATION_TEST \n DeviceID: ${idDevice} \n RegistrationID/token: ${tokenNotification.length} \n active: ${active} \n type: ${notificationPlatform.name} \n name: ${name} \n\n",
      // );
      return true;
    }());
    await notificationServerRepository.registerDevice(model);
  }
}

class ServerDisableNotification {
  Future<void> switchActiveNotification(
    NotificationServerRepository notificationServerRepository,
    String tokenNotification, {
    bool active = false,
  }) async {
    final notificationPlatform = Platform.isAndroid
        ? NotificationCurrentPlatform.android
        : Platform.isIOS
            ? NotificationCurrentPlatform.ios
            : NotificationCurrentPlatform.web;
    final model = NotificationEntity(
      registrationId: tokenNotification,
      type: notificationPlatform,
      active: active,

      deviceId: null,
      dateCreated: null,
    );

    /// From no visible logs in release version
    assert(() {
      // print(
      //   "\n\n NOTIFICATION_DISABLE_TEST \n DeviceID: ${idDevice} \n RegistrationID/token: ${tokenNotification.length} \n active: ${active} \n type: ${notificationPlatform.name} \n name: ${name} \n\n",
      // );
      return true;
    }());
    await notificationServerRepository.disableNotification(model);
  }
}
