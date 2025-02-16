import 'package:flutter/material.dart';

class PerfilEnfermero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(radius: 50, backgroundColor: Colors.blue),
            SizedBox(height: 10),
            Text("Fernanda Arellano", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Enfermera de Urgencias", style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.email),
              title: Text("fernanda@email.com"),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text("+52 999 123 4567"),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {},
              child: Text("Editar Perfil"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
