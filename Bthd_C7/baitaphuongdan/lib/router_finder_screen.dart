/*
 * BÀI TẬP 1: TÌM ĐƯỜNG ĐI VÀ TÍNH KHOẢNG CÁCH (ROUTE FINDER)
 * Họ và tên: [Nguyễn Văn Danh]
 * MSSV: [1250080027]
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class RouteFinderScreen extends StatefulWidget {
  const RouteFinderScreen({super.key});

  @override
  State<RouteFinderScreen> createState() => RouteFinderScreenState();
}

class RouteFinderScreenState extends State<RouteFinderScreen> {
  final MapController _mapController = MapController();

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  LatLng? _startLatLng;
  LatLng? _endLatLng;

  List<LatLng> _routePoints = [];
  final List<Marker> _markers = [];
  bool _isLoading = false;

  // Khai báo biến lưu Khoảng cách và Thời gian
  String _distance = '';
  String _duration = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // 1. Lấy vị trí hiện tại
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
      _startLatLng = LatLng(position.latitude, position.longitude);
      _startController.text = "${position.latitude}, ${position.longitude}";
      _updateMarkers();
      _mapController.move(_startLatLng!, 14.0);
    });
  }

  // 2. Chuyển đổi tên/tọa độ đầu vào
  Future<LatLng?> _parseLocationInput(String input) async {
    input = input.trim();
    if (input.isEmpty) return null;

    if (input.contains(',')) {
      List<String> parts = input.split(',');
      if (parts.length == 2) {
        double? lat = double.tryParse(parts[0].trim());
        double? lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) {
          return LatLng(lat, lng);
        }
      }
    }

    final String url =
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(input)}&format=json&limit=1';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FlutterMapApp/1.0 (contact@flutterapp.dev)'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          double lat = double.parse(data[0]['lat']);
          double lon = double.parse(data[0]['lon']);
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      debugPrint('Lỗi Geocoding: $e');
    }
    return null;
  }

  // 3. Tìm đường đi
  Future<void> _findRoute() async {
    FocusScope.of(context).unfocus();

    if (_startController.text.isEmpty || _endController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập cả hai điểm!');
      return;
    }

    setState(() {
      _isLoading = true;
      _distance = '';
      _duration = '';
    });

    _startLatLng = await _parseLocationInput(_startController.text);
    if (_startLatLng == null) {
      _showSnackBar('Không xác định được điểm xuất phát!');
      setState(() => _isLoading = false);
      return;
    }

    _endLatLng = await _parseLocationInput(_endController.text);
    if (_endLatLng == null) {
      _showSnackBar('Không xác định được điểm đích đến!');
      setState(() => _isLoading = false);
      return;
    }

    _updateMarkers();
    await _fetchRouteOSRM();

    setState(() {
      _isLoading = false;
    });
  }

  // 4. Lấy tuyến đường + Bổ sung TÍNH KHOẢNG CÁCH & THỜI GIAN
  Future<void> _fetchRouteOSRM() async {
    final String url =
        'http://router.project-osrm.org/route/v1/driving/'
        '${_startLatLng!.longitude},${_startLatLng!.latitude};'
        '${_endLatLng!.longitude},${_endLatLng!.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FlutterMapApp/1.0 (contact@flutterapp.dev)'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final coordinates = route['geometry']['coordinates'] as List;

          // Lấy khoảng cách (mét) và thời gian (giây) từ OSRM API
          double distanceInMeters = (route['distance'] as num).toDouble();
          double durationInSeconds = (route['duration'] as num).toDouble();

          setState(() {
            _routePoints = coordinates
                .map(
                  (point) => LatLng(point[1].toDouble(), point[0].toDouble()),
                )
                .toList();

            // Quy đổi sang km và phút
            _distance = '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
            _duration = '${(durationInSeconds / 60).round()} phút';
          });

          _mapController.move(_startLatLng!, 13.0);
        } else {
          _showSnackBar('Không tìm thấy tuyến đường nào!');
        }
      } else {
        _showSnackBar('Lỗi API OSRM: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối API: $e');
    }
  }

  void _updateMarkers() {
    _markers.clear();

    if (_startLatLng != null) {
      _markers.add(
        Marker(
          point: _startLatLng!,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
        ),
      );
    }

    if (_endLatLng != null) {
      _markers.add(
        Marker(
          point: _endLatLng!,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      );
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route Finder',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'SV: Nguyễn Văn Danh - MSSV: 1250080027',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _startController,
                  decoration: InputDecoration(
                    labelText: 'Điểm xuất phát (lat, lng hoặc tên địa điểm)',
                    prefixIcon: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.gps_fixed),
                      onPressed: _getCurrentLocation,
                    ),
                  ),
                ),
                TextField(
                  controller: _endController,
                  decoration: const InputDecoration(
                    labelText: 'Điểm đích (lat, lng hoặc tên địa điểm)',
                    prefixIcon: Icon(Icons.location_on, color: Colors.red),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _findRoute,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Tìm đường đi',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                // HIỂN THỊ KHOẢNG CÁCH VÀ THỜI GIAN KHI CÓ KẾT QUẢ
                if (_distance.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.straighten, color: Colors.teal),
                            const SizedBox(width: 5),
                            Text(
                              'Khoảng cách: $_distance',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.orange),
                            const SizedBox(width: 5),
                            Text(
                              'Thời gian: $_duration',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(10.7769, 106.7009),
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'dev.flutter.osm.routefinder.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue,
                      strokeWidth: 5.0,
                    ),
                  ],
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
