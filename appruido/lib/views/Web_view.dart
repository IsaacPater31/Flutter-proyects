import 'package:appruido/controllers/Webreports_controller.dart';
import 'package:flutter/material.dart';
import 'package:appruido/controllers/MapStart_Controller.dart';
import 'dart:async';

class WebView extends StatefulWidget {
  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final WebReportsController webReportsController = WebReportsController();
  bool isLoadingReports = true;
  String errorMessage = '';
  Timer? _refreshTimer; // Timer para la actualización en tiempo real

  @override
  void initState() {
    super.initState();
    _fetchReports(); // Cargar reportes al iniciar
    _startAutoRefresh(); // Iniciar el temporizador para la actualización automática
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Cancelar el temporizador cuando se destruya la vista
    super.dispose();
  }

  // Función para iniciar el temporizador de actualización automática
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 8), (timer) {
      _fetchReports(); // Actualiza los reportes cada 10 segundos
    });
  }

  // Función para cargar los reportes desde el controlador
  Future<void> _fetchReports() async {
    setState(() {
      isLoadingReports = true;
      errorMessage = ''; // Resetear cualquier mensaje de error anterior
    });

    await webReportsController.fetchReports(); // Usamos el controlador WebReportsController

    setState(() {
      isLoadingReports = false;
      if (webReportsController.reportData.isEmpty) {
        errorMessage = 'No se han recibido reportes.';
      } else {
        errorMessage = '';
      }
    });
  }

  // Función para asignar colores según el nivel de ruido con los rangos proporcionados
  Color getNoiseLevelColor(double nivelRuido) {
    if (nivelRuido < 65) {
      return Colors.green;  // Bajo nivel de ruido
    } else if (nivelRuido < 85) {
      return Colors.yellow; // Nivel moderado
    } else {
      return Colors.red;    // Nivel alto
    }
  }

  // Función para obtener el ícono según el nivel de ruido con los rangos proporcionados
  IconData getNoiseLevelIcon(double nivelRuido) {
    if (nivelRuido < 65) {
      return Icons.volume_up;   // Bajo volumen
    } else if (nivelRuido < 85) {
      return Icons.volume_mute; // Moderado
    } else {
      return Icons.headset_off; // Nivel alto
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa y Reportes'),
      ),
      body: Row(
        children: [
          // Panel izquierdo: Mapa
          Expanded(
            flex: 6,
            child: MapStartController(),
          ),
          // Panel derecho: Reportes
          Expanded(
            flex: 4,
            child: isLoadingReports
                ? Center(child: CircularProgressIndicator()) // Mostramos cargando
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage)) // Mensaje de error
                    : ListView.builder(
                        itemCount: webReportsController.reportData.length,
                        itemBuilder: (context, index) {
                          var report = webReportsController.reportData[index];
                          double nivelRuido =
                              double.tryParse(report['Nivel_Ruido'].toString()) ?? 0.0;

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            child: ListTile(
                              leading: Icon(
                                getNoiseLevelIcon(nivelRuido), // Mostrar ícono según el nivel
                                color: getNoiseLevelColor(nivelRuido), // Color del ícono
                              ),
                              title: Text(
                                'Nivel de Ruido: ${nivelRuido.toStringAsFixed(1)} dB',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                'Fecha: ${report['Fecha']} - Hora: ${report['Hora']}',
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              trailing: Icon(Icons.location_on),
                              onTap: () {
                                print('Detalles del reporte: ${report['Id_Medida']}');
                              },
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
