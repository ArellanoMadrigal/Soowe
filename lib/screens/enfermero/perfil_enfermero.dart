import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class PerfilEnfermero extends StatefulWidget {
  @override
  _PerfilEnfermeroState createState() => _PerfilEnfermeroState();
}

class _PerfilEnfermeroState extends State<PerfilEnfermero> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  static const String KEY_IMAGE_PATH = 'profile_image_path';

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  // Cargar la imagen guardada al iniciar
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? imagePath = prefs.getString(KEY_IMAGE_PATH);
    
    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        setState(() {
          _image = file;
        });
      }
    }
  }

  // Guardar la imagen en el almacenamiento permanente
  Future<void> _saveImage(File image) async {
    // Obtener el directorio de documentos de la aplicación
    final directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;
    
    // Crear un nombre único para la imagen
    final String fileName = 'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = '$path/$fileName';

    // Copiar la imagen al directorio permanente
    await image.copy(filePath);

    // Guardar la ruta en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_IMAGE_PATH, filePath);

    // Actualizar la UI
    setState(() {
      _image = File(filePath);
    });
  }

  Future<void> _selectImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar imagen'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Galería'),
                  ),
                  onTap: () {
                    _getImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                GestureDetector(
                  child: ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text('Cámara'),
                  ),
                  onTap: () {
                    _getImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (selectedImage != null) {
      await _saveImage(File(selectedImage.path));
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar sesión'),
          content: Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Sí, cerrar sesión'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      // Si quieres borrar la imagen al cerrar sesión, descomenta estas líneas:
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.remove(KEY_IMAGE_PATH);
      // if (_image != null && await _image!.exists()) {
      //   await _image!.delete();
      // }
      
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue,
                        backgroundImage: _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            onPressed: _selectImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Fernanda Arellano",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Enfermera de Urgencias",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.email, color: Colors.blue),
              title: Text(
                "Correo electrónico",
                style: TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                "alemil@gmail.com",
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.blue),
              title: Text(
                "Teléfono",
                style: TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                "+52 999 123 4567",
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.blue),
              title: Text(
                "Dirección",
                style: TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                "Calle Falsa 123, Ciudad, País",
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
                child: Text(
                  "Cerrar sesión",
                  style: TextStyle(color: Colors.blue),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.blue.shade100),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}