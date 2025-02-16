// File: profile/profile_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Solo permitir números
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Limitar a 10 dígitos
    final trimmedText = text.length > 10 ? text.substring(0, 10) : text;
    var formattedText = '';
    
    // Formatear como (XXX) - XXX - XXXX
    if (trimmedText.length >= 3) {
      formattedText = '(${trimmedText.substring(0, 3)})';
      if (trimmedText.length >= 6) {
        formattedText += ' - ${trimmedText.substring(3, 6)}';
        if (trimmedText.length > 6) {
          formattedText += ' - ${trimmedText.substring(6)}';
        }
      } else if (trimmedText.length > 3) {
        formattedText += ' - ${trimmedText.substring(3)}';
      }
    } else {
      formattedText = trimmedText;
    }

    // Calcular la nueva posición del cursor
    var cursorPosition = formattedText.length;
    if (newValue.selection.baseOffset < text.length) {
      cursorPosition = newValue.selection.baseOffset + (formattedText.length - text.length);
      if (cursorPosition < 0) cursorPosition = 0;
      if (cursorPosition > formattedText.length) cursorPosition = formattedText.length;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

// Profile View Screen
class ProfileView extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileView({
    super.key,
    required this.onLogout,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  String name = 'Cargando...';
  String email = '';
  String phone = '';
  String address = '';
  String? profileImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  String _formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length != 10) return phone;
    
    return '(${cleaned.substring(0, 3)}) - ${cleaned.substring(3, 6)} - ${cleaned.substring(6, 10)}';
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userData = await _authService.getUserProfile();
      setState(() {
        name = '${userData['nombre']} ${userData['apellido']}'.trim();
        email = userData['correo'] ?? '';
        phone = _formatPhoneNumber(userData['telefono'] ?? '');
        address = userData['direccion'] ?? '';
        profileImageUrl = userData['foto_perfil']?['url'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('No se pudo cargar el perfil');
    }
  }

  Future<void> _handleProfileImageUpload() async {
    try {
      // 1. Seleccionar imagen
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (pickedFile == null) return;

      // 2. Convertir a File y verificar tamaño
      final File imageFile = File(pickedFile.path);
      final fileSize = await imageFile.length();
      
      if (!mounted) return;
      
      // Verificar tamaño máximo (5MB)
      if (fileSize > 5 * 1024 * 1024) {
        _showErrorSnackBar('La imagen es demasiado grande (máximo 5MB)');
        return;
      }

      // 3. Mostrar indicador de carga
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

      // 4. Subir imagen
      try {
        final userId = await _authService.getCurrentUserId();
        if (userId == null) {
          if (!mounted) return;
          Navigator.of(context).pop();
          _showErrorSnackBar('Error de autenticación');
          return;
        }

        final uploadedImage = await _apiService.uploadProfilePicture(imageFile);
        
        if (!mounted) return;
        Navigator.of(context).pop();

        // 5. Actualizar UI con la nueva imagen
        if (uploadedImage['url'] != null) {
          setState(() {
            profileImageUrl = uploadedImage['url'];
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen de perfil actualizada'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Opcional: Recargar el perfil completo
          await _loadUserProfile();
        } else {
          _showErrorSnackBar('Error al procesar la imagen');
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop();
        _showErrorSnackBar('No se pudo subir la imagen: ${e.toString()}');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error al seleccionar imagen: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  Future<void> _handleEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          name: name,
          email: email,
          phone: phone,
          address: address,
        ),
      ),
    );

    if (result != null) {
      try {
        final userId = _authService.getCurrentUserId();
        if (userId != null) {
          await _apiService.updateUserProfile(userId, {
            'nombre': result['name'].split(' ')[0],
            'apellido': result['name'].split(' ').length > 1 
              ? result['name'].split(' ').sublist(1).join(' ')
              : '',
            'telefono': result['phone'],
            'direccion': result['address']
          });

          await _loadUserProfile();
        }
      } catch (e) {
        _showErrorSnackBar('No se pudo actualizar el perfil');
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _ProfileHeader(
                name: name,
                profileImageUrl: profileImageUrl,
                onEdit: _handleEdit,
                onImageUpload: _handleProfileImageUpload,
              ),
              const SizedBox(height: 20),
              _SectionGroup(
                children: [
                  _ProfileItem(
                    icon: Icons.email_outlined,
                    title: 'Correo electrónico',
                    subtitle: email,
                  ),
                  _ProfileItem(
                    icon: Icons.phone_outlined,
                    title: 'Teléfono',
                    subtitle: phone,
                    showEdit: true,
                    onTap: _handleEdit,
                  ),
                  _ProfileItem(
                    icon: Icons.location_on_outlined,
                    title: 'Dirección',
                    subtitle: address,
                    showEdit: true,
                    onTap: _handleEdit,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionGroup(
                title: 'Preferencias',
                children: [
                  _ProfileItem(
                    icon: Icons.settings_outlined,
                    title: 'Configuración',
                    showArrow: true,
                  ),
                  _ProfileItem(
                    icon: Icons.help_outline,
                    title: 'Ayuda',
                    showArrow: true,
                  ),
                  _ProfileItem(
                    icon: Icons.logout,
                    title: 'Cerrar sesión',
                    showArrow: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Cerrar sesión'),
                          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onLogout();
                              },
                              child: const Text('Cerrar sesión'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Edit Profile Screen
class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(
      text: _formatInitialPhone(widget.phone),
    );
    _addressController = TextEditingController(text: widget.address);
  }

  String _formatInitialPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length != 10) return phone;
    
    return '(${cleaned.substring(0, 3)}) - ${cleaned.substring(3, 6)} - ${cleaned.substring(6, 10)}';
  }

  String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, {
                  'name': _nameController.text,
                  'phone': _cleanPhoneNumber(_phoneController.text),
                  'address': _addressController.text,
                });
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInputCard(
              title: 'Nombre completo',
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Ingresa tu nombre completo',
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildInputCard(
              title: 'Correo electrónico',
              child: TextFormField(
                initialValue: widget.email,
                enabled: false,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInputCard(
              title: 'Teléfono',
              child: TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  hintText: '(123) - 456 - 7890',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  PhoneInputFormatter(),
                  LengthLimitingTextInputFormatter(19),
                ],
                validator: (value) {
                  final cleaned = _cleanPhoneNumber(value ?? '');
                  if (cleaned.length != 10) {
                    return 'Ingresa un número de teléfono válido';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildInputCard(
              title: 'Dirección',
              child: TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Ingresa tu dirección',
                  border: InputBorder.none,
                ),
                maxLines: null,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor ingresa tu dirección';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

// Profile Header Widget
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String? profileImageUrl;
  final VoidCallback onEdit;
  final VoidCallback onImageUpload;

  const _ProfileHeader({
    required this.name,
    this.profileImageUrl,
    required this.onEdit,
    required this.onImageUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GestureDetector(
            onTap: onImageUpload,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : null,
                  child: profileImageUrl == null
                    ? const Icon(Icons.person_outline, size: 40, color: Colors.white)
                    : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 18),
                      onPressed: onImageUpload,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onEdit,
            child: const Text('Editar perfil'),
          ),
        ],
      ),
    );
  }
}

class _SectionGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _SectionGroup({
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool showEdit;
  final bool showArrow;
  final VoidCallback? onTap;

  const _ProfileItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.showEdit = false,
    this.showArrow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            if (showEdit)
              Icon(
                Icons.edit_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              )
            else if (showArrow)
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}