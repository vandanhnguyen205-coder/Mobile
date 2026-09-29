import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/vocab.dart';
import '../../services/notification_service.dart';
import '../../services/vocab_service.dart';

/// Menu "Học từ": hiện từ, nhập nghĩa, Check.
class VocabLearn extends StatefulWidget {
  const VocabLearn({super.key});

  @override
  State<VocabLearn> createState() => _VocabLearnState();
}

class _VocabLearnState extends State<VocabLearn> {
  final _rand = Random();
  final _ctrl = TextEditingController();
  final _noti = NotificationService();

  List<Vocab> _words = [];
  Vocab? _current;
  int _correct = 0;
  int _wrong = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    VocabService().load().then((list) {
      if (!mounted) return;
      setState(() {
        _words = list;
        _loading = false;
        _pickNext();
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _pickNext() {
    if (_words.isEmpty) return;
    Vocab next;
    do {
      next = _words[_rand.nextInt(_words.length)];
    } while (_words.length > 1 && next == _current);
    _current = next;
  }

  Future<void> _check() async {
    final cur = _current;
    if (cur == null) return;
    final ok = _ctrl.text.trim().toLowerCase() == cur.meaning.trim().toLowerCase();

    setState(() {
      ok ? _correct++ : _wrong++;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Chính xác!' : 'Sai rồi. Đáp án: ${cur.meaning}'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));

    // Số từ sai là bội số của 3 -> notification
    if (!ok && _wrong % 3 == 0) {
      await _noti.showNow(
        title: 'Cần ôn tập thêm',
        body: 'Bạn đã trả lời sai $_wrong từ. Cố lên!',
        channelId: 'vocab_channel',
        channelName: 'Từ vựng',
      );
    }
    _ctrl.clear();
    setState(_pickNext);
  }

  Widget _counter(String label, int value, Color color) => Expanded(
        child: Card(
          color: color,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(label),
                Text('$value',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Học từ')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _current == null
              ? const Center(child: Text('Chưa có từ vựng nào. Hãy thêm từ trước.'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(children: [
                        _counter('Đúng', _correct, Colors.green.shade100),
                        _counter('Sai', _wrong, Colors.red.shade100),
                      ]),
                      const SizedBox(height: 32),
                      Text(_current!.word,
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _ctrl,
                        decoration: const InputDecoration(
                            labelText: 'Nhập nghĩa của từ',
                            border: OutlineInputBorder()),
                        onSubmitted: (_) => _check(),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _check, child: const Text('Check')),
                    ],
                  ),
                ),
    );
  }
}