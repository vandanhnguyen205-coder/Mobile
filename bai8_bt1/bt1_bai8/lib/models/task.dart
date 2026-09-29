class Task {
  final int id; // dùng luôn làm id của notification nhắc việc
  String title;
  DateTime? remindAt;
  bool done;

  Task({
    required this.id,
    required this.title,
    this.remindAt,
    this.done = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'remindAt': remindAt?.toIso8601String(),
        'done': done,
      };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as int,
        title: j['title'] as String,
        remindAt:
            j['remindAt'] == null ? null : DateTime.parse(j['remindAt'] as String),
        done: j['done'] as bool? ?? false,
      );
}