import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shake/shake.dart';
import 'emergency_service.dart';

class BackgroundService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'Women Safety Service', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        // auto start service
        autoStart: false,
        isForegroundMode: true,

        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'Women Safety App',
        initialNotificationContent: 'Shake detection is running in background',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: false,
        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,
        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    
    // Explicitly create detector variable
    ShakeDetector? detector;

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      // proper cleanup
      detector?.stopListening();
      service.stopSelf();
    });

    // Initialize shake detection
    try {
      detector = ShakeDetector.autoStart(
        onPhoneShake: () async {
          debugPrint("Background Shake Detected!");
          
          // Show notification that shake was detected
          // We wrap this in try-catch to avoid crashing if notification fails
          try {
            flutterLocalNotificationsPlugin.show(
              889,
              'Shake Detected',
              'Triggering SOS...',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'my_foreground',
                  'Women Safety Service',
                  icon: 'ic_bg_service_small',
                  ongoing: false,
                ),
              ),
            );
          } catch (e) {
            debugPrint("Notification error: $e");
          }
  
          // Trigger SOS
          await EmergencyService.triggerSOS((status) {
            debugPrint("Background SOS Status: $status");
          }, isBackground: true);
        },
        minimumShakeCount: 1,
        shakeSlopTimeMS: 500,
        shakeCountResetTime: 3000,
        shakeThresholdGravity: 2.7,
      );
    } catch (e) {
      debugPrint("Failed to start ShakeDetector: $e");
    }

    // Bring to foreground
    Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          // Ensure the service stays alive
          service.setForegroundNotificationInfo(
            title: "Women Safety App",
            content: "Shake detection is active",
          );
        }
      }
    });
  }
}
