import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'ble_controller.dart';
import 'plotter_ecg.dart';
import 'plotter_ppg.dart';

class DeviceDetailsPage extends StatelessWidget {
  final BluetoothDevice device;
  final int rssi;
  final BleController controller = Get.find<BleController>();

  DeviceDetailsPage({required this.device, required this.rssi, required List<BluetoothService> services});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
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
              "Device ID: ${device.id.id}",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "RSSI: $rssi",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "Status:",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Obx(() {
              if (controller.firstCharacteristicValue.value != 0 && controller.secondCharacteristicValue.value != 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Connected",
                      style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "ECG: ${controller.firstCharacteristicValue.value}",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "PPG: ${controller.secondCharacteristicValue.value}",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                );
              } else {
                return Text(
                  "Waiting for connection...",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                );
              }
            }),
            Spacer(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => PlotterECGPage());  // Navega a la página ECG
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: Text("ECG Plotter"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => PlotterPPGPage());  // Navega a la página PPG
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text("PPG Plotter"),
                  ),
                ],
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
