import 'package:flutter/material.dart';
import 'package:appruido/controllers/MapStart_Controller.dart'; // Asegúrate de que la ruta esté bien
import 'package:appruido/views/Sound_view.dart'; // Importa la vista de medición de sonido

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
                  // Botón para realizar medición
                  ElevatedButton(
                    onPressed: () {
                      // Navegar a la vista de medición de ruido
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SoundView()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50), backgroundColor: Colors.green, // Color del botón
                    ),
                    child: Text('Realizar Medición', style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(height: 20),
                  // Botón para ver reportes
                  ElevatedButton(
                    onPressed: () {
                      // Lógica para ver reportes
                      print('Ver reportes');
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50), // Tamaño personalizado
                    ),
                    child: Text('Ver Reportes'),
                  ),
                  SizedBox(height: 20),
                  // Botón para generar estadísticas
                  ElevatedButton(
                    onPressed: () {
                      // Lógica para generar estadísticas
                      print('Generar Estadísticas');
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50), // Tamaño personalizado
                    ),
                    child: Text('Generar Estadísticas'),
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
