import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  LatLng? _currentPosition;
  final LatLng _destination = const LatLng(
    10.7769,
    106.7009,
  ); // Chợ Bến Thành, TP.HCM
  List<LatLng> _routePoints = [];
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // 1. Lấy vị trí hiện tại của người dùng
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Vui lòng bật dịch vụ vị trí (GPS)!');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Quyền vị trí bị từ chối vĩnh viễn trong Cài đặt.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _updateMarkers();

      // Di chuyển camera đến vị trí hiện tại
      _mapController.move(_currentPosition!, 15.0);
    });
  }

  // 2. Cập nhật các Marker trên bản đồ
  void _updateMarkers() {
    _markers = [];

    // Marker vị trí hiện tại (Màu xanh dương)
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          point: _currentPosition!,
          width: 40,
          height: 40,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 35),
        ),
      );
    }

    // Marker đích đến (Màu đỏ)
    _markers.add(
      Marker(
        point: _destination,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
      ),
    );
  }

  // 3. Tìm đường bằng OSRM API (Miễn phí của OpenStreetMap)
  Future<void> _getDirections() async {
    if (_currentPosition == null) {
      _showSnackBar('Đang lấy vị trí hiện tại, vui lòng đợi...');
      return;
    }

    final String url =
        'http://router.project-osrm.org/route/v1/driving/'
        '${_currentPosition!.longitude},${_currentPosition!.latitude};'
        '${_destination.longitude},${_destination.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FlutterMapApp/1.0 (contact@flutterapp.dev)'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final coordinates =
              data['routes'][0]['geometry']['coordinates'] as List;

          setState(() {
            _routePoints = coordinates
                .map(
                  (point) => LatLng(point[1].toDouble(), point[0].toDouble()),
                )
                .toList();
          });
        } else {
          _showSnackBar('Không tìm thấy tuyến đường!');
        }
      } else {
        _showSnackBar('Lỗi đường truyền OSRM: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối API: $e');
    }
  }

  void _showSnackBar(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nguyễn Văn Danh- 1250080027'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          // Giao diện Bản đồ OpenStreetMap (Dùng CartoDB TileServer chống bị lỗi 403)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _destination, initialZoom: 13.0),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'dev.flutter.osm.navigator.app',
              ),

              // Layer hiển thị đường vẽ Polyline
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    color: Colors.blue,
                    strokeWidth: 5.0,
                  ),
                ],
              ),

              // Layer hiển thị các Marker
              MarkerLayer(markers: _markers),
            ],
          ),

          // Nút bấm lấy chỉ đường
          Positioned(
            bottom: 25,
            left: 20,
            child: FloatingActionButton.extended(
              onPressed: _getDirections,
              backgroundColor: Colors.teal,
              label: const Text('Chỉ đường (OSRM)'),
              icon: const Icon(Icons.directions),
            ),
          ),

          // Nút căn giữa vị trí hiện tại
          Positioned(
            bottom: 25,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                if (_currentPosition != null) {
                  _mapController.move(_currentPosition!, 15.0);
                } else {
                  _getCurrentLocation();
                }
              },
              child: const Icon(Icons.gps_fixed),
            ),
          ),
        ],
      ),
    );
  }
}
