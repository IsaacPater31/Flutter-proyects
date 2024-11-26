import 'dart:convert';
import 'package:http/http.dart' as http;

class HeatMapController {
  final String apiUrl = 'http://192.168.1.13/apis/Api_Heatmap.php';

  /// Tamaño de la celda para calcular áreas
  final double gridSize = 0.02; // Grados, ajustable según necesidad

  /// Obtiene los datos del mapa de calor desde el API y calcula intensidades por área
  Future<List<Map<String, dynamic>>> fetchHeatMapData(String fecha, {int? hora}) async {
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

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 1 && responseData['data'] != null) {
          // Procesar y agrupar datos por áreas
          return _processHeatMapData(responseData['data']);
        } else {
          print('No se encontraron datos: ${responseData['message']}');
          return [];
        }
      } else {
        throw Exception('Error en el servidor: Código ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener datos del API: $e');
      throw Exception('Error al obtener datos del mapa de calor');
    }
  }

  /// Agrupa los puntos en áreas y calcula intensidades promedio
  List<Map<String, dynamic>> _processHeatMapData(List<dynamic> data) {
    final Map<String, List<Map<String, double>>> groupedAreas = {};

    for (var entry in data) {
      final double lat = entry['lat'];
      final double lng = entry['lng'];
      final double nivelRuido = entry['nivelRuido'];

      // Calcula índices de la celda
      final int gridLat = (lat / gridSize).floor();
      final int gridLng = (lng / gridSize).floor();
      final String cellKey = '$gridLat:$gridLng';

      // Agrupa puntos en la celda
      if (!groupedAreas.containsKey(cellKey)) {
        groupedAreas[cellKey] = [];
      }
      groupedAreas[cellKey]!.add({'lat': lat, 'lng': lng, 'nivelRuido': nivelRuido});
    }

    // Calcular promedios por celda y crear áreas
    final List<Map<String, dynamic>> areas = [];
    groupedAreas.forEach((cellKey, puntos) {
      // Calcular promedio de latitud, longitud y nivel de ruido
      double sumLat = 0;
      double sumLng = 0;
      double sumRuido = 0;

      for (var punto in puntos) {
        sumLat += punto['lat']!;
        sumLng += punto['lng']!;
        sumRuido += punto['nivelRuido']!;
      }

      final int totalPuntos = puntos.length;
      final double promedioLat = sumLat / totalPuntos;
      final double promedioLng = sumLng / totalPuntos;
      final double promedioRuido = sumRuido / totalPuntos;

      areas.add({
        'lat': promedioLat,
        'lng': promedioLng,
        'nivelRuido': promedioRuido,
      });
    });

    return areas;
  }
}
