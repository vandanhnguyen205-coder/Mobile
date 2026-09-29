import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/todo.dart';

/// Đọc/ghi file text trong thư mục documents của app, mỗi dòng một bản ghi.
class FileService {
  FileService([this.fileName = 'todo.txt']);
  final String fileName;

  Future<String> get _path async =>
      (await getApplicationDocumentsDirectory()).path;

  Future<File> get _file async => File('${await _path}/$fileName');

  Future<List<String>> readLines() async {
    try {
      final file = await _file;
      if (!await file.exists()) return [];
      final lines = await file.readAsLines();
      return lines.where((l) => l.trim().isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> writeLines(List<String> lines) async {
    final file = await _file;
    await file.writeAsString(lines.isEmpty ? '' : '${lines.join('\n')}\n');
  }

  Future<void> appendLine(String line) async {
    final file = await _file;
    await file.writeAsString('$line\n', mode: FileMode.append);
  }

  // ---- Todo (todo.txt) ----
  Future<void> saveTodos(List<Todo> todos) =>
      writeLines(todos.map((e) => e.toFileString()).toList());

  Future<List<Todo>> loadTodos() async {
    final result = <Todo>[];
    for (final line in await readLines()) {
      try {
        result.add(Todo.fromString(line));
      } catch (_) {} // bỏ qua dòng hỏng
    }
    return result;
  }

  // ---- JSON lines (vocab, tasks) ----
  Future<List<T>> loadJson<T>(T Function(Map<String, dynamic>) fromJson) async {
    final result = <T>[];
    for (final line in await readLines()) {
      try {
        result.add(fromJson(jsonDecode(line) as Map<String, dynamic>));
      } catch (_) {}
    }
    return result;
  }

  Future<void> saveJson<T>(
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) =>
      writeLines(items.map((e) => jsonEncode(toJson(e))).toList());
}