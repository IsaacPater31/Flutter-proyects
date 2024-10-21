import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapStartController extends StatefulWidget {
  @override
  _MapStartControllerState createState() => _MapStartControllerState();
}

class _MapStartControllerState extends State<MapStartController> {
  GoogleMapController? _mapController;
  LatLng _initialPosition = LatLng(0, 0); // Posición inicial del mapa

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Ruido'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              _mapController!.animateCamera(CameraUpdate.newLatLng(_initialPosition));
            },
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            myLocationEnabled: true,
          ),
          // Cuadro en la parte inferior con el botón para obtener la ubicación
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.4 + 20, // Ajusta la posición del botón
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                // Aquí conectar la lógica para obtener la ubicación actual
                print('Conectar lógica para obtener ubicación actual');
              },
              child: Text('Obtener Ubicación Actual'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15), // Ajuste de padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Bordes redondeados
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
