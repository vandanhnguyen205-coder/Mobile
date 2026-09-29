import 'package:flutter/material.dart';
import '../services/notification_service.dart';

/// Bài tập 1
class ScreenNotiEx extends StatelessWidget {
  const ScreenNotiEx({super.key});

  static const _learnChannel = 'learn_english_channel';
  static const _learnChannelName = 'Học Anh Văn';

  @override
  Widget build(BuildContext context) {
    final noti = NotificationService();

    void snack(String msg) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));

    return Scaffold(
      appBar: AppBar(title: const Text('Screen Noti Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => noti.showNow(
                title: 'Nhắc học từ vựng',
                body: 'Bạn đã học 5 từ mới hôm nay chưa?',
                channelId: _learnChannel,
                channelName: _learnChannelName,
              ),
              child: const Text('Gửi thông báo nhắc học Ngoại ngữ'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await noti.scheduleAfter(
                  const Duration(minutes: 2),
                  id: 101,
                  title: 'Uống nước',
                  body: 'Nhắc uống nước đúng giờ',
                  channelId: 'drink_water_channel',
                  channelName: 'Uống nước',
                );
                snack('Sẽ nhắc uống nước sau 2 phút');
              },
              child: const Text('Gửi thông báo nhắc uống nước sau 2 phút'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await noti.scheduleAfter(
                  const Duration(minutes: 10),
                  id: 102, // id khác 101 để không ghi đè lịch uống nước
                  title: 'Nhắc học Ngoại ngữ',
                  body: 'Đến giờ học Ngoại ngữ rồi!',
                  channelId: _learnChannel,
                  channelName: _learnChannelName,
                );
                snack('Sẽ nhắc học Ngoại ngữ sau 10 phút');
              },
              child: const Text('Hẹn giờ gửi thông báo học Ngoại ngữ sau 10 phút'),
            ),
          ],
        ),
      ),
    );
  }
}