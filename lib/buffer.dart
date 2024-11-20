import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'ble_controller.dart';

class BufferPage extends StatelessWidget {
  const BufferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buffer de Datos")),
      body: GetBuilder<BleController>(
        builder: (controller) {
          return ListView.builder(
            itemCount: controller.characteristicsData.length,
            itemBuilder: (context, index) {
              // Obtén el stream de cada característica
              String characteristicUuid = controller.characteristicsData.keys.elementAt(index);
              Stream<List<int>> characteristicStream = controller.characteristicsData[characteristicUuid]!;

              return Card(
                elevation: 2,
                child: ListTile(
                  title: Text("Característica: $characteristicUuid"),
                  subtitle: StreamBuilder<List<int>>(
                    stream: characteristicStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          // Muestra el buffer de 20 bytes como un texto
                          return Text("Buffer: ${snapshot.data!.join(", ")}");
                        } else {
                          return const Text("Esperando datos...");
                        }
                      } else {
                        return const Text("No conectado");
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
