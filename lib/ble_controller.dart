import 'dart:typed_data';
import 'dart:math'; // Importamos math para funciones matemáticas

import 'package:ble_scanner_app/device_details_page.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

// Agregar librería para procesamiento de señales
// Puedes agregar paquetes de procesamiento de señales si es necesario

class BleController extends GetxController {
  FlutterBlue ble = FlutterBlue.instance;

  // Listas para almacenar los últimos 200 valores de las señales filtradas
  RxList<double> firstCharacteristicData = List.filled(200, 0.0).obs; // ECG
  RxList<double> secondCharacteristicData = List.filled(200, 0.0).obs; // PPG

  // Listas para almacenar los datos crudos recibidos
  List<double> ecgRawData = [];
  List<double> ppgRawData = [];

  // Parámetros del filtro
  final int fs = 360; // Frecuencia de muestreo (ajusta según tus datos)
  final int filterOrder = 5; // Orden del filtro

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
            // Procesar la primera característica (ECG)
            final firstCharacteristic = service.characteristics.firstWhere(
                  (c) => c.uuid == Guid('98679657-1234-5678-1234-567812345678'),
            );

            if (firstCharacteristic != null) {
              await firstCharacteristic.setNotifyValue(true);
              firstCharacteristic.value.listen((value) {
                double intValue = _convertBytesToDouble(value);
                ecgRawData.add(intValue);

                // Aplicar filtrado cuando haya suficientes datos
                if (ecgRawData.length >= 200) {
                  List<double> filteredData = _applyFilters(ecgRawData);

                  // Actualizar la lista observable con los datos filtrados
                  firstCharacteristicData.value = filteredData;

                  // Limpiar los datos crudos para evitar crecimiento infinito
                  ecgRawData.clear();
                }
              });
            } else {
              print("First characteristic not found.");
            }

            // Procesar la segunda característica (PPG)
            final secondCharacteristic = service.characteristics.firstWhere(
                  (c) => c.uuid == Guid('87654321-1234-5678-1234-567812345678'),
            );

            if (secondCharacteristic != null) {
              await secondCharacteristic.setNotifyValue(true);
              secondCharacteristic.value.listen((value) {
                double intValue = _convertBytesToDouble(value);
                ppgRawData.add(intValue);

                // Aplicar filtrado cuando haya suficientes datos
                if (ppgRawData.length >= 200) {
                  List<double> filteredData = _applyFilters(ppgRawData);

                  // Actualizar la lista observable con los datos filtrados
                  secondCharacteristicData.value = filteredData;

                  // Limpiar los datos crudos para evitar crecimiento infinito
                  ppgRawData.clear();
                }
              });
            } else {
              print("Second characteristic not found.");
            }
          }
        });

        // Navegar a la página de detalles del dispositivo
        Get.to(() => DeviceDetailsPage(device: device, rssi: rssi, services: services));

        print("Pasando a la siguiente página");
      } else {
        print("Device Disconnected");
      }
    });
  }

  // Método para aplicar los filtros a los datos crudos
  List<double> _applyFilters(List<double> rawData) {
    // Paso 1: Normalización Z-score
    List<double> normalizedData = _zScoreNormalize(rawData);

    // Paso 2: Filtrado
    List<double> filteredData = normalizedData;

    // Aplicar filtro pasa bajos
    filteredData = _lowPassFilter(filteredData, cutoffFreq: 100.0);

    // Aplicar filtro pasa altos
    filteredData = _highPassFilter(filteredData, cutoffFreq: 0.5);

    // Aplicar filtro Notch (si es necesario)
    filteredData = _notchFilter(filteredData, notchFreq: 50.0);

    // Puedes agregar más filtros o procesamiento según sea necesario

    // Solo devolvemos los últimos 200 valores para mantener el tamaño consistente
    return filteredData.sublist(filteredData.length - 200);
  }

  // Normalización Z-score
  List<double> _zScoreNormalize(List<double> data) {
    double mean = data.reduce((a, b) => a + b) / data.length;
    double sumSquared = data.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b);
    double stdDev = sqrt(sumSquared / data.length);

    return data.map((x) => (x - mean) / stdDev).toList();
  }

  // Implementación de filtro pasa bajos (Butterworth)
  List<double> _lowPassFilter(List<double> data, {double cutoffFreq = 100.0}) {
    // Implementa aquí tu filtro pasa bajos
    // Como Dart no tiene funciones nativas de filtrado, podemos usar un filtro sencillo
    List<double> filteredData = List<double>.filled(data.length, 0.0);

    double RC = 1.0 / (2 * pi * cutoffFreq);
    double dt = 1.0 / fs;
    double alpha = dt / (RC + dt);

    filteredData[0] = data[0]; // Inicializa el primer valor

    for (int i = 1; i < data.length; i++) {
      filteredData[i] = filteredData[i - 1] + alpha * (data[i] - filteredData[i - 1]);
    }

    return filteredData;
  }

  // Implementación de filtro pasa altos (Butterworth)
  List<double> _highPassFilter(List<double> data, {double cutoffFreq = 0.5}) {
    // Implementa aquí tu filtro pasa altos
    List<double> filteredData = List<double>.filled(data.length, 0.0);

    double RC = 1.0 / (2 * pi * cutoffFreq);
    double dt = 1.0 / fs;
    double alpha = RC / (RC + dt);

    filteredData[0] = data[0]; // Inicializa el primer valor

    for (int i = 1; i < data.length; i++) {
      filteredData[i] = alpha * (filteredData[i - 1] + data[i] - data[i - 1]);
    }

    return filteredData;
  }

  // Implementación de filtro Notch para eliminar interferencia de 50/60 Hz
  List<double> _notchFilter(List<double> data, {double notchFreq = 50.0, double Q = 30.0}) {
    // Implementa aquí tu filtro Notch
    List<double> filteredData = List<double>.filled(data.length, 0.0);

    double dt = 1.0 / fs;
    double w0 = 2 * pi * notchFreq * dt;
    double cos_w0 = cos(w0);
    double sin_w0 = sin(w0);
    double alpha = sin_w0 / (2 * Q);

    double b0 = 1;
    double b1 = -2 * cos_w0;
    double b2 = 1;
    double a0 = 1 + alpha;
    double a1 = -2 * cos_w0;
    double a2 = 1 - alpha;

    // Normalizar coeficientes
    b0 /= a0;
    b1 /= a0;
    b2 /= a0;
    a1 /= a0;
    a2 /= a0;

    // Inicializar variables
    double x_n1 = 0.0, x_n2 = 0.0;
    double y_n1 = 0.0, y_n2 = 0.0;

    for (int i = 0; i < data.length; i++) {
      double x_n = data[i];
      double y_n = b0 * x_n + b1 * x_n1 + b2 * x_n2 - a1 * y_n1 - a2 * y_n2;

      filteredData[i] = y_n;

      // Actualizar variables
      x_n2 = x_n1;
      x_n1 = x_n;
      y_n2 = y_n1;
      y_n1 = y_n;
    }

    return filteredData;
  }

  // Conversión de bytes a doble (int de 16 bits a double)
  double _convertBytesToDouble(List<int> bytes) {
    if (bytes.length >= 2) {
      ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
      return byteData.getInt16(0, Endian.little).toDouble();
    }
    return 0.0;
  }

  Stream<List<ScanResult>> get scanResults => ble.scanResults;
}