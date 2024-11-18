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
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("ECG1 Real-Time Plot"),
          ),
          SizedBox(
            height: 300,
            child: Obx(() {
              return LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    verticalInterval: 500, // Intervalos en eje X
                    horizontalInterval: (1 << 21) / 5, // Intervalos en eje Y
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
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Colors.black, width: 1),
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: (1 << 21) / 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 500,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
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
              );
            }),
          ),
          const SizedBox(height: 10),
          Obx(() {
            final ecg1 = controller.decodedValues["ecg1"] ?? 0;
            return Text(
              "Muestra actual: $ecg1",
              style: Theme.of(context).textTheme.bodyLarge,
            );
          }),
        ],
      ),
    );
  }
}

