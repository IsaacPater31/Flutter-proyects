import 'package:permission_handler/permission_handler.dart';
import 'package:noise_meter/noise_meter.dart';
import 'dart:async'; // Necesario para StreamSubscription

class SoundController {
  NoiseMeter _noiseMeter = NoiseMeter();
  bool _isRecording = false;
  late NoiseReading _noiseReading;
  late StreamSubscription _noiseSubscription; // Guardamos la suscripción

  // Verificar y solicitar permisos de micrófono
  Future<void> requestMicrophonePermission() async {
    // Verificar si ya tenemos permisos
    var status = await Permission.microphone.status;

    // Si no se tiene permiso, solicitarlo
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    // Si aún no se concede, puedes mostrar un mensaje de advertencia
    if (status.isDenied) {
      print("Permiso de micrófono denegado");
    } else if (status.isPermanentlyDenied) {
      // El usuario ha rechazado el permiso permanentemente
      print("Permiso de micrófono permanentemente denegado");
      openAppSettings(); // Opción para abrir la configuración del dispositivo
    } else {
      print("Permiso de micrófono concedido");
    }
  }

  // Iniciar la grabación y escuchar los cambios de ruido
  Future<void> startRecording(Function(NoiseReading) onNoiseUpdated) async {
    // Verificar permisos antes de comenzar a grabar
    await requestMicrophonePermission();

    // Si los permisos están concedidos, comenzamos la grabación
    if (await Permission.microphone.isGranted) {
      // Suscripción al stream de ruido
      _noiseSubscription = _noiseMeter.noise.listen((NoiseReading noiseReading) {
        onNoiseUpdated(noiseReading); // Actualiza la UI con la nueva lectura
        _noiseReading = noiseReading;
      });
      _isRecording = true;
    } else {
      print("No se tiene permiso para acceder al micrófono");
    }
  }

  // Detener la grabación
  void stopRecording() {
    _noiseSubscription.cancel(); // Cancelar la suscripción
    _isRecording = false;
  }

  // Obtener el valor del nivel de ruido promedio
  double getMeanDecibel() {
    return _noiseReading.meanDecibel; // Devuelve el nivel de ruido promedio
  }

  bool get isRecording => _isRecording;
}
