import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:appdesarrollo/screens/enfermero/perfil_enfermero.dart';
import 'package:appdesarrollo/screens/enfermero/solicitudes_enfermero.dart';
import 'package:appdesarrollo/screens/enfermero/estadisticas_enfermero.dart';

class HomeEnfermero extends StatefulWidget {
  @override
  _HomeEnfermeroState createState() => _HomeEnfermeroState();
}

class _HomeEnfermeroState extends State<HomeEnfermero> {
  int _selectedIndex = 0;
  File? _profileImage;
  bool _showWelcomeNotification = false;
  static const String KEY_IMAGE_PATH = 'profile_image_path';
  static const String KEY_FIRST_OPEN = 'first_app_open';

  final List<Widget> _screens = [
    SolicitudesEnfermero(),
    EstadisticasEnfermero(),
    PerfilEnfermero(),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Cargar datos iniciales: imagen de perfil y notificación de bienvenida
  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cargar imagen de perfil
    final String? imagePath = prefs.getString(KEY_IMAGE_PATH);
    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        setState(() {
          _profileImage = file;
        });
      }
    }

    // Verificar si es la primera vez que se abre la app
    final bool isFirstOpen = prefs.getBool(KEY_FIRST_OPEN) ?? true;
    if (isFirstOpen) {
      setState(() {
        _showWelcomeNotification = true;
      });
      // Marcar que ya no es la primera vez
      await prefs.setBool(KEY_FIRST_OPEN, false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Mostrar diálogo de bienvenida
  void _mostrarNotificacionBienvenida() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Bienvenida!'),
          content: Text('Fernanda, estás lista para comenzar tu turno. Revisa tus solicitudes y mantente atenta.'),
          actions: <Widget>[
            TextButton(
              child: Text('Entendido'),
              onPressed: () {
                setState(() {
                  _showWelcomeNotification = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Construir AppBar para la pantalla de inicio
  PreferredSizeWidget? _buildAppBar() {
    // Solo mostrar la barra con el ícono de notificación en la pantalla de inicio
    if (_selectedIndex == 0) {
      // Mostrar notificación de bienvenida si está activa
      if (_showWelcomeNotification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mostrarNotificacionBienvenida();
        });
      }

      return AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue, 
              radius: 20,
              backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
              child: _profileImage == null
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Fernanda Arellano",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  )
                ),
                Text(
                  "Enfermera de Urgencias",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey
                  )
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Si hay notificación de bienvenida, mostrar un punto rojo
          _showWelcomeNotification 
            ? Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications, color: Colors.black),
                    onPressed: _mostrarNotificacionBienvenida,
                  ),
                  Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  )
                ],
              )
            : IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.black),
                onPressed: null,
              ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      );
    }
    // Para otras pantallas, no mostrar AppBar
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          // Recargar la imagen de perfil
          await _loadInitialData();
        },
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Solicitudes"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Estadísticas"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil"
          ),
        ],
      ),
    );
  }
}