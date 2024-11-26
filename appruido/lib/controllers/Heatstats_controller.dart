import 'dart:convert';
import 'package:http/http.dart' as http;

class HeatMapController {
  final String apiUrl = 'http://192.168.1.13/apis/Api_Heatmap.php';

  /// Obtiene los datos del mapa de calor por día y opcionalmente por hora
  Future<List<Map<String, dynamic>>> fetchHeatMapData(String fecha, {int? hora}) async {
    print('Iniciando solicitud para el mapa de calor: Fecha: $fecha, Hora: ${hora ?? "Todo el día"}');

    try {
      // Crear el cuerpo de la solicitud POST
      final body = hora != null
          ? jsonEncode({'fecha': fecha, 'hora': hora.toString()})
          : jsonEncode({'fecha': fecha});

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Respuesta recibida con código: ${response.statusCode}');
      print('Contenido de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 1 && responseData['data'] != null) {
          print('Datos procesados correctamente.');
          return _processHeatMapData(responseData['data']);
        } else {
          print('Error en los datos recibidos: ${responseData['message']}');
          return _generateEmptyHeatMapData();
        }
      } else {
        print('Error en el servidor: Código ${response.statusCode}');
        throw Exception('Error en el servidor. Código: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción durante la solicitud: $e');
      throw Exception('Error al realizar la solicitud: $e');
    }
  }

  /// Procesa los datos del mapa de calor, asignando 0 a horas sin registros
  List<Map<String, dynamic>> _processHeatMapData(List<dynamic> data) {
    print('Procesando datos del mapa de calor: $data');

    // Generar datos completos (0 para áreas no reportadas)
    final List<Map<String, dynamic>> completeData = [];

    for (var entry in data) {
      completeData.add({
        'lat': entry['lat'],
        'lng': entry['lng'],
        'nivelRuido': entry['nivelRuido'] ?? 0, // Asigna 0 si el nivel de ruido es nulo
      });
      print('Punto procesado: Lat: ${entry['lat']}, Lng: ${entry['lng']}, Ruido: ${entry['nivelRuido'] ?? 0}');
    }

    return completeData;
  }

  /// Genera un conjunto vacío de datos para el mapa de calor
  List<Map<String, dynamic>> _generateEmptyHeatMapData() {
    print('Generando datos vacíos para el mapa de calor.');
    return [];
  }
}
