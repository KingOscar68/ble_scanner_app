import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ble_controller.dart';
import 'data_raw.dart'; // Nueva pantalla

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BLE Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BleController _controller = Get.put(BleController());

  @override
  void initState() {
    super.initState();
    _controller.scanAndConnect(onConnected: () {
      // Navega a la nueva página cuando se conecte al dispositivo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DataRawPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BLE Scanner")),
      body: Center(
        child: Obx(() {
          if (_controller.isConnecting.value) {
            return const CircularProgressIndicator();
          } else if (_controller.isConnected.value) {
            return const Text("¡Dispositivo conectado!");
          } else {
            return const Text("Buscando dispositivo...");
          }
        }),
      ),
    );
  }
}
