import 'package:flutter/material.dart';

import '../models/sinh_vien.dart';

class ManHinhChiTiet extends StatefulWidget {
  final SinhVien sinhVien;

  const ManHinhChiTiet({super.key, required this.sinhVien});

  @override
  State<ManHinhChiTiet> createState() => _ManHinhChiTietState();
}

class _ManHinhChiTietState extends State<ManHinhChiTiet> {
  late final TextEditingController _hoTenCtrl;
  late final TextEditingController _emailCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _hoTenCtrl = TextEditingController(text: widget.sinhVien.hoTen);
    _emailCtrl = TextEditingController(text: widget.sinhVien.email);
  }

  @override
  void dispose() {
    _hoTenCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _capNhat() {
    if (_formKey.currentState!.validate()) {
      final svCapNhat = widget.sinhVien.copyWith(
        hoTen: _hoTenCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      Navigator.pop(context, svCapNhat);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin chi tiết sinh viên")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mã SV: ${widget.sinhVien.id}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hoTenCtrl,
                decoration: const InputDecoration(
                  labelText: "Họ tên",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Nhập họ tên" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Nhập email" : null,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _capNhat,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Cập nhật thông tin"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hủy"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
