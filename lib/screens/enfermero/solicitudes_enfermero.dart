import 'package:flutter/material.dart';

class SolicitudesEnfermero extends StatelessWidget {
  final List<String> solicitudes = ["Paciente 1", "Paciente 2", "Paciente 3"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Solicitudes de Trabajo")),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: solicitudes.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(solicitudes[index]),
              subtitle: Text("Ubicación: Ciudad X"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
