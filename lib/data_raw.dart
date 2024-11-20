import 'package:flutter/material.dart';

class DataRawPage extends StatelessWidget {
  const DataRawPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Raw")),
      body: const Center(
        child: Text(
          "¡Dispositivo Conectado!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
