import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/vocab.dart';
import '../../services/notification_service.dart';
import '../../services/vocab_service.dart';
import 'vocab_learn.dart';
import 'vocab_quiz.dart';
import 'vocab_reminders.dart';

/// Bài tập 4 (tại lớp) - màn hình chính + menu.
class VocabHome extends StatefulWidget {
  const VocabHome({super.key});

  @override
  State<VocabHome> createState() => _VocabHomeState();
}

class _VocabHomeState extends State<VocabHome> {
  static const channelId = 'vocab_channel';
  static const channelName = 'Từ vựng';
  static const remindPrefix = 'vocab|';

  final _word = TextEditingController();
  final _meaning = TextEditingController();
  final _vocab = VocabService();
  final _noti = NotificationService();

  @override
  void dispose() {
    _word.dispose();
    _meaning.dispose();
    super.dispose();
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _save({required bool remind}) async {
    final word = _word.text.trim();
    final meaning = _meaning.text.trim();
    if (word.isEmpty || meaning.isEmpty) {
      _snack('Nhập đủ từ và nghĩa');
      return;
    }
    await _vocab.add(Vocab(word, meaning));

    if (remind) {
      final when = DateTime.now().add(const Duration(minutes: 10));
      await _noti.showNow(
        title: 'Đã lưu từ "$word"',
        body: 'Hãy ôn tập lại sau 10 phút',
        channelId: channelId,
        channelName: channelName,
      );
      await _noti.scheduleAt(
        when,
        title: 'Đến giờ ôn tập',
        body: 'Ôn lại từ "$word" nào!',
        channelId: channelId,
        channelName: channelName,
        payload: '$remindPrefix${when.toIso8601String()}',
      );
      _snack('Đã lưu "$word". Nhắc ôn tập lúc ${DateFormat('HH:mm').format(when)}');
    } else {
      _snack('Đã lưu "$word"');
    }
    _word.clear();
    _meaning.clear();
  }

  void _go(Widget page) {
    Navigator.pop(context); // đóng drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Học từ vựng')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('Menu', style: TextStyle(fontSize: 24)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Thêm từ'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Học từ'),
              onTap: () => _go(const VocabLearn()),
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Kiểm tra từ'),
              onTap: () => _go(const VocabQuiz()),
            ),
            ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('Lịch nhắc'),
              onTap: () => _go(const VocabReminders()),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _word,
              decoration: const InputDecoration(
                  labelText: 'Từ vựng', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _meaning,
              decoration: const InputDecoration(
                  labelText: 'Nghĩa của từ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _save(remind: false),
                child: const Text('Lưu'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => _save(remind: true),
                child: const Text('Lưu và Nhắc học sau 10 phút'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}