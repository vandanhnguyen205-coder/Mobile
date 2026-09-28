/*
 * BÀI TẬP: SIMPLE AUDIO PLAYER
 * Họ và tên: [Nguyễn Văn danh]
 * MSSV: [1250080027]
 */

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const AudioPlayerApp());
}

class AudioPlayerApp extends StatelessWidget {
  const AudioPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Audio Player',
      home: SimpleAudioPlayerScreen(),
    );
  }
}

class SimpleAudioPlayerScreen extends StatefulWidget {
  const SimpleAudioPlayerScreen({super.key});

  @override
  State<SimpleAudioPlayerScreen> createState() =>
      _SimpleAudioPlayerScreenState();
}

class _SimpleAudioPlayerScreenState extends State<SimpleAudioPlayerScreen> {
  // Tạo đối tượng AudioPlayer từ package audioplayers
  late AudioPlayer _audioPlayer;

  // Danh sách các bài hát trong thư mục assets/audios/
  // Chỉ có một file âm thanh thực tế trong project: sample.mp3
  final List<String> _playlist = ['sample.mp3'];

  int _currentIndex = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Lắng nghe trạng thái phát nhạc để tự động cập nhật UI
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Khi phát hết bài hát, tự động chuyển sang bài tiếp theo
    _audioPlayer.onPlayerComplete.listen((event) {
      _next();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Lấy tên hiển thị của bài hát (loại bỏ đuôi .mp3)
  String get _currentSongName {
    final fileName = _playlist[_currentIndex];
    return fileName.replaceAll('.mp3', '');
  }

  // 1. Chức năng Phát nhạc (Play)
  Future<void> _play() async {
    await _audioPlayer.play(AssetSource('audios/${_playlist[_currentIndex]}'));
  }

  // 2. Chức năng Tạm dừng (Pause)
  Future<void> _pause() async {
    await _audioPlayer.pause();
  }

  // 3. Chức năng Dừng hẳn (Stop)
  Future<void> _stop() async {
    await _audioPlayer.stop();
  }

  // 4. Chức năng Bài tiếp theo (Next)
  Future<void> _next() async {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    });
    await _play();
  }

  // 5. Chức năng Bài trước đó (Previous)
  Future<void> _previous() async {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    });
    await _play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC), // Màu nền sáng theo đúng hình
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simple Audio Player',
              style: TextStyle(color: Colors.black87, fontSize: 18),
            ),
            Text(
              'SV: Nguyễn Văn A - MSSV: 12345678',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tên bài hát hiển thị ở giữa
            Text(
              _currentSongName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),

            // Hàng chứa các nút điều khiển: Previous, Play/Pause, Stop, Next
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nút Previous
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _previous,
                ),
                const SizedBox(width: 10),

                // Nút Play / Pause
                IconButton(
                  iconSize: 32,
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (_isPlaying) {
                      _pause();
                    } else {
                      _play();
                    }
                  },
                ),
                const SizedBox(width: 10),

                // Nút Stop
                IconButton(
                  iconSize: 28,
                  icon: const Icon(Icons.stop),
                  onPressed: _stop,
                ),
                const SizedBox(width: 10),

                // Nút Next
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.skip_next),
                  onPressed: _next,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
