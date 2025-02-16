import 'package:flutter/material.dart';

class CitasEnfermero extends StatelessWidget {
  final List<Map<String, String>> citas = [
    {"paciente": "Carlos Gómez", "fecha": "12 Sept 2024", "hora": "10:00 AM"},
    {"paciente": "María Pérez", "fecha": "15 Sept 2024", "hora": "3:00 PM"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: citas.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.blue),
              title: Text(citas[index]["paciente"]!),
              subtitle: Text("${citas[index]["fecha"]} - ${citas[index]["hora"]}"),
            ),
          );
        },
      ),
    );
  }
}
