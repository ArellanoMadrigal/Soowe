import 'package:flutter/material.dart';
import 'perfil_enfermero.dart';
import 'solicitudes_enfermero.dart';
import 'citas_enfermero.dart';
import 'estadisticas_enfermero.dart';

class HomeEnfermero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text("Panel del Enfermero"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _menuCard(context, "Perfil", Icons.person, PerfilEnfermero()),
            _menuCard(context, "Solicitudes", Icons.assignment, SolicitudesEnfermero()),
            _menuCard(context, "Citas", Icons.calendar_today, CitasEnfermero()),
            _menuCard(context, "Estadísticas", Icons.bar_chart, EstadisticasEnfermero()),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, String title, IconData icon, Widget screen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue.shade700),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
