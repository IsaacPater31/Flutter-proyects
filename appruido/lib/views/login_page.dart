import 'package:appruido/controllers/login_controller.dart';
import 'package:appruido/views/home_page.dart';
import 'package:flutter/material.dart';
import 'signup_page.dart'; // Asegúrate de importar el controlador

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginController loginController = LoginController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'User',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Lógica para iniciar sesión
                int result = await loginController.login(
                  user: emailController.text,
                  password: passwordController.text,
                );

                if (result == 1) {
                  // Redirigir a la página de inicio
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()), // Reemplaza esto con tu página de inicio
                  );
                } else {
                  // Mostrar un mensaje de error
                  String errorMessage;
                  if (result == 0) {
                    errorMessage = 'Credenciales inválidas.';
                  } else {
                    errorMessage = 'Error al iniciar sesión. Intente nuevamente más tarde.';
                  }

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text(errorMessage),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cerrar'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Iniciar Sesión'),
            ),
            TextButton(
              onPressed: () {
                // Redirigir a la pantalla de registro
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text('No tienes una cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
