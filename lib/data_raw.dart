import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ble_controller.dart';

class DataRawPage extends StatelessWidget {
  const DataRawPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BleController controller = Get.find<BleController>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Datos Decodificados")),
      body: Center(
        child: Obx(() {
          final ecg1 = controller.decodedValues["ecg1"] ?? 0;
          final ecg2 = controller.decodedValues["ecg2"] ?? 0;
          final ppg = controller.decodedValues["ppg"] ?? 0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("ECG1: $ecg1", style: textTheme.bodyLarge),
              const SizedBox(height: 10),
              Text("ECG2: $ecg2", style: textTheme.bodyLarge),
              const SizedBox(height: 10),
              Text("PPG: $ppg", style: textTheme.bodyLarge),
            ],
          );
        }),
      ),
    );
  }
}
