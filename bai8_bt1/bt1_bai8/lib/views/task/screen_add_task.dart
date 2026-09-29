import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/notification_service.dart';
import '../../utils/datetime_utils.dart';

/// Thêm nhiệm vụ. Trả về [Task] qua Navigator.pop khi bấm "Lưu nhiệm vụ".
class ScreenAddTask extends StatefulWidget {
  const ScreenAddTask({super.key});

  @override
  State<ScreenAddTask> createState() => _ScreenAddTaskState();
}

class _ScreenAddTaskState extends State<ScreenAddTask> {
  final _title = TextEditingController();
  DateTime? _remindAt;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _pickReminder() async {
    final t = await pickDateTime(context, initial: _remindAt);
    if (t == null) return;
    if (!t.isAfter(DateTime.now())) {
      _snack('Thời gian nhắc phải ở tương lai');
      return;
    }
    setState(() => _remindAt = t);
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      _snack('Nhập tên nhiệm vụ');
      return;
    }
    Navigator.pop(
      context,
      Task(id: NotificationService.newId(), title: title, remindAt: _remindAt),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm nhiệm vụ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                  labelText: 'Nhiệm vụ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton.filledTonal(
                  tooltip: 'Đặt thời gian thông báo',
                  icon: Icon(_remindAt == null
                      ? Icons.notifications_none
                      : Icons.notifications_active),
                  onPressed: _pickReminder,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_remindAt == null
                      ? 'Chưa đặt thông báo'
                      : 'Nhắc lúc ${formatTime(_remindAt!)}'),
                ),
                if (_remindAt != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _remindAt = null),
                  ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: _save, child: const Text('Lưu nhiệm vụ')),
            ),
          ],
        ),
      ),
    );
  }
}