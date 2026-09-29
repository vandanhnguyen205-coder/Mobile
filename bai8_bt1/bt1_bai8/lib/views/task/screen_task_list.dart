import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/file_service.dart';
import '../../services/notification_service.dart';
import '../../utils/datetime_utils.dart';
import 'screen_add_task.dart';

/// Bài tập về nhà - danh sách nhiệm vụ.
class ScreenTaskList extends StatefulWidget {
  const ScreenTaskList({super.key});

  @override
  State<ScreenTaskList> createState() => _ScreenTaskListState();
}

class _ScreenTaskListState extends State<ScreenTaskList> {
  static const _doneNotiId = 9999; // cố định để thông báo được cập nhật, không nhân bản

  final _file = FileService('tasks.txt');
  final _noti = NotificationService();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _file.loadJson(Task.fromJson);
    if (!mounted) return;
    setState(() => _tasks = data);
  }

  Future<void> _save() => _file.saveJson<Task>(_tasks, (t) => t.toJson());

  Future<void> _openAdd() async {
    final task = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => const ScreenAddTask()),
    );
    if (task == null) return; // "Lưu nhiệm vụ" -> lưu file, quay về màn hình chính
    setState(() => _tasks.add(task));
    await _save();
    final at = task.remindAt;
    if (at != null) {
      await _noti.scheduleAt(
        at,
        id: task.id,
        title: 'Nhắc nhiệm vụ',
        body: task.title,
        channelId: 'task_channel',
        channelName: 'Nhiệm vụ',
      );
    }
  }

  Future<void> _confirmDone(Task t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Nhiệm vụ "${t.title}" đã hoàn thành?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Không')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Có')),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => t.done = true);
    await _save();
    await _noti.cancel(t.id); // huỷ lịch nhắc nếu còn

    final count = _tasks.where((e) => e.done).length;
    await _noti.showNow(
      id: _doneNotiId,
      title: 'Hoàn thành nhiệm vụ',
      body: 'Bạn đã hoàn thành $count nhiệm vụ',
      channelId: 'task_done_channel',
      channelName: 'Nhiệm vụ hoàn thành',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách nhiệm vụ')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('Chưa có nhiệm vụ nào.'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (_, i) {
                final t = _tasks[i];
                return ListTile(
                  leading: Checkbox(
                    value: t.done,
                    onChanged: t.done ? null : (_) => _confirmDone(t),
                  ),
                  title: Text(
                    t.title,
                    style: TextStyle(
                      decoration: t.done ? TextDecoration.lineThrough : null,
                      color: t.done ? Colors.grey : null,
                    ),
                  ),
                  subtitle: t.remindAt == null
                      ? null
                      : Text('Nhắc lúc ${formatTime(t.remindAt!)}'),
                  trailing: t.remindAt == null
                      ? null
                      : const Icon(Icons.notifications_active, size: 20),
                );
              },
            ),
    );
  }
}