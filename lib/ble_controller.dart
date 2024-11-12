import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'dart:convert'; // Para procesar los valores recibidos

class BleController extends GetxController {
  FlutterBlue ble = FlutterBlue.instance;

  final String targetServiceUuid = "12345678-1234-5678-1234-567812345678";
  final String targetCharacteristicUuid = "98679657-1234-5678-1234-567812345678";

  RxBool isConnecting = true.obs;
  RxBool isConnected = false.obs;
  RxList<int> receivedData = <int>[].obs; // Almacena los valores recibidos

  BluetoothCharacteristic? targetCharacteristic;

  // Escanea dispositivos y conecta automáticamente
  Future<void> scanAndConnect({required Function onConnected}) async {
    try {
      ble.startScan(timeout: const Duration(seconds: 15));

      ble.scanResults.listen((results) async {
        for (ScanResult result in results) {
          final device = result.device;

          // Intenta conectarse al primer dispositivo encontrado
          try {
            await device.connect();
            ble.stopScan();

            // Explora servicios para encontrar el objetivo
            List<BluetoothService> services = await device.discoverServices();
            for (BluetoothService service in services) {
              if (service.uuid.toString().toLowerCase() == targetServiceUuid.toLowerCase()) {
                for (BluetoothCharacteristic characteristic in service.characteristics) {
                  if (characteristic.uuid.toString().toLowerCase() ==
                      targetCharacteristicUuid.toLowerCase()) {
                    targetCharacteristic = characteristic;
                    isConnected.value = true;
                    isConnecting.value = false;

                    // Escucha valores de la característica
                    targetCharacteristic?.setNotifyValue(true);
                    targetCharacteristic?.value.listen((value) {
                      receivedData.value = value; // Actualiza los datos recibidos
                    });

                    // Llama al callback para navegar
                    onConnected();
                    return;
                  }
                }
              }
            }
          } catch (e) {
            print("Error al conectar con el dispositivo: $e");
          }
        }
      });
    } catch (e) {
      print("Error durante el escaneo: $e");
      isConnecting.value = false;
    }
  }
}
