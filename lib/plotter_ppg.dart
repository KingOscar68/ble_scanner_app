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
                final data = controller.secondCharacteristicData;
                final double maxY = data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) + 100 : 100;
                final double minY = data.isNotEmpty ? data.reduce((a, b) => a < b ? a : b) - 100 : -100;

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
                        color: Colors.red,
                        belowBarData: BarAreaData(show: false),
                        dotData: FlDotData(
                          show: false, // Oculta los puntos, solo muestra la línea
                        ),
                        isStrokeCapRound: true, // Hace que los extremos de la línea sean redondeados
                        barWidth: 2, // Grosor de la línea
                      ),
                    ],
                    minY: minY-200,  // Ajuste del mínimo valor del eje Y
                    maxY: maxY+200,  // Ajuste del máximo valor del eje Y
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
  List<FlSpot> _getSpotsFromData(List<double> dataList) {
    return List.generate(dataList.length, (index) {
      return FlSpot(index.toDouble(), dataList[index]);
    });
  }
}

