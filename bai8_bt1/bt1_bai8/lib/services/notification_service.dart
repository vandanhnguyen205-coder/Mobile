import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Singleton: gọi NotificationService() ở đâu cũng trả về cùng một instance,
/// init() chỉ chạy một lần.
class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// ID duy nhất (int32 dương) cho mỗi thông báo.
  static int newId() =>
      DateTime.now().millisecondsSinceEpoch.remainder(0x7FFFFFFF);

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  // ================= INIT =================
  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings);
    await _requestPermission();
    _initialized = true;
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    // Android 12+: quyền báo thức chính xác (cho zonedSchedule exact)
    final android = _android;
    if (android != null &&
        !(await android.canScheduleExactNotifications() ?? false)) {
      await android.requestExactAlarmsPermission();
    }
  }

  NotificationDetails _details(
    String channelId,
    String channelName,
    String? channelDescription,
  ) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        playSound: true,
        enableVibration: true,
        showWhen: true,
      ),
    );
  }

  // ================= HIỂN THỊ NGAY =================
  Future<void> showNow({
    int? id,
    required String title,
    required String body,
    String channelId = 'general_channel',
    String channelName = 'Thông báo chung',
    String? channelDescription,
    String? payload,
  }) {
    return _plugin.show(
      id ?? newId(),
      title,
      body,
      _details(channelId, channelName, channelDescription),
      payload: payload,
    );
  }

  // ================= HẸN GIỜ =================
  /// Lên lịch tại thời điểm [when]. Trả về id của thông báo.
  Future<int> scheduleAt(
    DateTime when, {
    int? id,
    required String title,
    required String body,
    String channelId = 'general_channel',
    String channelName = 'Thông báo chung',
    String? channelDescription,
    String? payload,
  }) async {
    final nid = id ?? newId();
    final exact = await _android?.canScheduleExactNotifications() ?? false;
    await _plugin.zonedSchedule(
      nid,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      _details(channelId, channelName, channelDescription),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
    return nid;
  }

  /// Lên lịch sau một khoảng [delay].
  Future<int> scheduleAfter(
    Duration delay, {
    int? id,
    required String title,
    required String body,
    String channelId = 'general_channel',
    String channelName = 'Thông báo chung',
    String? channelDescription,
    String? payload,
  }) {
    return scheduleAt(
      DateTime.now().add(delay),
      id: id,
      title: title,
      body: body,
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();
}
