import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../services/notification_service.dart';
import '../../utils/datetime_utils.dart';

/// Mục "Lịch nhắc": các lịch đã đặt nhưng chưa hiển thị notification.
class VocabReminders extends StatefulWidget {
  const VocabReminders({super.key});

  @override
  State<VocabReminders> createState() => _VocabRemindersState();
}

class _VocabRemindersState extends State<VocabReminders> {
  final _noti = NotificationService();
  late Future<List<PendingNotificationRequest>> _future = _fetch();

  Future<List<PendingNotificationRequest>> _fetch() async {
    final all = await _noti.pending();
    return all.where((r) => (r.payload ?? '').startsWith('vocab|')).toList()
      ..sort((a, b) => _time(a).compareTo(_time(b)));
  }

  DateTime _time(PendingNotificationRequest r) =>
      DateTime.tryParse((r.payload ?? '').replaceFirst('vocab|', '')) ??
      DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch nhắc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _future = _fetch()),
          ),
        ],
      ),
      body: FutureBuilder<List<PendingNotificationRequest>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Chưa có lịch nhắc nào.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final r = items[i];
              return ListTile(
                leading: const Icon(Icons.alarm),
                title: Text(r.body ?? ''),
                subtitle: Text('Lúc ${formatTime(_time(r))}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await _noti.cancel(r.id);
                    setState(() => _future = _fetch());
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}