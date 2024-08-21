// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class NotificationModel {
  final String id;

  /// Any additional data sent with the message.
  final Map<String, dynamic> data;

  /// The message type of the message.
  final String? messageType;

  /// The notification title.
  final String? title;

  /// The notification title.
  final String notificationId;

  /// The notification body content.
  final String? body;

  final DateTime? createAt;

  /// Readed user notification intro application
  final bool readed;

  /// Readed user notification intro application
  final bool foreground;

  NotificationModel({
    required this.id,
    required this.data,
    required this.messageType,
    required this.title,
    required this.notificationId,
    required this.body,
    this.createAt,
    this.readed = false,
    this.foreground = false,
  });

  NotificationModel copyWith({
    String? id,
    Map<String, dynamic>? data,
    String? messageType,
    String? title,
    String? notificationId,
    String? body,
    DateTime? createAt,
    bool? readed,
    bool? foreground,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      data: data ?? this.data,
      messageType: messageType ?? this.messageType,
      title: title ?? this.title,
      notificationId: notificationId ?? this.notificationId,
      body: body ?? this.body,
      createAt: createAt ?? this.createAt,
      readed: readed ?? this.readed,
      foreground: foreground ?? this.foreground,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'data': data,
      'messageType': messageType,
      'title': title,
      'notificationId': notificationId,
      'body': body,
      'createAt': createAt?.millisecondsSinceEpoch,
      'readed': readed,
      'foreground': foreground,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      data: Map<String, dynamic>.from((map['data'] as Map<String, dynamic>)),
      messageType:
          map['messageType'] != null ? map['messageType'] as String : null,
      title: map['title'] != null ? map['title'] as String : null,
      notificationId: map['notificationId'] as String,
      body: map['body'] != null ? map['body'] as String : null,
      createAt: map['createAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createAt'] as int)
          : null,
      readed: map['readed'] as bool,
      foreground: map['foreground'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NotificationModel(id: $id, data: $data, messageType: $messageType, title: $title, notificationId: $notificationId, body: $body, createAt: $createAt, readed: $readed, foreground: $foreground)';
  }

  @override
  bool operator ==(covariant NotificationModel other) {
    // if (identical(this, other)) return true;

    return other.id == id &&
        // mapEquals(other.data, data) &&
        // other.messageType == messageType &&
        other.title == title &&
        // other.notificationId == notificationId &&
        other.body == body &&
        other.foreground == foreground;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        // data.hashCode ^
        // messageType.hashCode ^
        title.hashCode ^
        // notificationId.hashCode ^
        body.hashCode ^
        foreground.hashCode;
  }
}
