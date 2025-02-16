import 'package:flutter/material.dart';
import 'perfil_enfermero.dart';
import 'solicitudes_enfermero.dart';
import 'citas_enfermero.dart';
import 'estadisticas_enfermero.dart';

class HomeEnfermero extends StatefulWidget {
  @override
  _HomeEnfermeroState createState() => _HomeEnfermeroState();
}

class _HomeEnfermeroState extends State<HomeEnfermero> {
  int _selectedIndex = 0;

  static List<Widget> _screens = [
    SolicitudesEnfermero(),
    CitasEnfermero(),
    EstadisticasEnfermero(),
    PerfilEnfermero(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundColor: Colors.blue, radius: 20),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Fernanda Arellano", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Enfermera de Urgencias", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [IconButton(icon: Icon(Icons.notifications), onPressed: () {})],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Solicitudes"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Citas"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Estadísticas"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}
