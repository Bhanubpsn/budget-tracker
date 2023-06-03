import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService{

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initializeNotification() async{
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('logo');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  //****************************************************This is for Budget overflow****************************************************

  void showNotificationWater(int id,String title,String body) async{
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      // RepeatInterval.everyMinute,
      NotificationDetails(
        android: AndroidNotificationDetails(
          id.toString(),
          'Out of BUDGET!',
          importance: Importance.max,
          priority: Priority.max,
          icon: 'logo',
        ),
      ),
    );
  }
}