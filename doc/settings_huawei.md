
### Шаг 1: Подготовка проекта в Huawei Developer Console

1. **Создание проекта в Huawei Developer Console:**
   - Перейдите на [Huawei Developer Console](https://developer.huawei.com/consumer/en/).
   - Зарегистрируйтесь или войдите в свою учетную запись.
   - Создайте новый проект.

2. **Добавление приложения в Huawei Developer Console:**
   - Добавьте ваше Android-приложение в созданный проект.
   - Укажите имя пакета приложения (то же самое, что и в Android).
   - Скачайте файл конфигурации `agconnect-services.json`.

3. **Настройка Push Kit в Huawei Developer Console:**
   - Перейдите в раздел **Push Kit** и включите его для вашего приложения.

### Шаг 2: Настройка проекта Android для Huawei Push Kit

1. **Добавление файла конфигурации:**
   - Добавьте скачанный файл `agconnect-services.json` в папку `android/app`.

2. **Настройка `build.gradle`:**
   - Откройте файл `android/build.gradle` и добавьте репозиторий Huawei Maven в раздел `buildscript`:
     ```gradle
     buildscript {
         repositories {
             google()
             mavenCentral()
             maven { url 'https://developer.huawei.com/repo/' }
         }
         dependencies {
             classpath 'com.android.tools.build:gradle:7.0.2'
             classpath 'com.huawei.agconnect:agcp:1.6.5.300'
         }
     }
     ```
   - В файле `android/app/build.gradle` добавьте плагин AGConnect:
     ```gradle
     apply plugin: 'com.huawei.agconnect'
     ```

3. **Добавление зависимостей Huawei Push Kit:**
   - Откройте `android/app/build.gradle` и добавьте зависимость от Push Kit:
     ```gradle
     dependencies {
         implementation 'com.huawei.hms:push:6.4.0.300'
     }
     ```

4. **Обновление манифеста Android:**
   - Откройте файл `android/app/src/main/AndroidManifest.xml` и добавьте разрешения и сервисы Huawei Push Kit:
     ```xml
     <uses-permission android:name="android.permission.INTERNET"/>
     <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
     <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

     <application>
         <meta-data
             android:name="com.huawei.hms.client.appid"
             android:value="@string/app_id"/>
         <service
             android:name="com.huawei.hms.push.HmsMessageService"
             android:enabled="true"
             android:exported="true">
             <intent-filter>
                 <action android:name="com.huawei.push.action.MESSAGING_EVENT"/>
             </intent-filter>
         </service>
     </application>
     ```

### Шаг 3: Добавление зависимостей HMS в проект Flutter

1. **Установка плагина HMS Push Kit:**
   Добавьте следующую зависимость в файл `pubspec.yaml`:
   ```yaml
   dependencies:
     huawei_push: latest_version
   ```

   Замените `latest_version` на последнюю версию пакета, доступную на [pub.dev](https://pub.dev/packages/huawei_push).

2. **Инициализация Push Kit в Flutter:**
   В файле `lib/main.dart` инициализируйте Push Kit:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:huawei_push/push.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();

     // Инициализация Huawei Push Kit
     await Push.getTokenStream.listen((token) {
       print("Huawei Push Token: $token");
     });

     runApp(MyApp());
   }
   ```

### Шаг 4: Получение токена и обработка уведомлений

1. **Запрос токена Push Kit:**
   Чтобы получить токен для устройства, используйте следующий код:
   ```dart
   void getToken() async {
     String? token = await Push.getToken();
     print("Huawei Push Token: $token");
   }
   ```

2. **Обработка входящих сообщений:**
   Настройте обработку входящих уведомлений:
   ```dart
   Push.onMessageReceived.listen((RemoteMessage remoteMessage) {
     print('Received push message: ${remoteMessage.data}');
   });
   ```

### Шаг 5: Развертывание и тестирование приложения

1. **Сборка и запуск приложения:**
   Убедитесь, что ваш проект настроен на сборку и выполните команду для запуска:
   ```bash
   flutter run
   ```

2. **Отправка тестового уведомления:**
   Отправьте тестовое уведомление через Huawei Developer Console:
   - Перейдите в раздел Push Kit вашего проекта и выберите **Send Notification**.
   - Укажите таргетинг по токену устройства и отправьте уведомление.

### Шаг 6: Обработка специальных ситуаций

1. **Отправка уведомлений через сервер:**
   Чтобы отправить уведомления через сервер, используйте API Huawei Push Kit или интегрируйте с Firebase Functions для мультиплатформенных уведомлений.

2. **Отладка:**
   Если возникнут ошибки, проверьте настройки приложения в Huawei Developer Console и убедитесь, что все необходимые разрешения и зависимости добавлены в проект.

### Шаг 7: Проверка и публикация

1. **Тестирование на устройстве Huawei:**
   Проверьте работу уведомлений на устройстве Huawei с HMS.
   
2. **Публикация приложения:**
   Когда вы уверены, что все работает корректно, подготовьте приложение для публикации в AppGallery и Google Play.

