import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';  // Para obtener la ubicación en tiempo real
import 'package:http/http.dart' as http; // Para hacer solicitudes HTTP
import 'dart:convert'; // Para manejar JSON

class MapStartController extends StatefulWidget {
  @override
  _MapStartControllerState createState() => _MapStartControllerState();
}

class _MapStartControllerState extends State<MapStartController> {
  MapController _mapController = MapController();
  LatLng _currentPosition = LatLng(45.521563, -122.677433);  // Ubicación inicial
  List<Marker> _markers = []; // Lista para almacenar los markers

  final String apiUrl = 'http://192.168.1.16/apis/Api_Registrosruido.php'; // Asegúrate de usar la URL correcta

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();  // Llamar a la función para obtener la ubicación en tiempo real
    _fetchNoiseRecords(); // Llamar a la función para obtener los registros de ruido
  }

  // Método para obtener la ubicación actual usando Geolocator
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si los servicios de ubicación están deshabilitados, terminar
      return;
    }

    // Verificar y solicitar permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Si el permiso es denegado
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Si el permiso es denegado permanentemente
      return;
    }

    // Obtener la posición actual en tiempo real
    Geolocator.getPositionStream().listen((Position position) {
      if (position != null) {
        setState(() {
          // Actualizar la posición actual
          _currentPosition = LatLng(position.latitude, position.longitude);
          // Mover el mapa a la ubicación actual
          _mapController.move(_currentPosition, 15.0);
        });
      }
    });
  }

  // Función para obtener los registros de ruido desde el servidor
  Future<void> _fetchNoiseRecords() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data['status'] == 1) {
          _updateMarkers(data['data']);
        } else {
          print('No se encontraron registros: ${data['message']}');
        }
      } else {
        print('Error en la respuesta del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e'); // Manejo de excepciones
    }
  }

  // Función para actualizar los marcadores en el mapa
  void _updateMarkers(List<dynamic> records) {
    List<Marker> markers = [];
    for (var record in records) {
      double nivelRuido = record['Nivel_Ruido'];
      LatLng position = LatLng(record['Latitud'], record['Longitud']);

      // Determinar el color del marcador según el nivel de ruido
      Color markerColor;
      if (nivelRuido < 65) {
        markerColor = Colors.green;
      } else if (nivelRuido >= 65 && nivelRuido <= 85) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa de Ruido"),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _currentPosition,  // Usar la ubicación dinámica
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
    );
  }
}
