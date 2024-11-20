import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  FlutterBlue ble = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];
  Map<String, Stream<List<int>>> characteristicsData = {}; // Para almacenar los streams de cada característica

  // Esta función conecta al dispositivo y descubre sus servicios
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(timeout: Duration(seconds: 15));

    // Al conectarse, obtenemos los servicios disponibles
    List<BluetoothService> discoveredServices = await device.discoverServices();

    // Guardamos los servicios descubiertos en la lista
    services = discoveredServices;

    // Suscribirnos a las características del servicio
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.notify) {
          await characteristic.setNotifyValue(true); // Habilitar notificaciones para esta característica
          // Guardamos el stream de datos de cada característica
          characteristicsData[characteristic.uuid.toString()] = characteristic.value;
        }
      }
    }

    update();
  }

  // Esta función escanea los dispositivos disponibles
  Future scanDevices() async {
    if (await Permission.bluetoothScan.request().isGranted) {
      if (await Permission.bluetoothConnect.request().isGranted) {
        ble.startScan(timeout: Duration(seconds: 15));

        // Stop scanning after timeout
        ble.stopScan();
      }
    }
  }

  Stream<List<ScanResult>> get scanResults => ble.scanResults;
}
