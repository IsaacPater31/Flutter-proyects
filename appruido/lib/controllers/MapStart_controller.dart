import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapStartController extends StatefulWidget {
  @override
  _MapStartControllerState createState() => _MapStartControllerState();
}

class _MapStartControllerState extends State<MapStartController> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = LatLng(0.0, 0.0);
  List<Marker> _markers = [];
  final String apiUrl = 'http://192.168.1.16/apis/Api_Registrosruido.php';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchNoiseRecords();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Servicios de ubicación desactivados.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Permiso de ubicación denegado.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("Permiso de ubicación denegado permanentemente.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      print("Coordenadas actuales: Latitud: ${position.latitude}, Longitud: ${position.longitude}");

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      _mapController.move(_currentPosition, 15.0);
    } catch (e) {
      print("Error obteniendo la ubicación: $e");
    }
  }

  Future<void> _fetchNoiseRecords() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print("Respuesta de la API: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data['status'] == 1) {
          _updateMarkers(data['data']);
        } else {
          print("Error en datos de la API: ${data['message']}"); // Manejo de errores
        }
      } else {
        print("Error en la respuesta HTTP: Código ${response.statusCode}");
      }
    } catch (e) {
      print("Error en solicitud HTTP: $e");
    }
  }

  void _updateMarkers(List<dynamic> records) {
    List<Marker> markers = [];
    for (var record in records) {
      double nivelRuido = (record['Nivel_Ruido'] as num).toDouble();
      LatLng position = LatLng(
        (record['Latitud'] as num).toDouble(),
        (record['Longitud'] as num).toDouble(),
      );

      String fecha = record['Fecha'];
      String hora = record['Hora'];
      print("Registro: Nivel de ruido: $nivelRuido, Fecha: $fecha, Hora: $hora, Coordenadas: $position");

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
    }

    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: _currentPosition,
        zoom: 13.0,
        onMapReady: () {
          if (_currentPosition.latitude != 0.0 && _currentPosition.longitude != 0.0) {
            _mapController.move(_currentPosition, 15.0);
          }
        },
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
    );
  }
}
