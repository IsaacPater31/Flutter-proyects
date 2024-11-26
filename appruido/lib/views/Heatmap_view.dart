import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

class HeatmapView extends StatefulWidget {
  @override
  _HeatmapViewState createState() => _HeatmapViewState();
}

class _HeatmapViewState extends State<HeatmapView> {
  final MapController _mapController = MapController();

  List<WeightedLatLng> _heatmapPoints = [];

  @override
  void initState() {
    super.initState();
    _loadHeatmapData();
  }

  Future<void> _loadHeatmapData() async {
    // Simular datos de ejemplo. Aquí puedes agregar datos reales desde tu API.
    setState(() {
      _heatmapPoints = [
        WeightedLatLng(LatLng(37.7749, -122.4194), 0.8), // San Francisco
        WeightedLatLng(LatLng(34.0522, -118.2437), 0.5), // Los Ángeles
        WeightedLatLng(LatLng(40.7128, -74.0060), 0.7),  // Nueva York
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Calor'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(37.7749, -122.4194), // Centrado en San Francisco
          zoom: 5.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          HeatMapLayer(
            heatMapDataSource: _heatmapPoints,
            radius: 25.0,
            blur: 15.0,
            maxOpacity: 0.8,
            minOpacity: 0.2,
          ),
        ],
      ),
    );
  }
}
