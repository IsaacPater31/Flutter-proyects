import 'package:appruido/controllers/Cops_controller.dart';
import 'package:appruido/views/Reports_view.dart';
import 'package:flutter/material.dart';
import 'package:appruido/controllers/MapStart_Controller.dart'; // Ruta del mapa
import 'package:appruido/views/Sound_view.dart'; // Vista de medición de sonido


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Ruido'), // Solo un título aquí
      ),
      body: Stack(
        children: [
          // Mapa en la parte superior de la pantalla
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.6, // 60% de la pantalla
            child: MapStartController(), // Mapa
          ),
          // Cuadro en la parte inferior con las funciones
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Columna de botones a la izquierda
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            print('Botón "Realizar Medición" presionado');
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SoundView()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(120, 50),
                            backgroundColor: Colors.green,
                          ),
                          child: Text('Realizar Medición'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            print('Botón "Ver Reportes" presionado');
                            // Navegar a la vista de reportes
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ReportsView()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(120, 50),
                          ),
                          child: Text('Ver Reportes'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16), // Espacio entre las columnas
                  // Columna de botones a la derecha
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            print('Botón "Generar Estadísticas" presionado');
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(120, 50),
                          ),
                          child: Text('Generar Estadísticas'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            print('Botón "Llamar Autoridades" presionado');
                            // Llamada a la línea de emergencia
                            CopsController.callEmergencyLine();
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(120, 50),
                            backgroundColor: Colors.red,
                          ),
                          child: Text('Llamar Autoridades'),
                        ),
                      ],
                    ),
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
                print('Botón de Notificaciones presionado');
              },
            ),
          ),
        ],
      ),
    );
  }
}
