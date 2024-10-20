import 'package:appruido/controllers/login_controller.dart';
import 'package:appruido/views/home_page.dart';
import 'package:flutter/material.dart';
import 'signup_page.dart'; // Asegúrate de importar el controlador

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginController loginController = LoginController();
  bool isLoading = false; // Estado para mostrar el indicador de carga

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
              onPressed: isLoading
                  ? null // Deshabilitar el botón mientras se carga
                  : () async {
                      setState(() {
                        isLoading = true; // Iniciar la carga
                      });

                      // Lógica para iniciar sesión
                      int result = await loginController.login(
                        user: emailController.text,
                        password: passwordController.text,
                      );

                      setState(() {
                        isLoading = false; // Finalizar la carga
                      });

                      if (result == 1) {
                        // Redirigir a la página de inicio
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      } else {
                        // Mostrar un mensaje de error
                        String errorMessage;
                        if (result == 0) {
                          errorMessage = 'Credenciales inválidas.';
                        } else if (result == -1) {
                          errorMessage = 'Error en la conexión. Intente nuevamente.';
                        } else {
                          errorMessage = 'Error al iniciar sesión. Intente nuevamente más tarde.';
                        }

                        print('Resultado de inicio de sesión: $result'); // Para depuración

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
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white) // Mostrar indicador de carga
                  : Text('Iniciar Sesión'),
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
