import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ble_controller.dart';

class DataRawPage extends StatelessWidget {
  const DataRawPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BleController controller = Get.find<BleController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Datos en tiempo real")),
      body: Center(
        child: Obx(() {
          if (controller.receivedData.isEmpty) {
            return const Text("Esperando datos...");
          } else {
            // Convierte los datos recibidos en texto legible
            String dataAsString = String.fromCharCodes(controller.receivedData);
            return Text("Datos recibidos: $dataAsString");
          }
        }),
      ),
    );
  }
}
