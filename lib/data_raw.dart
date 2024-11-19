import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ble_controller.dart';

class DataRawPage extends StatelessWidget {
  const DataRawPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BleController controller = Get.find<BleController>();

    return Scaffold(
      appBar: AppBar(title: const Text("ECG1 Plotter")),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "ECG1 Real-Time Plot",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Obx(() {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2), // Recuadro alrededor de la gráfica
                          borderRadius: BorderRadius.circular(8), // Bordes redondeados opcionales
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                verticalInterval: 500,
                                horizontalInterval: (1 << 21) / 5,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.grey.shade400,
                                  strokeWidth: 0.8,
                                ),
                                getDrawingVerticalLine: (value) => FlLine(
                                  color: Colors.grey.shade400,
                                  strokeWidth: 0.8,
                                ),
                              ),
                              borderData: FlBorderData(
                                show: false, // Oculta las líneas de los bordes
                              ),
                              titlesData: FlTitlesData(
                                show: false, // Oculta las etiquetas de los ejes
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(
                                    controller.ecg1Data.length,
                                        (i) => FlSpot(i.toDouble(), controller.ecg1Data[i].toDouble()),
                                  ),
                                  isCurved: true,
                                  color: Colors.blue,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                              minY: -(1 << 21).toDouble(),
                              maxY: (1 << 21).toDouble(),
                              minX: 0,
                              maxX: controller.ecg1Data.length.toDouble(),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  final ecg1 = controller.decodedValues["ecg1"] ?? 0;
                  return Text(
                    "Muestra actual: $ecg1",
                    style: Theme.of(context).textTheme.bodyLarge,
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
