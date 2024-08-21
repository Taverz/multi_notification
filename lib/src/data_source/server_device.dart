import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';

class ServerNotificationDevice {
  Future<void> registerDevice(
    NotificationAddDeviceUseCase _notificationAddDeviceUseCase,
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
    await _notificationAddDeviceUseCase.call(model);
  }
}

class ServerDisableNotification {
  Future<void> switchActiveNotification(
      NotificationRepository repositoryNotification, String tokenNotification,
      {bool active = false}) async {
    final notificationPlatform = Platform.isAndroid
        ? NotificationCurrentPlatform.android
        : Platform.isIOS
            ? NotificationCurrentPlatform.ios
            : NotificationCurrentPlatform.web;
    final model = NotificationEntity(
      registrationId: tokenNotification,
      type: notificationPlatform,
      // id: UniqueKey().hashCode,
      // deviceId: idDevice,
      // name: name,
      // dateCreated: utcTime,
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
    await repositoryNotification.disableNotification(fcmDevice: model);
  }
}
