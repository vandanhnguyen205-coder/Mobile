import 'package:flutter/material.dart';
import '../../models/vocab.dart';
import '../../services/vocab_service.dart';

class _Question {
  final Vocab vocab;
  final List<String> options;
  _Question(this.vocab, this.options);
}

/// Mục "Kiểm tra từ": trắc nghiệm tự sinh từ dữ liệu đã lưu.
class VocabQuiz extends StatefulWidget {
  const VocabQuiz({super.key});

  @override
  State<VocabQuiz> createState() => _VocabQuizState();
}

class _VocabQuizState extends State<VocabQuiz> {
  static const _maxQuestions = 10;

  List<Vocab> _words = [];
  List<_Question> _questions = [];
  int _index = 0;
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
        _start();
      });
    });
  }

  void _start() {
    _index = 0;
    _correct = 0;
    _wrong = 0;
    if (_words.length < 2) {
      _questions = [];
      return;
    }
    final picked = ([..._words]..shuffle()).take(_maxQuestions);
    _questions = picked.map((v) {
      final distractors = _words
          .where((w) => w.meaning != v.meaning)
          .map((w) => w.meaning)
          .toSet()
          .toList()
        ..shuffle();
      final options = [v.meaning, ...distractors.take(3)]..shuffle();
      return _Question(v, options);
    }).toList();
  }

  void _answer(String option) {
    final q = _questions[_index];
    final ok = option == q.vocab.meaning;
    setState(() {
      ok ? _correct++ : _wrong++;
    });
    if (_index + 1 < _questions.length) {
      setState(() => _index++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() {
    final total = _questions.length;
    final percent = (_correct * 100 / total).round();
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Kết quả'),
        content: Text('Số câu đúng: $_correct\n'
            'Số câu sai: $_wrong\n'
            'Tỉ lệ đúng: $_correct/$total ($percent%)'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(_start);
            },
            child: const Text('Làm lại'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kiểm tra từ')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kiểm tra từ')),
        body: const Center(child: Text('Cần ít nhất 2 từ vựng để kiểm tra.')),
      );
    }
    final q = _questions[_index];
    return Scaffold(
      appBar: AppBar(title: const Text('Kiểm tra từ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Câu ${_index + 1}/${_questions.length}'),
                Text('Đúng: $_correct   Sai: $_wrong'),
              ],
            ),
            const SizedBox(height: 32),
            Text('Nghĩa của từ "${q.vocab.word}" là:',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 24),
            for (final o in q.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton(
                  onPressed: () => _answer(o),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(o),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}