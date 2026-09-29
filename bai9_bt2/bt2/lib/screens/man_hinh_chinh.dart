import 'package:flutter/material.dart';

import '../models/sinh_vien.dart';
import 'man_hinh_them.dart';
import 'man_hinh_chi_tiet.dart';

class ManHinhChinh extends StatefulWidget {
  const ManHinhChinh({super.key});

  @override
  State<ManHinhChinh> createState() => _ManHinhChinhState();
}

class _ManHinhChinhState extends State<ManHinhChinh> {
  final List<SinhVien> _danhSach = [
    SinhVien(
      id: "1250080027",
      hoTen: "Nguyễn Văn Danh",
      email: "vandanhnguyen@gmail.com",
    ),
    SinhVien(id: "2", hoTen: "Nguyễn Văn B", email: "b@example.com"),
    SinhVien(id: "3", hoTen: "An Bình Trần", email: "abt@abc.com"),
  ];

  String _tuKhoa = "";

  List<SinhVien> get _danhSachLoc => _tuKhoa.isEmpty
      ? _danhSach
      : _danhSach
            .where(
              (sv) => sv.hoTen.toLowerCase().contains(_tuKhoa.toLowerCase()),
            )
            .toList();

  Future<void> _moManHinhThem() async {
    final svMoi = await showDialog<SinhVien>(
      context: context,
      builder: (ctx) => const ManHinhThem(),
    );
    if (svMoi != null) {
      setState(() => _danhSach.add(svMoi));
    }
  }

  Future<void> _moChiTiet(SinhVien sv) async {
    final svCapNhat = await Navigator.push<SinhVien>(
      context,
      MaterialPageRoute(builder: (ctx) => ManHinhChiTiet(sinhVien: sv)),
    );
    if (svCapNhat != null) {
      setState(() {
        final index = _danhSach.indexWhere((x) => x.id == sv.id);
        if (index != -1) _danhSach[index] = svCapNhat;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            decoration: const InputDecoration(
              hintText: "Tìm kiếm sinh viên...",
              border: InputBorder.none,
              icon: Icon(Icons.search),
            ),
            onChanged: (giaTri) => setState(() => _tuKhoa = giaTri),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moManHinhThem,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _danhSachLoc.length,
        itemBuilder: (ctx, index) {
          final sv = _danhSachLoc[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(child: Text(sv.hoTen[0])),
              title: Text(sv.hoTen),
              subtitle: Text(sv.email),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _moChiTiet(sv),
            ),
          );
        },
      ),
    );
  }
}
