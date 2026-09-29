class Todo {
  String title;
  DateTime time;

  Todo({required this.title, required this.time});

  // convert -> string (mỗi Todo một dòng)
  String toFileString() =>
      '${title.replaceAll('\n', ' ')}|${time.toIso8601String()}';

  // parse <- string; tách ở dấu '|' cuối cùng nên title có '|' vẫn đúng
  static Todo fromString(String line) {
    final i = line.lastIndexOf('|');
    return Todo(
      title: line.substring(0, i),
      time: DateTime.parse(line.substring(i + 1)),
    );
  }
} 