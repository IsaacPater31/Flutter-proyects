import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';  // Para obtener la ubicación en tiempo real

class MapStartController extends StatefulWidget {
  @override
  _MapStartControllerState createState() => _MapStartControllerState();
}

class _MapStartControllerState extends State<MapStartController> {
  MapController _mapController = MapController();
  LatLng _currentPosition = LatLng(45.521563, -122.677433);  // Ubicación inicial

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();  // Llamar a la función para obtener la ubicación en tiempo real
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
      // ignore: unnecessary_null_comparison
      if (position != null) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _mapController.move(_currentPosition, 15.0);  // Mover el mapa a la ubicación actual
        });
      }
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
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: _currentPosition,
              builder: (ctx) => Icon(Icons.location_pin, color: Colors.red, size: 40),
            ),
          ],
        ),
      ],
    );
  }
}
