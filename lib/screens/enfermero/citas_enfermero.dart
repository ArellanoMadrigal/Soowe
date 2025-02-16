import 'package:flutter/material.dart';

class CitasEnfermero extends StatelessWidget {
  final List<String> citas = ["Cita con Paciente A", "Cita con Paciente B"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mis Citas")),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: citas.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(citas[index]),
              subtitle: Text("Fecha: 20/02/2025"),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}
