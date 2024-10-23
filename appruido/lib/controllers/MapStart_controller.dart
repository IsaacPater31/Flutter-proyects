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

  final String apiUrl = 'http://192.168.1.12/apis/Api_Registrosruido.php'; // Asegúrate de usar la URL correcta

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();  // Llamar a la función para obtener la ubicación en tiempo real
    _fetchNoiseRecords(); // Llamar a la función para obtener los registros de ruido
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si no están habilitados, mostrar un mensaje o pedir que los habiliten
      return;
    }

    // Verificar los permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Si los permisos son negados, mostrar un mensaje o manejarlo
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Manejar el caso en que los permisos se niegan permanentemente
      return;
    }

    // Obtener la ubicación en tiempo real
    Geolocator.getPositionStream().listen((Position position) {
      // Verificar que la posición no sea nula
      if (position != null) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _mapController.move(_currentPosition, 15.0);  // Mover el mapa a la ubicación actual
        });
      }
    });
  }

  Future<void> _fetchNoiseRecords() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verificar que la respuesta sea un objeto y contenga 'status'
        if (data is Map<String, dynamic> && data['status'] == 1) {
          _updateMarkers(data['data']); // Actualizar marcadores si hay registros
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

  void _updateMarkers(List<dynamic> records) {
    List<Marker> markers = [];
    for (var record in records) {
      // Asegúrate de que estos valores se manejen como double
      double nivelRuido = (record['Nivel_Ruido'] is String)
          ? double.tryParse(record['Nivel_Ruido']) ?? 0.0
          : record['Nivel_Ruido'];
      LatLng position = LatLng(
        (record['Latitud'] is String) ? double.tryParse(record['Latitud']) ?? 0.0 : record['Latitud'],
        (record['Longitud'] is String) ? double.tryParse(record['Longitud']) ?? 0.0 : record['Longitud'],
      );

      // Determinar el color del marcador según el nivel de ruido
      Color markerColor = nivelRuido < 31 ? Colors.green : Colors.red;

      markers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: position,
        builder: (ctx) => Icon(Icons.location_pin, color: markerColor, size: 40),
      ));
    }
    setState(() {
      _markers = markers; // Actualizar la lista de marcadores
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: _currentPosition,  // Posición inicial (se actualizará en tiempo real)
        zoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.appruido',
        ),
        MarkerLayer(
          markers: _markers, // Usar los marcadores actualizados
        ),
      ],
    );
  }
}
