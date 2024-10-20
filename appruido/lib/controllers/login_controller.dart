import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginController {
  final String apiUrl = 'http://192.168.1.12/apis/Api_Login.php'; // Asegúrate de usar la URL correcta

  Future<int> login({required String user, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'User': user,
          'Password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Verificar que la respuesta sea un objeto y contenga 'status'
        if (responseData is Map<String, dynamic> && responseData.containsKey('status')) {
          return responseData['status']; // Devuelve el estado directamente
        }
      } else {
        print('Error en la respuesta del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e'); // Manejo de excepciones
    }

    return -1; // Error en el inicio de sesión
  }
}
