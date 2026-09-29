import 'package:flutter/material.dart';

import 'screens/man_hinh_chinh.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Quản Lý Sinh Viên",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ManHinhChinh(),
      debugShowCheckedModeBanner: false,
    );
  }
}
