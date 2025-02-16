import 'package:flutter/material.dart';

class PerfilEnfermero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Perfil del Enfermero")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(radius: 50, backgroundColor: Colors.blue.shade700),
            SizedBox(height: 15),
            Text("Nombre del Enfermero", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Especialidad: Enfermería General"),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {},
              child: Text("Editar Perfil"),
            ),
          ],
        ),
      ),
    );
  }
}
