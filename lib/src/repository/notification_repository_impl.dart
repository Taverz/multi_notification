import 'dart:async';
import 'package:multi_notification/src/data_source/notiofication_server_repository.dart';
import 'package:multi_notification/src/data_source/local_state_noticiation.dart';
import 'package:multi_notification/src/data_source/server_device.dart';
import 'package:multi_notification/src/model/notification_model.dart';
import 'package:multi_notification/src/repository/notification_repository.dart'
    as not;
import '../data_source/firebase_service_impl.dart';
import '../data_source/notification_service.dart';

class NotificationIntegrationImpl implements not.NotificationIntegration {
  NotificationIntegrationImpl(
    this.repositoryNotification,
    this.localStateNotificationRepository,
  );

  final NotificationServerRepository repositoryNotification;
  final LocalStateNotificationRepository localStateNotificationRepository;

  static String? _tokenPush;
  @override
  String? get tokenPush => _tokenPush;

  final _tokenStreamController = StreamController<String>.broadcast();
  @override
  Stream<String> get tokenStream => _tokenStreamController.stream;

  final _notificationStreamController =
      StreamController<NotificationModel>.broadcast();
  @override
  Stream<NotificationModel> get notificationStream =>
      _notificationStreamController.stream;

  static bool _active = false;
  static bool _fullInit = false;
  @override
  bool get active => _active && _fullInit;

  late NotificationService _notificationService;
  final _serverNotificationDevice = ServerNotificationRegisterDevice();
  final _serverDisableNotification = ServerDisableNotification();

  @override
  void closeAll() {
    _closeStream(_tokenStreamController);
    _closeStream(_notificationStreamController);
    _tokenPush = null;
  }

  @override
  Future<void> updateTokenNotification() async {
    try {
      await _notificationService.tokenUpdateNotification();
    } catch (e) {
      _handleError('Failed to update token notification', e);
    }
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
    } catch (e) {
      _handleError('Failed to disable notification', e);
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
    } catch (e) {
      _handleError('Failed to activate notification', e);
      return false;
    }
  }

  @override
  @pragma('vm:entry-point')
  Future<bool> foregroundNotificationActivate() async {
    try {
      await _notificationService.foregroundNotification();
      return true;
    } catch (e) {
      _handleError('Failed to activate foreground notification', e);
      return false;
    }
  }

  @override
  @pragma('vm:entry-point')
  Future<bool> backgroundNotificationActivate() async {
    try {
      await _notificationService.backgroundNotification();
      return true;
    } catch (e) {
      _handleError('Failed to activate background notification', e);
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
      await _serverNotificationDevice.registerDevice(
        repositoryNotification,
        _tokenPush!,
        true,
        nameDevice,
      );
    } catch (e) {
      _handleError('Failed to register device', e);
    }
  }

  @override
  Future<bool> tokenInitNotification() async {
    return _initializeTokenNotification();
  }

  @override
  Future<bool> tokenUpdateNotification() async {
    return _initializeTokenNotification();
  }

  @override
  @pragma('vm:entry-point')
  Future<void> initMain({bool useFirebase = true}) async {
    await localStateNotificationRepository.init();
    _getActiveNotification();
    if (active) return;

    // Clear existing streams
    _clearStreams();

    final completer = Completer<String>();
    _tokenStreamController.stream.listen((event) {
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
        _notificationStreamController,
        _tokenStreamController,
      );
      await _notificationService.mainInit();
      _tokenPush = _notificationService.tokenPush;
    } catch (e) {
      _handleError('Failed to initialize Notification Service', e);
    }
  }

  Future<void> _switchActiveNotification(bool active) async {
    _active = active;
    await localStateNotificationRepository.changeActive(active);
    await _getActiveNotification();
  }

  Future<void> _getActiveNotification() async {
    final activeStr = await localStateNotificationRepository.getStatusActive();
    _active = activeStr == 'true';
  }

  void _clearStreams() {
    _notificationStreamController
        .addStream(const Stream<NotificationModel>.empty());
    _tokenStreamController.addStream(const Stream<String>.empty());
  }

  void _closeStream(StreamController controller) {
    if (!controller.isClosed) {
      controller.close();
    }
  }

  Future<bool> _initializeTokenNotification() async {
    try {
      await _notificationService.tokenInitNotification();
      return true;
    } catch (e) {
      _handleError('Failed to initialize token notification', e);
      return false;
    }
  }

  void _handleError(String message, Object error) {
    print('$message: $error');
  }
}
