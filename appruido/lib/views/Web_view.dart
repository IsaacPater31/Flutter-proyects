import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class NoiseMapWithReports extends StatefulWidget {
  @override
  _NoiseMapWithReportsState createState() => _NoiseMapWithReportsState();
}

class _NoiseMapWithReportsState extends State<NoiseMapWithReports> {
  final MapController _mapController = MapController();
  final String apiUrl = 'http://192.168.1.14/apis/Api_Registrosruido.php';
  List<Marker> _markers = [];
  List<Map<String, dynamic>> _noiseReports = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchNoiseData();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchNoiseData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchNoiseData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          _updateMarkersAndReports(data['data']);
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _updateMarkersAndReports(List<dynamic> records) {
    List<Marker> markers = [];
    List<Map<String, dynamic>> reports = [];

    for (var record in records) {
      double nivelRuido = (record['Nivel_Ruido'] as num).toDouble();
      LatLng position = LatLng(
        (record['Latitud'] as num).toDouble(),
        (record['Longitud'] as num).toDouble(),
      );

      String fecha = record['Fecha'];
      String hora = record['Hora'];
      String usuario = record['Usuario_ID'];

      Color markerColor;
      if (nivelRuido < 65) {
        markerColor = Colors.green;
      } else if (nivelRuido < 85) {
        markerColor = Colors.yellow;
      } else {
        markerColor = Colors.red;
      }

      markers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: position,
        builder: (ctx) => Icon(Icons.location_pin, color: markerColor, size: 40),
      ));

      reports.add({
        'nivelRuido': nivelRuido,
        'fecha': fecha,
        'hora': hora,
        'usuario': usuario,
        'color': markerColor,
      });
    }

    setState(() {
      _markers = markers;
      _noiseReports = reports;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Mapa ocupando el 50% izquierdo
          Expanded(
            flex: 5,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(0.0, 0.0),
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.appruido',
                ),
                MarkerLayer(
                  markers: _markers,
                ),
              ],
            ),
          ),
          // Lista de reportes ocupando el 50% derecho
          Expanded(
            flex: 5,
            child: ListView.builder(
              itemCount: _noiseReports.length,
              itemBuilder: (context, index) {
                final report = _noiseReports[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: report['color'],
                      radius: 10,
                    ),
                    title: Text("Nivel de ruido: ${report['nivelRuido']} dB"),
                    subtitle: Text(
                        "Fecha: ${report['fecha']} - Hora: ${report['hora']}\nUsuario: ${report['usuario']}"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
