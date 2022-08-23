import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotification {

  late AndroidNotificationChannel channel;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void initNotifacion() async {

    channel = const AndroidNotificationChannel(
      'high_importance_channel', 
      'High Importance Notifications', 
      importance: Importance.high
    );

    flutterLocalNotificationsPlugin  = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true
    );
  }

  void onMessagingListener() {

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message){
      if( message != null ){
        print('NUEVA NOTIFICACION : $message');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) { 

      RemoteNotification? notification = message.notification;

      AndroidNotification? android = message.notification?.android;

      if( notification != null && android != null ){

        flutterLocalNotificationsPlugin.show(
          notification.hashCode, 
          notification.title, 
          notification.body, 
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id, 
              channel.name, 
              icon: 'launch_background'
            )
          )
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('NUEVA NOTIFICACION : $message');
    });

  }


  Future<String?> getNotificationToken() async {

    return await FirebaseMessaging.instance.getToken();

  }


  //  Authorization - YOUR Server key of Cloud Messaging
  Future<void> sendNotification(String to, Map<String, dynamic> data, String title, String body) async {

    Uri uri = Uri.https('fcm.googleapis.com', '/fcm/send');

    await http.post(uri, 
      headers: <String, String>{ 
        'Content-Type' : 'application/json',
        'Authorization' : 'AAAAVBR8iM4:APA91bHbCWX8WSl6lbQdV0lPD5__0OuAF3u9UH4uIiAI68qWIwfoBwEExWQP2gLXBVXimLaPibTFwXZfH-rwrVYQkqXMlvpXY2iYL89AS1ecvwg3Rys1xwZWzMg-RqdlTa8DDHaWnN4W'
      },
      body: jsonEncode( <String, dynamic>{
        'notification' : {
          'body' : body,
          'title' : title
        },
        'priority' : 'high',
        'ttl' : '4500s',
        'data': data,
        'to' : to
      })
    );
  }

  Future<void> sendNotificationMultiple(List<String> toList, Map<String, dynamic> data, String title, String body) async {

    Uri uri = Uri.https('fcm.googleapis.com', '/fcm/send');

    await http.post(uri, 
      headers: <String, String>{ 
        'Content-Type' : 'application/json',
        'Authorization' : 'AAAAVBR8iM4:APA91bHbCWX8WSl6lbQdV0lPD5__0OuAF3u9UH4uIiAI68qWIwfoBwEExWQP2gLXBVXimLaPibTFwXZfH-rwrVYQkqXMlvpXY2iYL89AS1ecvwg3Rys1xwZWzMg-RqdlTa8DDHaWnN4W'
      },
      body: jsonEncode( <String, dynamic>{
        'notification' : {
          'body' : body,
          'title' : title
        },
        'priority' : 'high',
        'ttl' : '4500s',
        'data': data,
        'registration_ids' : toList
      })
    );
  }


}

final pushNotification = PushNotification();