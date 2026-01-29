import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request SMS permission
  static Future<PermissionStatus> requestSmsPermission() async {
    return await Permission.sms.request();
  }

  /// Request phone call permission
  static Future<PermissionStatus> requestPhonePermission() async {
    return await Permission.phone.request();
  }

  /// Request all necessary permissions for emergency SOS
  static Future<void> requestAllPermissions() async {
    await requestSmsPermission();
    await requestPhonePermission();
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.notification.request();
  }

  /// Check if permissions are granted
  static Future<bool> hasPermissions() async {
    final smsStatus = await Permission.sms.status;
    final phoneStatus = await Permission.phone.status;
    return smsStatus.isGranted && phoneStatus.isGranted;
  }
}
