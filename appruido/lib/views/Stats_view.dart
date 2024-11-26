import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:appruido/controllers/Date_controller.dart';
import 'package:appruido/controllers/HourStats_controller.dart';

class StatsView extends StatefulWidget {
  @override
  _StatsViewState createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  final DateController _dateController = DateController();
  final HourStatsController _hourStatsController = HourStatsController();

  Map<String, dynamic>? _stats;
  String? _errorMessage;

  List<Map<String, dynamic>>? _hourlyStats; // Datos globales por hora
  String? _hourlyErrorMessage;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData(_selectedDate);
    _fetchHourlyStats();
  }

  /// Realiza la solicitud al controlador para las estadísticas diarias
  void _fetchData(DateTime date) async {
    setState(() {
      _stats = null;
      _errorMessage = null;
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final response = await _dateController.fetchStatsByDate(formattedDate);

    setState(() {
      if (response['status'] == 1 && response['hourly'] != null) {
        _stats = response;
      } else {
        _errorMessage = response['message'] ?? "No hay registros de ruido para la fecha seleccionada.";
      }
    });
  }

  /// Realiza la solicitud al controlador para las estadísticas globales por hora
  void _fetchHourlyStats() async {
    setState(() {
      _hourlyStats = null;
      _hourlyErrorMessage = null;
    });

    try {
      final response = await _hourStatsController.fetchHourlyStats();
      setState(() {
        _hourlyStats = response;
      });
    } catch (e) {
      setState(() {
        _hourlyErrorMessage = "Error al cargar las estadísticas por hora.";
      });
    }
  }

  /// Muestra el selector de fecha
  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _fetchData(pickedDate);
    }
  }

  /// Procesa los datos para la gráfica diaria
  List<NoiseData> _createChartData() {
    final hourlyData = _stats?['hourly'] ?? [];
    return hourlyData.map<NoiseData>((entry) {
      return NoiseData(
        entry['hora'] as String,
        entry['nivel_ruido'] as double,
      );
    }).toList();
  }

  /// Procesa los datos para la gráfica global por hora
  List<NoiseData> _createHourlyChartData() {
    final data = _hourlyStats ?? [];
    return data.map<NoiseData>((entry) {
      return NoiseData(
        entry['hora'] as String,
        entry['nivel_ruido'] as double,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas de Ruido'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selección de fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fecha seleccionada:',
                  style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(_selectedDate),
                    style: TextStyle(fontSize: screenWidth * 0.045),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.04),

            // Gráfica diaria
            Text(
              'Variación por hora:',
              style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
            ),
            Text(
              'Esta gráfica muestra los niveles de ruido promedio por hora para la fecha seleccionada.',
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
            SizedBox(height: screenWidth * 0.03),
            _stats != null
                ? SizedBox(
                    height: 300,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      title: ChartTitle(text: 'Niveles de ruido por hora'),
                      series: <ChartSeries>[
                        ColumnSeries<NoiseData, String>(
                          dataSource: _createChartData(),
                          xValueMapper: (NoiseData data, _) => data.hour,
                          yValueMapper: (NoiseData data, _) => data.level,
                          color: Colors.blue,
                        )
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.045),
                        ),
                      )
                    : Center(child: CircularProgressIndicator()),

            SizedBox(height: screenWidth * 0.06),

            // Resumen
            Text(
              'Resumen del día:',
              style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
            ),
            Text(
              'Este resumen muestra los valores promedio, mínimos y máximos de ruido registrados en la fecha seleccionada.',
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
            SizedBox(height: screenWidth * 0.03),
            _stats != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promedio de ruido: ${_stats!['summary']?['Promedio'] ?? "Sin datos"} dB',
                        style: TextStyle(fontSize: screenWidth * 0.045),
                      ),
                      Text(
                        'Nivel mínimo de ruido: ${_stats!['summary']?['Minimo'] ?? "Sin datos"} dB',
                        style: TextStyle(fontSize: screenWidth * 0.045),
                      ),
                      Text(
                        'Nivel pico de ruido: ${_stats!['summary']?['Pico'] ?? "Sin datos"} dB',
                        style: TextStyle(fontSize: screenWidth * 0.045),
                      ),
                    ],
                  )
                : Container(),

            SizedBox(height: screenWidth * 0.06),

            // Gráfica global por hora
            Text(
              'Estadísticas por hora (globales):',
              style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
            ),
            Text(
              'Esta gráfica muestra los niveles promedio de ruido por hora considerando todos los registros.',
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
            SizedBox(height: screenWidth * 0.03),
            _hourlyStats != null
                ? SizedBox(
                    height: 300,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      title: ChartTitle(text: 'Promedio global por hora'),
                      series: <ChartSeries>[
                        ColumnSeries<NoiseData, String>(
                          dataSource: _createHourlyChartData(),
                          xValueMapper: (NoiseData data, _) => data.hour,
                          yValueMapper: (NoiseData data, _) => data.level,
                          color: Colors.orange,
                        )
                      ],
                    ),
                  )
                : _hourlyErrorMessage != null
                    ? Center(
                        child: Text(
                          _hourlyErrorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.045),
                        ),
                      )
                    : Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

class NoiseData {
  final String hour;
  final double level;

  NoiseData(this.hour, this.level);
}
