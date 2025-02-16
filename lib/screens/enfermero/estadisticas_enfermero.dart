import 'package:flutter/material.dart';

class EstadisticasEnfermero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Estadísticas Generales", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(Icons.assignment_turned_in, color: Colors.blue),
                title: Text("Citas completadas"),
                trailing: Text("24"),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.attach_money, color: Colors.green),
                title: Text("Ganancias del mes"),
                trailing: Text("\$12,500"),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.star, color: Colors.orange),
                title: Text("Calificación promedio"),
                trailing: Text("4.8/5"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
