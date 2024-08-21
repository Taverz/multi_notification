import 'dart:async';
import 'package:domain/domain.dart';
import 'package:multi_notification/src/data_source/server_device.dart';
import 'package:multi_notification/src/model/notification_model.dart';
import 'package:multi_notification/src/repository/notification_repository.dart'
    as not;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data_source/firebase_service_impl.dart';
import '../data_source/notification_service.dart';

class NotificationIntegrationImpl implements not.NotificationIntegration {
  NotificationIntegrationImpl(
    this._notificationAddDeviceUseCase,
    this.repositoryNotification,
    this.secureStorage,
  );

  final NotificationAddDeviceUseCase _notificationAddDeviceUseCase;
  final NotificationRepository repositoryNotification;
  final FlutterSecureStorage secureStorage;
  final String _keyStorageActiveNotification = 'active_notification';

  static String? _tokenPush;
  @override
  String? get tokenPush => _tokenPush;

  static final StreamController<String> _tokenStream =
      StreamController.broadcast();
  @override
  StreamController<String> get tokenStream => _tokenStream;

  static final StreamController<NotificationModel> _notificationStream =
      StreamController.broadcast();
  @override
  StreamController<NotificationModel> get notificationStream =>
      _notificationStream;

  static bool _active = false;
  static bool _fullInit = false;
  @override
  bool get active => _active && _fullInit;

  late NotificationService _notificationService;
  final ServerNotificationDevice _serverNotificationDevice =
      ServerNotificationDevice();
  final ServerDisableNotification _serverDisableNotification =
      ServerDisableNotification();

  @override
  void closeAll() {
    _notificationStream.close();
    _tokenStream.close();
    _tokenPush = null;
  }

  Future<void> updateTokenNotification() async {
    try {
      await _notificationService.tokenUpdateNotification();
    } catch (_) {}
  }

  @override
  Future<bool> disableNotification({required String nameDevice}) async {
    if (tokenPush == null) return false;
    try {
      await _switchActiveNotification(false);
      await _serverDisableNotification.switchActiveNotification(
        repositoryNotification,
        tokenPush!,
        active: false,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> activeNotification({required String nameDevice}) async {
    try {
      await _switchActiveNotification(true);
      await initMain();
      await registerDevice(nameDevice: nameDevice);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  @pragma('vm:entry-point')
  Future<bool> foregroundNotificationActivate() async {
    try {
      await _notificationService.foregroundNotification();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  @pragma('vm:entry-point')
  Future<bool> backgroundNotificationActivate() async {
    try {
      await _notificationService.backgroundNotification();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> registerDevice({required String nameDevice}) async {
    if (_tokenPush == null) {
      throw Exception('Error register device, token is null');
    }
    try {
      await _getActiveNotification();
    } catch (_) {}
    await _serverNotificationDevice.registerDevice(
      _notificationAddDeviceUseCase,
      _tokenPush!,
      true,
      nameDevice,
    );
  }

  @override
  Future<bool> tokenInitNotification() async {
    try {
      await _notificationService.tokenInitNotification();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> tokenUpdateNotification() async {
    try {
      await _notificationService.tokenUpdateNotification();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  @pragma('vm:entry-point')
  Future<void> initMain({bool useFirebase = true}) async {
    _getActiveNotification();
    if (active) return;

    // Clear existing streams instead of reassigning
    _clearStreams();

    final completer = Completer<String>();
    _tokenStream.stream.listen((event) {
      _tokenPush = event;
      if (!completer.isCompleted) {
        completer.complete(event);
      }
    });

    await _initializeService(useFirebase);
    _tokenPush = await completer.future.timeout(const Duration(seconds: 10));

    _fullInit = true;
  }

  @pragma('vm:entry-point')
  Future<void> _initializeService(bool useFirebase) async {
    try {
      _notificationService = NotificationServiceFirebaseImpl(
        _notificationStream,
        _tokenStream,
      );
      await _notificationService.mainInit();
      _tokenPush = _notificationService.tokenPush;
    } catch (e) {
      print('Failed to initialize Firebase Notification Service: $e');
    }
  }

  Future<void> _switchActiveNotification(bool active) async {
    _active = active;
    await secureStorage.write(
      key: _keyStorageActiveNotification,
      value: active.toString(),
    );
    await _getActiveNotification();
  }

  Future<void> _getActiveNotification() async {
    final activeStr =
        await secureStorage.read(key: _keyStorageActiveNotification);
    _active = activeStr == 'true';
  }

  void _clearStreams() {
    // Clear existing streams
    _notificationStream.addStream(Stream<NotificationModel>.empty());
    _tokenStream.addStream(Stream<String>.empty());
  }
}
