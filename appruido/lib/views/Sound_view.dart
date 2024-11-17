import 'package:flutter/material.dart';
import 'package:appruido/controllers/Sound_controller.dart';

class SoundView extends StatefulWidget {
  @override
  _SoundViewState createState() => _SoundViewState();
}

class _SoundViewState extends State<SoundView> {
  final SoundController _soundController = SoundController();
  double _currentDecibel = 0.0;

  void _startMeasurement() {
    _soundController.startRecording((noiseReading) {
      setState(() {
        _currentDecibel = noiseReading.meanDecibel;
      });
    });
  }

  void _stopMeasurement() {
    _soundController.stopRecording();
  }

  void _saveReport() {
    _soundController.saveNoiseLevel(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Medición de Ruido")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nivel de Ruido Promedio: ${_currentDecibel.toStringAsFixed(2)} dB'),
            ElevatedButton(onPressed: _startMeasurement, child: Text("Iniciar Medición")),
            ElevatedButton(onPressed: _stopMeasurement, child: Text("Detener Medición")),
            ElevatedButton(onPressed: _saveReport, child: Text("Guardar Reporte")),
          ],
        ),
      ),
    );
  }
}
