class SinhVien {
  final String id;
  String hoTen;
  String email;

  SinhVien({required this.id, required this.hoTen, required this.email});

  // Tạo bản sao với dữ liệu mới (dùng cho cập nhật)
  SinhVien copyWith({String? id, String? hoTen, String? email}) {
    return SinhVien(
      id: id ?? this.id,
      hoTen: hoTen ?? this.hoTen,
      email: email ?? this.email,
    );
  }
}
