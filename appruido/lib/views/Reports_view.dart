import 'package:appruido/controllers/Reports_controller.dart';
import 'package:flutter/material.dart';


class ReportsView extends StatefulWidget {
  @override
  _ReportsViewState createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  bool isLoading = true;
  final ReportsController reportsController = ReportsController();

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  void fetchReports() async {
    await reportsController.fetchReports();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes de Ruido'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : reportsController.reportData.isEmpty
              ? Center(child: Text('No se encontraron reportes'))
              : ListView.builder(
                  itemCount: reportsController.reportData.length,
                  itemBuilder: (context, index) {
                    var report = reportsController.reportData[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: ListTile(
                        title: Text('Nivel de Ruido: ${report['Nivel_Ruido']} dB'),
                        subtitle: Text('Fecha: ${report['Fecha']} - Hora: ${report['Hora']}'),
                        trailing: Icon(Icons.location_on),
                        onTap: () {
                          print('Detalles del reporte: ${report['Id_Medida']}');
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
