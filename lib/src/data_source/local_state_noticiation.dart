// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:multi_notification/src/data_source/crud/crud.dart';

class LocalStateNotificationRepository {
  final CRUDInterface crudOperation;
  final String _keyStorageActiveNotification = 'active_notification';
  const LocalStateNotificationRepository({
    required this.crudOperation,
  });

  Future<void> init() async {
    await crudOperation.init(_keyStorageActiveNotification);
  }

  Future<void> changeActive(bool active) async {
    await crudOperation.setParameter(active);
  }

  Future<bool> getStatusActive() async {
    return await crudOperation.getParameter();
  }
}
