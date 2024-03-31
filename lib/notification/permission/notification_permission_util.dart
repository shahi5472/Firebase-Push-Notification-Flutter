import 'package:notification_permissions/notification_permissions.dart';

import 'notification_permission_status.dart';

class NotificationPermissionUtil {
  static Future<bool> isGranted() async {
    return getStatus().then((value) => value == NotificationPermissionStatus.granted);
  }

  static Future<NotificationPermissionStatus> getStatus() async {
    final permissionStatus = await NotificationPermissions.getNotificationPermissionStatus();
    switch (permissionStatus) {
      case PermissionStatus.granted:
        return NotificationPermissionStatus.granted;
      case PermissionStatus.denied:
        return NotificationPermissionStatus.denied;
      case PermissionStatus.provisional:
        return NotificationPermissionStatus.provisional;
      default:
        return NotificationPermissionStatus.unknown;
    }
  }

  static Future<bool> request() async {
    await NotificationPermissions.requestNotificationPermissions(
      iosSettings: const NotificationSettingsIos(),
      openSettings: true,
    );
    return isGranted();
  }
}
