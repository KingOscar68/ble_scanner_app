import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

class BleController extends GetxController {
  FlutterBlue ble = FlutterBlue.instance;

  final String targetServiceUuid = "12345678-1234-5678-1234-567812345678";
  final List<String> targetCharacteristicsUuids = [
    "98679657-1234-5678-1234-567812345671",
    "98679657-1234-5678-1234-567812345672",
    "98679657-1234-5678-1234-567812345673",
    "98679657-1234-5678-1234-567812345674",
    "98679657-1234-5678-1234-567812345675",
    "98679657-1234-5678-1234-567812345676",
    "98679657-1234-5678-1234-567812345677",
    "98679657-1234-5678-1234-567812345678",
    "98679657-1234-5678-1234-567812345679",
  ];

  RxBool isConnecting = true.obs;
  RxBool isConnected = false.obs;

  RxMap<String, int> decodedValues = {"ecg1": 0, "ecg2": 0, "ppg": 0}.obs;

  // Arreglo circular para ecg1 en voltaje (double)
  RxList<double> ecg1Data = List.filled(500, 0.0).obs;

  List<BluetoothCharacteristic> targetCharacteristics = [];

  // Escanea dispositivos y conecta automáticamente
  Future<void> scanAndConnect({required Function onConnected}) async {
    try {
      ble.startScan(timeout: const Duration(seconds: 15));

      ble.scanResults.listen((results) async {
        for (ScanResult result in results) {
          final device = result.device;

          try {
            await device.connect();
            ble.stopScan();

            // Explora servicios para encontrar el objetivo
            List<BluetoothService> services = await device.discoverServices();
            for (BluetoothService service in services) {
              if (service.uuid.toString().toLowerCase() == targetServiceUuid.toLowerCase()) {
                for (BluetoothCharacteristic characteristic in service.characteristics) {
                  if (targetCharacteristicsUuids.contains(
                      characteristic.uuid.toString().toLowerCase())) {
                    targetCharacteristics.add(characteristic);

                    // Activa notificaciones para recibir datos en tiempo real
                    characteristic.setNotifyValue(true);
                    characteristic.value.listen((value) {
                      if (value.length >= 20) {
                        decodeAFEData(value);
                      }
                    });
                  }
                }

                if (targetCharacteristics.length == targetCharacteristicsUuids.length) {
                  isConnected.value = true;
                  isConnecting.value = false;

                  // Llama al callback para navegar
                  onConnected();
                  return;
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

  // Actualiza el arreglo circular de ecg1 con valores en voltaje
  void updateEcg1Data(int rawValue) {
    // Convierte el valor crudo a voltaje
    double voltage = rawValue * 1.2 / ((1 << 21) - 1);

    ecg1Data.removeAt(0); // Elimina el primer elemento
    ecg1Data.add(voltage); // Agrega el nuevo valor en voltaje al final
  }

  // Función para decodificar datos del buffer
  void decodeAFEData(List<int> buffer) {
    if (buffer.length < 20) return;

    int ecg1 = decodeSensorData(buffer.sublist(8, 11));
    int ecg2 = decodeSensorData(buffer.sublist(12, 15));
    int ppg = decodeSensorData(buffer.sublist(16, 19));

    decodedValues["ecg1"] = ecg1;
    decodedValues["ecg2"] = ecg2;
    decodedValues["ppg"] = ppg;

    updateEcg1Data(ecg1); // Actualiza el arreglo circular de ecg1 con voltaje

    print("ECG1 Raw: $ecg1, ECG1 Voltage: ${ecg1 * 1.2 / ((1 << 21) - 1)}");
  }

  // Función auxiliar para decodificar un sensor
  int decodeSensorData(List<int> data) {
    if (data.length != 3) return 0;

    // Construye el valor absoluto a partir de los bits
    int value = (data[2] & 0x1F) << 16 | (data[1] << 8) | data[0];

    // Determina el signo
    int sign = 1;
    if ((data[2] & 0xE0) == 0xE0) {
      sign = -1;
    } else {
      sign = 1;
    }

    return sign * value;
  }
}
