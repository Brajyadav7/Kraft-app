import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'dart:typed_data';
import 'notification_handler.dart';
import 'package:vibration/vibration.dart';

typedef ShakeCallback = void Function();

class ShakeDetectionService {
  static final ShakeDetectionService _instance =
      ShakeDetectionService._internal();

  factory ShakeDetectionService() {
    return _instance;
  }

  ShakeDetectionService._internal();

  ShakeDetector? _detector;
  ShakeCallback? _onShakeCallback;
  bool _isListening = false;
  Timer? _shakeCooldown;
  Timer? _notificationCancelTimer;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _notificationInitialized = false;
  static const String _isolateName = 'shake_cancel_port';
  final ReceivePort _port = ReceivePort();

  /// Initialize notification plugin
  Future<void> initializeNotifications() async {
    if (_notificationInitialized) return;

    // Register port for background communication
    IsolateNameServer.removePortNameMapping(_isolateName);
    IsolateNameServer.registerPortWithName(_port.sendPort, _isolateName);
    _port.listen((message) {
      if (message == 'cancel') {
        debugPrint('🔴 Received cancel signal from background isolate');
        cancelSOSFromNotification();
      }
    });

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔴 Foreground Notification Response: actionId=${response.actionId}');
        if (response.actionId == 'cancel_shake') {
          cancelSOSFromNotification();
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Create the channel explicitly
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'shake_channel_v4', // id - CHANGED to force update settings
      'Shake Detection', // title
      description: 'Notifications for shake detection events',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _notificationInitialized = true;
  }

  /// Show shake detection notification in notification bar
  Future<void> _showShakeNotification() async {
    try {
      await initializeNotifications();

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'shake_channel_v4',
            'Shake Detection',
            channelDescription: 'Notifications for shake detection events',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
            playSound: true,
            actions: <AndroidNotificationAction>[
              AndroidNotificationAction(
                'cancel_shake',
                'CANCEL SOS',
                titleColor: Colors.red,
                showsUserInterface: false,
                cancelNotification: true,
              ),
            ],
          );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notificationsPlugin.show(
        1,
        '🚨 SOS Initiated!',
        'Shake detected! Sending alerts in 8s...',
        notificationDetails,
        payload: 'shake_alert',
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Cancel the pending shake notification
  Future<void> _cancelShakeNotification() async {
    await _notificationsPlugin.cancel(1);
  }

  /// Start listening to shake events
  void startListening(ShakeCallback onShake) {
    _onShakeCallback = onShake;
    _isListening = true;

    debugPrint('🔴 Shake detection started (Background mode)');

    _detector = ShakeDetector.autoStart(
      onPhoneShake: _handleShake,
      minimumShakeCount: 1,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 4.5,
    );
  }



  /// Stop listening to shake events
  void stopListening() {
    _isListening = false;
    _onShakeCallback = null;
    debugPrint('🔴 Shake detection stopped');
    _detector?.stopListening();
    _detector = null;
    _shakeCooldown?.cancel();
    _notificationCancelTimer?.cancel();
    _cancelShakeNotification();
    Vibration.cancel(); // Stop vibration
    IsolateNameServer.removePortNameMapping(_isolateName);
  }

  /// Handle shake event
  void _handleShake() async {
    if (!_isListening || _onShakeCallback == null) return;

    // Prevent multiple rapid shake detections
    if (_shakeCooldown != null && _shakeCooldown!.isActive) {
      return;
    }

    debugPrint('🔴 SHAKE DETECTED! Showing notification...');
    
    // Explicit long vibration: Vibrate 1s, Wait 0.5s, Vibrate 1s (Repeats)
    if (await Vibration.hasVibrator() == true) {
      // pattern: [initialDelay, vibrate, pause, vibrate]
      // repeat: index into pattern to start repeating from.
      // We want to repeat from index 1 (vibrate 1000) or index 0 (delay 0)?
      // Let's use [500, 1000] (wait 0.5s, vibrate 1s) and repeat 0.
      Vibration.vibrate(pattern: [500, 1000], repeat: 0); 
    }

    // Show shake notification in notification bar
    _showShakeNotification();

    // Auto-trigger SOS after 8 seconds if not cancelled
    _notificationCancelTimer = Timer(const Duration(seconds: 8), () {
      if (_isListening && _onShakeCallback != null) {
        debugPrint('🔴 Auto-confirming SOS after 8 second countdown...');
        _cancelShakeNotification(); // Cancels notification
        Vibration.cancel(); // Stop vibration when SOS is sent
        _onShakeCallback?.call();
      }
    });

    // Add cooldown to prevent rapid repeated triggers
    _shakeCooldown = Timer(const Duration(seconds: 3), () {});
  }

  /// User confirmed SOS from notification
  Future<void> confirmSOSFromNotification() async {
    _notificationCancelTimer?.cancel();
    Vibration.cancel(); // Stop vibration
    await _cancelShakeNotification();
    if (_isListening && _onShakeCallback != null) {
      debugPrint('🔴 User confirmed SOS from notification');
      _onShakeCallback?.call();
    }
  }

  /// User cancelled SOS from notification
  Future<void> cancelSOSFromNotification() async {
    if (_notificationCancelTimer != null) {
      debugPrint('🔴 Cancelling SOS timer...');
      _notificationCancelTimer?.cancel();
      _notificationCancelTimer = null;
    } else {
      debugPrint('🔴 Timer was ALREADY null or cancelled');
    }
    Vibration.cancel(); // Stop vibration
    await _cancelShakeNotification();
    debugPrint('🔴 User cancelled SOS from notification');
  }

  /// Test notification publicly (Simulates a real shake)
  Future<void> testNotification() async {
    // Only simulate if not already listening/processing to avoid confusion
    // forcing the handle shake logic manually for testing
    debugPrint('🔴 Testing Notification flow...');
    _showShakeNotification();

    // Start a fake timer to simulate the SOS countdown for testing cancellation
    _notificationCancelTimer?.cancel();
    _notificationCancelTimer = Timer(const Duration(seconds: 8), () {
      debugPrint('🔴 [TEST] Auto-confirming SOS after 8 second countdown...');
      _cancelShakeNotification();
      // In a real test we might not want to actually trigger the SOS callback
      // to avoid calling 911/SMS during dev, but for now let's just log it.
      debugPrint('🔴 [TEST] SOS WOULD BE TRIGGERED NOW');
    });
  }

  /// Get current listening status
  bool get isListening => _isListening;
}
