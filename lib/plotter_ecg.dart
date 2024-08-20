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
                        spots: _createSpots(controller.firstCharacteristicValue.value),
                        color: Colors.blue,
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

  List<FlSpot> _createSpots(int value) {
    List<FlSpot> spots = [];
    for (int i = 0; i < 100; i++) {
      spots.add(FlSpot(i.toDouble(), value.toDouble()));
    }
    return spots;
  }
}
