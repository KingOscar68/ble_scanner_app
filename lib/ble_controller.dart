import 'package:ble_scanner_app/device_details_page.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  FlutterBlue ble = FlutterBlue.instance;

  // Listas para almacenar los últimos 50 valores de las características
  RxList<double> firstCharacteristicData = List.filled(200, 0.0).obs;
  RxList<double> secondCharacteristicData = List.filled(200, 0.0).obs;

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

            await firstCharacteristic.setNotifyValue(true);
            firstCharacteristic.value.listen((value) {
              double intValue = _convertBytesToDouble(value);
              _updateDataList(firstCharacteristicData, intValue);
            });

            // Procesar la segunda característica
            final secondCharacteristic = service.characteristics.firstWhere(
                  (c) => c.uuid == Guid('87654321-1234-5678-1234-567812345678'),
            );

            await secondCharacteristic.setNotifyValue(true);
            secondCharacteristic.value.listen((value) {
              double intValue = _convertBytesToDouble(value);
              _updateDataList(secondCharacteristicData, intValue);
            });
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

  // Método para actualizar las listas con los últimos 50 valores
  void _updateDataList(RxList<double> dataList, double newValue) {
    dataList.removeAt(0); // Elimina el primer elemento (más antiguo)
    dataList.add(newValue); // Agrega el nuevo valor al final de la lista
  }

  // Conversión de bytes a doble (int de 16 bits a double)
  double _convertBytesToDouble(List<int> bytes) {
    if (bytes.length >= 2) {
      int intValue = (bytes[0] << 8) | bytes[1];
      // Si el valor es negativo, ajustamos manualmente
      if (intValue & 0x8000 != 0) {
        intValue = intValue - 0x10000;
      }
      return intValue.toDouble();
    }
    return 0.0;
  }


  Stream<List<ScanResult>> get scanResults => ble.scanResults;
}
