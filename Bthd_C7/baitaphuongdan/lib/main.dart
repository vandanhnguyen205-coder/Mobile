import 'package:flutter/material.dart';

import 'router_finder_screen.dart'; // Import màn hình mới

void main() {
  runApp(const RouteFinderApp());
}

class RouteFinderApp extends StatelessWidget {
  const RouteFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Route Finder',
      home: RouteFinderScreen(),
    );
  }
}
