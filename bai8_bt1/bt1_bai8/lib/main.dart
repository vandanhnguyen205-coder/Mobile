import 'package:flutter/material.dart';

import 'services/notification_service.dart';
import 'views/screen_noti_ex.dart';
import 'views/screen_todo.dart';
import 'views/task/screen_task_list.dart';
import 'views/vocab/vocab_home.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
    );
  }
}

/// Màn hình gộp để mở từng bài tập.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(String, Widget)>[
      ('Bài 1 - Notification cơ bản', const ScreenNotiEx()),
      ('Bài 2 - Todo lưu file', const ScreenTodo()),
      ('Bài 3 - Todo + lịch nhắc', const ScreenTodo(withReminder: true)),
      ('Bài 4 (lớp) - Học từ vựng', const VocabHome()),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 08 - Notification & File')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (label, page) in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilledButton.tonal(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                ),
                child: Text(label),
              ),
            ),
        ],
      ),
    );
  }
}
