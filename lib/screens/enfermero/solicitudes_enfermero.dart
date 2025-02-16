import 'package:flutter/material.dart';

class SolicitudesEnfermero extends StatelessWidget {
  final List<Map<String, String>> solicitudes = [
    {"cliente": "Carlos Gómez", "ubicacion": "CDMX", "detalle": "Cuidados postoperatorios"},
    {"cliente": "María Pérez", "ubicacion": "Guadalajara", "detalle": "Cuidado de adulto mayor"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: solicitudes.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Icon(Icons.person, color: Colors.blue),
              title: Text(solicitudes[index]["cliente"]!),
              subtitle: Text("${solicitudes[index]["ubicacion"]} - ${solicitudes[index]["detalle"]}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.check, color: Colors.green), onPressed: () {}),
                  IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () {}),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
