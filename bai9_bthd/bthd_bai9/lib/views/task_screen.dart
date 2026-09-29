import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import 'task_detail.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Task> _tasks = [];
  final TaskController _taskController = TaskController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final list = await _taskController.fetchTasks();
    if (mounted) setState(() => _tasks = list);
  }

  Future<void> _searchTask(String keyword) async {
    if (keyword.trim().isEmpty) {
      await _loadTasks();
    } else {
      final result = await _taskController.searchTasks(keyword);
      if (mounted) setState(() => _tasks = result);
    }
  }

  Future<void> _addTask() async {
    if (_titleCtrl.text.trim().isEmpty) return;

    bool exists = await _taskController.isTaskExist(_titleCtrl.text.trim());
    if (exists && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Công việc đã tồn tại!')));
      return;
    }

    Task newTask = Task(
      id: _tasks.isNotEmpty ? _tasks.last.id + 1 : 1,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
    );

    await _taskController.insertTask(newTask);
    _titleCtrl.clear();
    _descCtrl.clear();
    await _loadTasks();
  }

  Future<void> _deleteLastTask() async {
    if (_tasks.isEmpty) return;
    await _taskController.deleteTask(_tasks.last.id);
    await _loadTasks();
  }

  Future<void> _openEditScreen(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );
    if (result == true) _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Công việc'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
              ),
              onChanged: _searchTask,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addTask,
                    child: const Text('Thêm'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleteLastTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text('Xóa cuối'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(child: Text('Chưa có công việc nào'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (ctx, i) {
                        final task = _tasks[i];
                        return Card(
                          color: task.isCompleted
                              ? Colors.green[100]
                              : Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Text(task.description),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openEditScreen(task),
                            ),
                            onTap: () {
                              _titleCtrl.text = task.title;
                              _descCtrl.text = task.description;
                            },
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
