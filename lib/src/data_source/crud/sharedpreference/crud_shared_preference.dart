import 'dart:convert';
import 'package:multi_notification/src/data_source/crud/crud.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FlutterSecureStorageCRUD implements CRUDInterface {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String? _key;

  @override
  Future<void> init(String key) async {
    _key = key;
  }

  @override
  Future<void> putMap(Map<String, dynamic> value) async {
    _ensureKeyIsSet();
    final jsonString = json.encode(value);
    await _secureStorage.write(key: _key!, value: jsonString);
  }

  @override
  Future<void> putList(List<dynamic> value) async {
    _ensureKeyIsSet();
    final stringList = value.map((e) => json.encode(e)).toList();
    final jsonString = json.encode(stringList);
    await _secureStorage.write(key: _key!, value: jsonString);
  }

  @override
  Future<void> updateMap(Map<String, dynamic> value) async {
    _ensureKeyIsSet();
    final currentMap = await getAllMap();
    currentMap.addAll(value);
    await putMap(currentMap);
  }

  @override
  Future<void> updateList(List<dynamic> value) async {
    _ensureKeyIsSet();
    final currentList = await getAllList();
    currentList.addAll(value);
    await putList(currentList);
  }

  @override
  Future<void> deleteElementFromList(dynamic element) async {
    _ensureKeyIsSet();
    final currentList = await getAllList();
    currentList.remove(element);
    await putList(currentList);
  }

  @override
  Future<void> deleteMap() async {
    _ensureKeyIsSet();
    await _secureStorage.delete(key: _key!);
  }

  @override
  Future<dynamic> getElementFromMap() async {
    _ensureKeyIsSet();
    final currentMap = await getAllMap();
    return currentMap[_key];
  }

  @override
  Future<dynamic> getElementFromList(int index) async {
    _ensureKeyIsSet();
    final currentList = await getAllList();
    if (index < currentList.length) {
      return currentList[index];
    }
    return null;
  }

  @override
  Future<List<dynamic>> getAllList() async {
    _ensureKeyIsSet();
    final jsonString = await _secureStorage.read(key: _key!);
    if (jsonString != null) {
      final List<dynamic> decodedList = json.decode(jsonString);
      return decodedList.map((e) => json.decode(e)).toList();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getAllMap() async {
    _ensureKeyIsSet();
    final jsonString = await _secureStorage.read(key: _key!);
    if (jsonString != null) {
      return json.decode(jsonString);
    }
    return {};
  }

  @override
  Future<void> setParameter(dynamic value) async {
    final key = _key!;
    if (value is int || value is double || value is bool || value is String) {
      await _secureStorage.write(key: key, value: value.toString());
    } else if (value is List<String>) {
      final jsonString = json.encode(value);
      await _secureStorage.write(key: key, value: jsonString);
    }
  }

  @override
  Future<dynamic> getParameter() async {
    final value = await _secureStorage.read(key: _key!);
    return value;
  }

  void _ensureKeyIsSet() {
    if (_key == null) {
      throw Exception(
        "FlutterSecureStorageCRUD key is not initialized. Call init(key) first.",
      );
    }
  }
}
