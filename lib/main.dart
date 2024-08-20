import 'package:ble_scanner_app/ble_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text("BLE SCANNER"),),
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.grey[850],
        body: GetBuilder<BleController>(
          init: BleController(),
          builder: (BleController controller)
          {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<List<ScanResult>>(
                      stream: controller.scanResults,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final data = snapshot.data![index];
                                  return Card(
                                    elevation: 2,
                                    color: Colors.grey[800],
                                    child: ListTile(
                                      title: Text(data.device.name, style: TextStyle(color: Colors.white)),
                                      subtitle: Text(data.device.id.id,style: TextStyle(color: Colors.white)),
                                      trailing: Text(data.rssi.toString(),style: TextStyle(color: Colors.white)),
                                      onTap: ()=> controller.connectToDevice(data.device),
                                    ),
                                  );
                                }),
                          );
                        }else{
                          return Center(child: Text("No Device Found"),);
                        }
                      }),
                  SizedBox(height: 15,),
                  ElevatedButton(
                    onPressed: () async {
                      controller.scanDevices();
                      // await controller.disconnectDevice();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue[900],   // Color del texto (blanco)
                    ),
                    child: Center(
                      child: Text("SCAN"),
                    ),
                  ),

                ],
              ),
            );
          },
        )
    );
  }
}