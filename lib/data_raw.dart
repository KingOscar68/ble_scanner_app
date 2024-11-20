import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'ble_controller.dart';

class DataRawPage extends StatelessWidget {
  const DataRawPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Raw")),
      body: GetBuilder<BleController>(
        builder: (controller) {
          if (controller.services.isEmpty) {
            return const Center(
              child: Text(
                "Esperando conexión...",
                style: TextStyle(fontSize: 24),
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.services.length,
            itemBuilder: (context, index) {
              final service = controller.services[index];
              return Card(
                elevation: 2,
                child: ListTile(
                  title: Text("Servicio: ${service.uuid}"),
                  onTap: () {
                    // Aquí puedes agregar lo que necesites hacer al tocar un servicio
                    print("Conectado al servicio: ${service.uuid}");
                    // Si deseas interactuar con los característicos del servicio, puedes hacerlo aquí
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
