class Vocab {
  final String word;
  final String meaning;
  const Vocab(this.word, this.meaning);

  Map<String, dynamic> toJson() => {'word': word, 'meaning': meaning};

  factory Vocab.fromJson(Map<String, dynamic> j) =>
      Vocab(j['word'] as String, j['meaning'] as String);
}