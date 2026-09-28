import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const PhotoCaptureApp());
}

class PhotoCaptureApp extends StatelessWidget {
  const PhotoCaptureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Capture & Preview',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const PhotoCaptureHome(),
    );
  }
}

class PhotoCaptureHome extends StatefulWidget {
  const PhotoCaptureHome({super.key});

  @override
  State<PhotoCaptureHome> createState() => _PhotoCaptureHomeState();
}

class _PhotoCaptureHomeState extends State<PhotoCaptureHome> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Yêu cầu quyền truy cập
  Future<void> _requestPermission(Permission permission) async {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  // Chọn ảnh từ gallery
  Future<void> _pickImageFromGallery() async {
    await _requestPermission(Permission.photos);
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Chụp ảnh từ camera
  Future<void> _captureImageFromCamera() async {
    await _requestPermission(Permission.camera);
    final XFile? capturedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (capturedFile != null) {
      setState(() {
        _imageFile = File(capturedFile.path);
      });
    }
  }

  // Xem trước ảnh toàn màn hình
  void _showFullScreenPreview(BuildContext context) {
    if (_imageFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImage(imageFile: _imageFile!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Capture & Preview'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageFile == null)
              const Text(
                '1250080027 NGUYỄN VĂN danh Chưa có ảnh nào được chọn.',
              )
            else
              GestureDetector(
                onTap: () => _showFullScreenPreview(context),
                child: Image.file(_imageFile!, height: 300, fit: BoxFit.cover),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImageFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Chọn ảnh từ Gallery'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _captureImageFromCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Chụp ảnh từ Camera'),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget xem trước toàn màn hình
class FullScreenImage extends StatelessWidget {
  final File imageFile;

  const FullScreenImage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xem trước')),
      backgroundColor: Colors.black,
      body: Center(child: InteractiveViewer(child: Image.file(imageFile))),
    );
  }
}
