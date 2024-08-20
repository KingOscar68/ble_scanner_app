import 'package:ble_scanner_app/device_details_page.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';

class BleController extends GetxController {
  FlutterBlue ble = FlutterBlue.instance;

  // Estos almacenarán los valores recibidos de las características como enteros de 16 bits.
  RxInt firstCharacteristicValue = 0.obs;
  RxInt secondCharacteristicValue = 0.obs;


  // Método para escanear dispositivos cercanos
  Future scanDevices() async {
    if (await Permission.bluetoothScan.request().isGranted) {
      if (await Permission.bluetoothConnect.request().isGranted) {
        ble.startScan(timeout: Duration(seconds: 15));
        ble.stopScan();
      }
    }
  }

  // Método para conectar al dispositivo BLE, descubrir servicios, y leer características
  Future<void> connectToDevice(BluetoothDevice device, int rssi) async {
    await device.connect(timeout: Duration(seconds: 15));

    device.state.listen((isConnected) async {
      if (isConnected == BluetoothDeviceState.connecting) {
        print("Device connecting to: ${device.name}");
      } else if (isConnected == BluetoothDeviceState.connected) {
        print("Device connected: ${device.name}");

        // Descubrir servicios
        List<BluetoothService> services = await device.discoverServices();

        // Encuentra el servicio específico y suscribe a las características
        services.forEach((service) async {
          if (service.uuid == Guid('12345678-1234-5678-1234-567812345678')) {

            // Procesar la primera característica
            final firstCharacteristic = service.characteristics.firstWhere(
                  (c) => c.uuid == Guid('98679657-1234-5678-1234-567812345678'),
            );

            if (firstCharacteristic != null) {
              await firstCharacteristic.setNotifyValue(true);
              firstCharacteristic.value.listen((value) {
                int intValue = _convertBytesToInt(value);
                print("First Characteristic Value: $intValue");
                firstCharacteristicValue.value = intValue;
              });
            } else {
              print("First characteristic not found.");
            }

            // Procesar la segunda característica
            final secondCharacteristic = service.characteristics.firstWhere(
                  (c) => c.uuid == Guid('87654321-1234-5678-1234-567812345678'),
            );

            if (secondCharacteristic != null) {
              await secondCharacteristic.setNotifyValue(true);
              secondCharacteristic.value.listen((value) {
                int intValue = _convertBytesToInt(value);
                print("Second Characteristic Value: $intValue");
                secondCharacteristicValue.value = intValue;
              });
            } else {
              print("Second characteristic not found.");
            }
          }
        });

        // Navegar a la página de detalles del dispositivo
        Get.to(() => DeviceDetailsPage(device: device, rssi: rssi, services: services));

        print("Pasando a la siguiente pagina");
      } else {
        print("Device Disconnected");
      }
    });
  }

  // Conversión de bytes a entero de 16 bits
  int _convertBytesToInt(List<int> bytes) {
    // Asegúrate de que `bytes` tenga al menos 2 elementos.
    if (bytes.length >= 2) {
      ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
      return byteData.getInt16(0, Endian.little); // Usa Endian.big si el orden de bytes es diferente
    }
    return 0;
  }

  Stream<List<ScanResult>> get scanResults => ble.scanResults;
}
