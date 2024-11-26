import 'package:appruido/controllers/Heatstats_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class HeatMapView extends StatefulWidget {
  @override
  _HeatMapViewState createState() => _HeatMapViewState();
}

class _HeatMapViewState extends State<HeatMapView> {
  final HeatMapController _heatMapController = HeatMapController();
  final MapController _mapController = MapController();

  List<CircleMarker> _heatMapCircles = [];
  DateTime _selectedDate = DateTime.now();
  int? _selectedHour;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchHeatMapData();
  }

  Future<void> _fetchHeatMapData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final data = await _heatMapController.fetchHeatMapData(formattedDate, hora: _selectedHour);

      setState(() {
        _heatMapCircles = data.map((entry) {
          final double intensity = entry['nivelRuido'];
          final LatLng position = LatLng(entry['lat'], entry['lng']);

          Color color;
          if (intensity < 65) {
            color = Colors.green.withOpacity(0.5);
          } else if (intensity < 85) {
            color = Colors.yellow.withOpacity(0.5);
          } else {
            color = Colors.red.withOpacity(0.5);
          }

          return CircleMarker(
            point: position,
            radius: 50, // Ajustar según necesidad
            color: color,
            borderColor: Colors.transparent,
          );
        }).toList();
      });
    } catch (e) {
      print('Error al cargar los datos del mapa de calor: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedHour = null; // Restablecer hora para mostrar todo el día
      });
      _fetchHeatMapData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Calor'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(10.437763, -75.517159),
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.appruido',
              ),
              CircleLayer(circles: _heatMapCircles),
            ],
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('Seleccionar Fecha'),
            ),
            DropdownButton<int>(
              hint: Text('Hora'),
              value: _selectedHour,
              items: List.generate(24, (index) => index).map((hour) {
                return DropdownMenuItem(
                  value: hour,
                  child: Text('$hour:00'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHour = value;
                });
                _fetchHeatMapData();
              },
            ),
          ],
        ),
      ),
    );
  }
}