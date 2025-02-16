import 'package:flutter/material.dart';

class EstadisticasEnfermero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mis Estadísticas")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 80, color: Colors.blue.shade700),
            SizedBox(height: 15),
            Text("Total de Servicios: 12"),
            Text("Calificación Promedio: 4.8 ⭐"),
          ],
        ),
      ),
    );
  }
}
