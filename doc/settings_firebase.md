# Настройка и тестирование Firebase  

[Link Message official docs](https://firebase.google.com/docs/cloud-messaging/flutter/client)  
[Link CLI official docs](https://firebase.google.com/docs/cli)  

### Шаг 1: Установка Firebase CLI на macOS

1. **Установка Homebrew (если еще не установлен):**
   - Откройте терминал и установите Homebrew:
     ```bash
     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
     ```

2. **Установка Firebase CLI:**
   - Установите Firebase CLI с помощью npm:
     ```bash
     npm install -g firebase-tools
     ```

3. **Вход в Firebase через CLI:**
   - Выполните команду для авторизации в Firebase:
     ```bash
     firebase login
     ```

### Шаг 2: Инициализация Firebase в проекте Flutter через CLI

1. **Инициализация Firebase проекта:**
   - Перейдите в корневую директорию вашего Flutter-проекта в терминале и выполните команду:
     ```bash
     flutterfire configure
     ```
   - Эта команда запустит интерфейс CLI, который позволит вам выбрать Firebase проект, добавить Android и iOS приложения, а также автоматически сгенерирует файл `firebase_options.dart`.

2. **Выбор функций Firebase:**
   - CLI предложит выбрать нужные Firebase сервисы. Выберите **Cloud Messaging**, если хотите использовать уведомления.

3. **Генерация `firebase_options.dart`:**
   - После завершения настройки, Firebase CLI автоматически создаст файл `firebase_options.dart` в папке `lib`. Этот файл содержит все параметры инициализации для Android и iOS.

### Шаг 3: Настройка проекта Android и iOS

1. **Настройка Firebase для Android:**
   - CLI также скачает файл `google-services.json`. Переместите его в папку `android/app`.
   - Откройте файл `android/build.gradle` и добавьте следующие строки в секцию `buildscript`:
     ```gradle
     buildscript {
         dependencies {
             classpath 'com.google.gms:google-services:4.3.15'
         }
     }
     ```
   - В конце файла `android/app/build.gradle` добавьте:
     ```gradle
     apply plugin: 'com.google.gms.google-services'
     ```

2. **Настройка Firebase для iOS:**
   - Переместите файл `GoogleService-Info.plist`, сгенерированный CLI, в папку `ios/Runner`.
   - Убедитесь, что минимальная версия iOS указана как `12.0` или выше в `ios/Podfile`:
     ```ruby
     platform :ios, '12.0'
     ```
   - Выполните команду `pod install` в папке `ios`:
     ```bash
     cd ios
     pod install
     cd ..
     ```

### Шаг 4: Инициализация Firebase и FCM в коде Flutter

1. **Подключение `firebase_options.dart`:**
   В файле `lib/main.dart` подключите сгенерированный файл `firebase_options.dart` и инициализируйте Firebase с его помощью:
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   import '../docs/firebase_options.dart';
   import 'package:flutter/material.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     runApp(MyApp());
   }
   ```

2. **Настройка Firebase Messaging:**
   Добавьте код для получения и обработки уведомлений:
   ```dart
   import 'package:firebase_messaging/firebase_messaging.dart';

   Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
     await Firebase.initializeApp();
     print("Handling a background message: ${message.messageId}");
   }

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );

     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

     runApp(MyApp());
   }
   ```

3. **Запрос разрешений для уведомлений (iOS):**
   Если ваше приложение поддерживает iOS, запросите разрешение на отправку уведомлений:
   ```dart
   FirebaseMessaging messaging = FirebaseMessaging.instance;
   NotificationSettings settings = await messaging.requestPermission(
     alert: true,
     badge: true,
     sound: true,
   );
   ```

### Шаг 5: Отправка тестового уведомления через Firebase CLI

1. **Отправка тестового уведомления:**
   Используйте Firebase CLI для отправки тестового уведомления или отправьте сообщение через Firebase Console. Если хотите отправить уведомление с помощью командной строки, используйте команду `curl`:
   ```bash
   curl -X POST -H "Authorization: key=YOUR_SERVER_KEY" -H "Content-Type: application/json" \
   -d '{
     "to": "YOUR_FCM_TOKEN",
     "notification": {
       "title": "Test Notification",
       "body": "This is a test message"
     }
   }' https://fcm.googleapis.com/fcm/send
   ```

   Замените `YOUR_SERVER_KEY` на ваш серверный ключ, который можно найти в Firebase Console, и `YOUR_FCM_TOKEN` на токен устройства.

### Шаг 6: Сборка и запуск приложения на macOS

1. **Запуск приложения:**
   Запустите проект на Android или iOS через терминал:
   ```bash
   flutter run
   ```

2. **Проверка уведомлений:**
   Убедитесь, что уведомления приходят на ваше устройство.

