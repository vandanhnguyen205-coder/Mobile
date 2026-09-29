import '../models/vocab.dart';
import 'file_service.dart';

class VocabService {
  final FileService _file = FileService('vocab.txt');

  Future<List<Vocab>> load() => _file.loadJson(Vocab.fromJson);

  /// Thêm từ mới; nếu từ đã tồn tại thì cập nhật nghĩa.
  Future<void> add(Vocab v) async {
    final list = await load();
    final i =
        list.indexWhere((e) => e.word.toLowerCase() == v.word.toLowerCase());
    if (i >= 0) {
      list[i] = v;
    } else {
      list.add(v);
    }
    await _file.saveJson<Vocab>(list, (e) => e.toJson());
  }
}