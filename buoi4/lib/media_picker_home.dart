import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class MediaPickerHome extends StatefulWidget {
  const MediaPickerHome({super.key});

  @override
  State<MediaPickerHome> createState() => _MediaPickerHomeState();
}

class _MediaPickerHomeState extends State<MediaPickerHome> {
  File? _mediaFile; // Lưu trữ file media (image hoặc video)
  VideoPlayerController? _videoController; // Điều khiển phát video
  final ImagePicker _picker = ImagePicker(); // Khởi tạo ImagePicker

  // Kiểm tra và yêu cầu quyền truy cập
  Future<void> _requestPermission(Permission permission) async {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  // Khởi tạo Video Player
  Future<void> _initVideoPlayer(File file) async {
    await _videoController?.dispose(); // Giải phóng controller cũ nếu có
    _videoController = VideoPlayerController.file(file);
    await _videoController!.initialize();
    setState(() {}); // Cập nhật lại UI sau khi khởi tạo xong
    _videoController!.play();
  }

  // Chọn ảnh hoặc video từ gallery
  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    // Yêu cầu quyền dựa trên nền tảng/loại media
    if (isVideo) {
      await _requestPermission(Permission.videos);
    } else {
      await _requestPermission(Permission.photos);
    }

    final XFile? pickedFile = isVideo
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(
            source: source,
            imageQuality: 100,
            maxWidth: 1920,
            maxHeight: 1080,
          );

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      if (isVideo) {
        await _initVideoPlayer(file);
      } else {
        await _videoController?.dispose();
        _videoController = null;
      }

      setState(() {
        _mediaFile = file;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Chưa chọn tệp nào')));
      }
    }
  }

  // Chụp ảnh hoặc quay video từ camera
  Future<void> _captureMedia(bool isVideo) async {
    await _requestPermission(Permission.camera);
    if (isVideo) {
      await _requestPermission(Permission.microphone);
    }

    final XFile? capturedFile = isVideo
        ? await _picker.pickVideo(source: ImageSource.camera)
        : await _picker.pickImage(
            source: ImageSource.camera,
            imageQuality: 100,
            maxWidth: 1920,
            maxHeight: 1080,
          );

    if (capturedFile != null) {
      final File file = File(capturedFile.path);
      if (isVideo) {
        await _initVideoPlayer(file);
      } else {
        await _videoController?.dispose();
        _videoController = null;
      }

      setState(() {
        _mediaFile = file;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Chưa ghi hình tệp nào')));
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose(); // Giải phóng bộ nhớ khi widget bị hủy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Picker App'), centerTitle: true),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Hiển thị khung xem trước Media
              if (_mediaFile == null)
                const Text(
                  '1250080027 Nguyễn Văn Danh Chưa chọn ảnh hoặc video.',
                )
              else if (_videoController != null &&
                  _videoController!.value.isInitialized)
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
              else
                Image.file(_mediaFile!, height: 300, fit: BoxFit.cover),

              const SizedBox(height: 30),

              // Danh sách nút bấm
              ElevatedButton.icon(
                onPressed: () => _pickMedia(ImageSource.gallery, false),
                icon: const Icon(Icons.photo_library),
                label: const Text('Chọn ảnh từ Gallery'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _captureMedia(false),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Chụp ảnh từ Camera'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _pickMedia(ImageSource.gallery, true),
                icon: const Icon(Icons.video_library),
                label: const Text('Chọn video từ Gallery'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _captureMedia(true),
                icon: const Icon(Icons.videocam),
                label: const Text('Quay video từ Camera'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
