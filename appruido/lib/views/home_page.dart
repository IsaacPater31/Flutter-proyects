import 'package:flutter/material.dart';
import 'package:appruido/controllers/MapStart_Controller.dart'; // Asegúrate de que la ruta esté bien

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medición de Ruido'),
      ),
      body: Stack(
        children: [
          // Mapa en la parte superior de la pantalla
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.6, // 60% de la pantalla
            child: MapStartController(), // Llama al widget del mapa
          ),
          // Cuadro en la parte inferior con las funciones de medición
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.4, // 40% de la pantalla
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribuir espacio entre los widgets
                children: [
                  // Botón circular para el micrófono
                  GestureDetector(
                    onTap: () {
                      // Lógica para iniciar la medición de ruido
                      print('Iniciar medición de ruido');
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.mic, color: Colors.white, size: 36),
                    ),
                  ),
                  Text('Presiona para medir el nivel de ruido'),
                  SizedBox(height: 20),
                  // Botón para ver reportes
                  ElevatedButton(
                    onPressed: () {
                      // Lógica para ver reportes
                      print('Ver reportes');
                    },
                    child: Text('Ver Reportes'),
                  ),
                ],
              ),
            ),
          ),
          // Botón para notificaciones en la esquina superior derecha
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // Lógica para las notificaciones
                print('Notificaciones');
              },
            ),
          ),
        ],
      ),
    );
  }
}
