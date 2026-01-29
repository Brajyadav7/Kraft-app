import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'shake_service.dart';

class NotificationHandler {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> showUploadNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'shake_channel_v4', // Reusing the high-importance channel
      'Upload Status',
      channelDescription: 'Shows status of video evidence upload',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true, // Prevent dismissal
      autoCancel: false,
      onlyAlertOnce: true,
      showProgress: true,
      indeterminate: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      2, // Distinct ID from Shake Notification (1)
      'Uploading Evidence...',
      'Please wait. Do not close the app.',
      details,
    );
  }

  static Future<void> cancelUploadNotification() async {
    await _notificationsPlugin.cancel(2);
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('🔴 Background Notification Tap: actionId=${notificationResponse.actionId}');
  if (notificationResponse.actionId == 'cancel_shake') {
    debugPrint('🔴 Background action: cancel_shake tapped');
    
    // Attempt to notify main isolate via port
    final SendPort? send = IsolateNameServer.lookupPortByName('shake_cancel_port');
    if (send != null) {
      debugPrint('🔴 Sending cancel signal to main isolate');
      send.send('cancel');
    } else {
      debugPrint('🔴 Main isolate port not found! Calling service directly (may fail if separate isolate)');
    }
    
    // Also try direct call (works if same isolate, harmless if not)
    ShakeDetectionService().cancelSOSFromNotification();
  }
}
