// part 'notification_type_platform_enum.dart';

/// Properties:
/// * [registrationId] - service plugin token (Firebase token)
/// * [type] - android, ios, web
/// * [id] - random
/// * [name] - no required, empty
/// * [deviceId] - Unique device identifier
/// * [active] - Inactive devices will not be sent notifications
/// * [dateCreated] - utc data create token
class NotificationEntity {
  /// * [registrationId] - service plugin token (Firebase token)
  final String registrationId;

  /// * [type] - android, ios, web
  final NotificationCurrentPlatform type;

  /// * [id] - random
  final int? id;

  /// * [name] - no required, empty
  final String? name;

  /// * [deviceId] - Unique device identifier
  final String? deviceId;

  /// * [active] - Inactive devices will not be sent notifications
  final bool? active;

  /// * [dateCreated] - utc data create token
  final DateTime? dateCreated;

  NotificationEntity({
    required this.registrationId,
    required this.type,
    this.id,
    this.name,
    required this.deviceId,
    this.active,
    required this.dateCreated,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationEntity &&
        other.registrationId == registrationId &&
        other.type == type &&
        other.id == id &&
        other.name == name &&
        other.deviceId == deviceId &&
        other.active == active &&
        other.dateCreated == dateCreated;
  }

  @override
  int get hashCode {
    return registrationId.hashCode ^
        type.hashCode ^
        id.hashCode ^
        name.hashCode ^
        deviceId.hashCode ^
        active.hashCode ^
        dateCreated.hashCode;
  }
}

enum NotificationCurrentPlatform {
  ios,
  android,
  web;
}

extension NotificationCurrentPlatformExtension on NotificationCurrentPlatform {
  String get totext {
    switch (this) {
      case NotificationCurrentPlatform.ios:
        return 'ios';
      case NotificationCurrentPlatform.android:
        return 'android';
      case NotificationCurrentPlatform.web:
        return 'web';
    }
  }
}
