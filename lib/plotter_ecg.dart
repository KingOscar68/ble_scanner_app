import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'ble_controller.dart';

class PlotterECGPage extends StatelessWidget {
  final BleController controller = Get.find<BleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ECG Plotter'),
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
              "ECG Data Plot",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                final data = controller.ecgData;

                return LineChart(
                  LineChartData(
                    backgroundColor: Colors.black,
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.white),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.white.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toString(),
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: _getSpotsFromData(data),
                        color: Colors.blue,
                        belowBarData: BarAreaData(show: false),
                        dotData: FlDotData(
                          show: false, // Oculta los puntos, solo muestra la línea
                        ),
                        isStrokeCapRound: true, // Hace que los extremos de la línea sean redondeados
                        barWidth: 2, // Grosor de la línea
                      ),
                    ],
                    minY: -500000, // Valores mínimos ajustados para ECG
                    maxY: 500000, // Valores máximos ajustados para ECG
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Convierte la lista de datos en una lista de FlSpot para el gráfico
  List<FlSpot> _getSpotsFromData(List<int> dataList) {
    return List.generate(dataList.length, (index) {
      return FlSpot(index.toDouble(), dataList[index].toDouble());
    });
  }
}
