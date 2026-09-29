import 'package:flutter/material.dart';

import '../models/sinh_vien.dart';

class ManHinhThem extends StatefulWidget {
  const ManHinhThem({super.key});

  @override
  State<ManHinhThem> createState() => _ManHinhThemState();
}

class _ManHinhThemState extends State<ManHinhThem> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _hoTenCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _luu() {
    if (_formKey.currentState!.validate()) {
      final svMoi = SinhVien(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Tạo mã tạm
        hoTen: _hoTenCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      Navigator.pop(context, svMoi); // Trả về màn hình chính
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Thêm Sinh Viên",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _hoTenCtrl,
                decoration: const InputDecoration(
                  labelText: "Tên sinh viên",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? "Nhập họ tên"
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? "Nhập email" : null,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hủy"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: _luu, child: const Text("Lưu")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
