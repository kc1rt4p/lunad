import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lunad/data/models/consumer_request.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> showRequestsUpdateNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'consumer request',
      'request updated',
      'notifications for rider assigned request',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        'Request Updated',
        'One of your requests\' status has been updated',
        platformChannelSpecifics,
        payload: null);
  }

  Future<void> showRequestUpdateNotification(ConsumerRequest request) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'consumer-request',
      'requests updated',
      'notifications for rider assigned request',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        'Request Updated',
        'Your ${request.type} request is now ${request.status}',
        platformChannelSpecifics,
        payload: request.toString());
  }

  Future<void> showAssignedNotification(ConsumerRequest request) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'rider-assignment',
      'rider requests',
      'notifications for rider assigned request',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        'Job Assignment',
        'You have been assigned for a ${request.type} job',
        platformChannelSpecifics,
        payload: request.toString());
  }
}
