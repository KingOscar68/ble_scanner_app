import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'ble_controller.dart';

class PlotterPPGPage extends StatelessWidget {
  final BleController controller = Get.find<BleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PPG Plotter'),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[850],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PPG Data Plot",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                return LineChart(
                  LineChartData(
                    backgroundColor: Colors.black,
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.white),
                    ),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: _createSpots(controller.secondCharacteristicValue.value),
                        color: Colors.red,
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Crea puntos para el gráfico basado en los valores recibidos
  List<FlSpot> _createSpots(int value) {
    // Esta es una implementación simple. Puedes expandirla para manejar un buffer de datos
    // o una lista de valores en lugar de un solo valor.
    List<FlSpot> spots = [];
    for (int i = 0; i < 100; i++) {
      spots.add(FlSpot(i.toDouble(), value.toDouble()));
    }
    return spots;
  }
}
