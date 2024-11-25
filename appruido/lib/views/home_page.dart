import 'package:appruido/controllers/Cops_controller.dart';
import 'package:appruido/views/Reports_view.dart';
import 'package:flutter/material.dart';
import 'package:appruido/controllers/MapStart_Controller.dart'; // Controlador del mapa
import 'package:appruido/views/Sound_view.dart'; // Vista de medición de sonido

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mapa de Ruido',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
        ), // Título más pequeño
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Color del encabezado
      ),
      body: Stack(
        children: [
          // Mapa en la parte superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.7, // Ocupa el 70% del alto
            child: MapStartController(),
          ),
          // Cuadro en la parte inferior con las funciones
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.3, // Ocupa el 30% del alto
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500), // Animación suave
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey.shade200],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
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
                        FilledButton.icon(
                          onPressed: () {
                            print('Botón "Realizar Medición" presionado');
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SoundView()),
                            );
                          },
                          icon: Icon(Icons.mic, color: Colors.white),
                          label: Text(
                            'Realizar Medición',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: Size(140, 50),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            print('Botón "Ver Reportes" presionado');
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ReportsView()),
                            );
                          },
                          icon: Icon(Icons.list_alt, color: Colors.white),
                          label: Text(
                            'Ver mis Reportes',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            minimumSize: Size(140, 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  // Columna de botones a la derecha
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            print('Botón "Generar Estadísticas" presionado');
                          },
                          icon: Icon(Icons.bar_chart, color: Colors.white),
                          label: Text(
                            'Generar Estadísticas',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: Size(140, 50),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            print('Botón "Llamar Autoridades" presionado');
                            CopsController.callEmergencyLine();
                          },
                          icon: Icon(Icons.phone, color: Colors.white),
                          label: Text(
                            'Llamar Autoridades',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: Size(140, 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
