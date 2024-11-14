import 'package:flutter/material.dart';
import 'package:appruido/controllers/Sound_controller.dart'; // Importa tu controlador de sonido

class SoundView extends StatefulWidget {
  @override
  _SoundViewState createState() => _SoundViewState();
}

class _SoundViewState extends State<SoundView> {
  SoundController _soundController = SoundController();
  double _currentDecibel = 0.0;

  // Iniciar medición de ruido
  void _startMeasurement() {
    _soundController.startRecording((noiseReading) {
      setState(() {
        _currentDecibel = noiseReading.meanDecibel;
      });
    });
  }

  // Detener medición de ruido
  void _stopMeasurement() {
    _soundController.stopRecording();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medición de Ruido"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar el nivel de ruido actual
            Text(
              'Nivel de Ruido Promedio: ${_currentDecibel.toStringAsFixed(2)} dB',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            // Botón para iniciar la medición de ruido
            ElevatedButton(
              onPressed: _startMeasurement,
              child: Text('Iniciar Medición'),
            ),
            SizedBox(height: 20),
            // Botón para detener la medición de ruido
            ElevatedButton(
              onPressed: _stopMeasurement,
              child: Text('Detener Medición'),
            ),
          ],
        ),
      ),
    );
  }
}
