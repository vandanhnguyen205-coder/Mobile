import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/file_service.dart';
import '../services/notification_service.dart';
import '../utils/datetime_utils.dart';

/// Bài tập 2 (withReminder = false) và Bài tập 3 (withReminder = true).
class ScreenTodo extends StatefulWidget {
  const ScreenTodo({super.key, this.withReminder = false});
  final bool withReminder;

  @override
  State<ScreenTodo> createState() => _ScreenTodoState();
}

class _ScreenTodoState extends State<ScreenTodo> {
  final _controller = TextEditingController();
  final _fileService = FileService('todo.txt');
  final _noti = NotificationService();

  List<Todo> _todos = [];
  DateTime? _selectedTime;

  final _colors = [
    Colors.red.shade100,
    Colors.green.shade100,
    Colors.blue.shade100,
    Colors.yellow.shade100,
    Colors.purple.shade100,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await _fileService.loadTodos();
    if (!mounted) return;
    setState(() => _todos = data);
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _pick() async {
    final t = await pickDateTime(context, initial: _selectedTime);
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _add() async {
    final title = _controller.text.trim();
    final time = _selectedTime;
    if (title.isEmpty || time == null) {
      _snack('Nhập tên công việc và chọn thời gian');
      return;
    }
    if (widget.withReminder && !time.isAfter(DateTime.now())) {
      _snack('Thời gian nhắc phải ở tương lai');
      return;
    }

    setState(() => _todos.add(Todo(title: title, time: time)));
    await _fileService.saveTodos(_todos);

    if (widget.withReminder) {
      // 1) Đặt lịch nhắc đúng giờ đã chọn
      await _noti.scheduleAt(
        time,
        title: 'Đến giờ làm việc',
        body: title,
        channelId: 'todo_channel',
        channelName: 'Công việc',
      );
      // 2) Thông báo ngay là đã thêm lịch
      await _noti.showNow(
        title: 'Đã thêm lịch công việc',
        body: '$title - ${formatTime(time)}',
        channelId: 'todo_channel',
        channelName: 'Công việc',
      );
    }

    _controller.clear();
    setState(() => _selectedTime = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.withReminder ? 'Nhắc việc' : 'Todo App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Tên công việc',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(_selectedTime == null
                      ? 'Chưa chọn thời gian'
                      : formatTime(_selectedTime!)),
                ),
                OutlinedButton(
                    onPressed: _pick, child: const Text('Chọn thời gian')),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _add, child: const Text('Lưu')),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (_, i) {
                  final t = _todos[i];
                  return Card(
                    color: _colors[i % _colors.length],
                    child: ListTile(
                      leading: const Icon(Icons.task, color: Colors.black87),
                      title: Text(t.title,
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(formatTime(t.time),
                          style: const TextStyle(color: Colors.black54)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}