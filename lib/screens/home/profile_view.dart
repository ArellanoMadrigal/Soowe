import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/patient.dart';
import '../../services/patient_service.dart';

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
      cursorPosition =
          newValue.selection.baseOffset + (formattedText.length - text.length);
      if (cursorPosition < 0) cursorPosition = 0;
      if (cursorPosition > formattedText.length)
        cursorPosition = formattedText.length;
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
  final PatientService _patientService = PatientService();
  List<PatientModel> patients = [];

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
    _loadUserPatients();
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
      // Mostrar diálogo para elegir la fuente de la imagen
      if (!mounted) return;
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Seleccionar imagen'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tomar foto'),
                onTap: () async {
                  final status = await Permission.camera.request();
                  if (status.isGranted) {
                    if (!context.mounted) return;
                    Navigator.pop(context, ImageSource.camera);
                  } else {
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _showErrorSnackBar(
                        'Se requiere permiso para usar la cámara');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de galería'),
                onTap: () async {
                  if (Platform.isAndroid) {
                    final status = await Permission.storage.request();
                    if (status.isGranted) {
                      if (!context.mounted) return;
                      Navigator.pop(context, ImageSource.gallery);
                    } else {
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _showErrorSnackBar(
                          'Se requieren permisos para acceder a las fotos');
                    }
                  } else {
                    final status = await Permission.photos.request();
                    if (status.isGranted) {
                      if (!context.mounted) return;
                      Navigator.pop(context, ImageSource.gallery);
                    } else {
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _showErrorSnackBar(
                          'Se requieren permisos para acceder a las fotos');
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Seleccionar imagen
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      // Convertir a File y verificar tamaño
      final File imageFile = File(pickedFile.path);
      final fileSize = await imageFile.length();

      if (!mounted) return;

      // Verificar tamaño máximo (5MB)
      if (fileSize > 5 * 1024 * 1024) {
        _showErrorSnackBar('La imagen es demasiado grande (máximo 5MB)');
        return;
      }

      // Mostrar indicador de carga
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

      // Subir imagen
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

        // Actualizar UI con la nueva imagen
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

  Future<void> _loadUserPatients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.getCurrentUserId();
      if (userId != null) {
        List<PatientModel> fetchedPatients =
            await _patientService.getAllPatientsFromUser(userId);

        setState(() {
          patients = fetchedPatients;
        });
      }
    } catch (e) {
      _showErrorSnackBar('No se pudo cargar la lista de pacientes');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToPatientDetails(PatientModel patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailsScreen(patient: patient),
      ),
    );
  }

  void _navigateToAddPatient() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPatientScreen(),
      ),
    ).then((_) {
      _loadUserPatients();
    });
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
                title: 'Pacientes',
                children: [
                  if (patients.isNotEmpty)
                    ...patients.map((patient) => _ProfileItem(
                          icon: Icons.person_outline,
                          title: patient.nombre,
                          subtitle: patient.descripcion,
                          showArrow: true,
                          onTap: () {
                            _navigateToPatientDetails(patient);
                          },
                        )),
                  _ProfileItem(
                    icon: Icons.person_add_outlined,
                    title: 'Agregar paciente',
                    onTap: () {
                      _navigateToAddPatient();
                    },
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
                          content: const Text(
                              '¿Estás seguro que deseas cerrar sesión?'),
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
                      ? const Icon(Icons.person_outline,
                          size: 40, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 32,
                      maxHeight: 32,
                    ),
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
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
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
  final bool showArrow;
  final bool showEdit;
  final VoidCallback? onTap;

  const _ProfileItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.showArrow = false,
    this.showEdit = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showEdit)
              Icon(
                Icons.edit_outlined,
                size: 20,
                color: Colors.grey.shade400,
              )
            else if (showArrow)
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }
}

class PatientDetailsScreen extends StatelessWidget {
  final PatientModel patient;

  const PatientDetailsScreen({super.key, required this.patient});
  

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(patient.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navegar a la pantalla de edición del paciente
              _navigateToEditPatient(context, patient);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient.nombre,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Descripción: ${patient.descripcion}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Alergias: ${patient.alergias.join(", ")}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Cuidados necesarios: ${patient.cuidadosNecesarios ?? "Ninguno"}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditPatient(BuildContext context, PatientModel patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPatientScreen(patient: patient),
      ),
    ).then((_) {
      // Recargar los detalles del paciente si es necesario
      Navigator.pop(context, true); // Actualizar la pantalla anterior
    });
  }
}

class AddPatientScreen extends StatefulWidget {
  final PatientModel? patient;

  const AddPatientScreen({super.key, this.patient});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _conditionController = TextEditingController();
  final _careController = TextEditingController();

  final _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Si se está editando un paciente, llenar los campos con sus datos
    if (widget.patient != null) {
      _nameController.text = widget.patient!.nombre;
      _descriptionController.text = widget.patient!.descripcion;
      _allergiesController.text = widget.patient!.alergias.join(", ");
      _conditionController.text = widget.patient!.estado ?? 'En Espera';
      _careController.text = widget.patient!.cuidadosNecesarios ?? 'Ninguno';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.patient == null ? 'Agregar Paciente' : 'Editar Paciente'),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Descripción'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una descripción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _allergiesController,
                      decoration: const InputDecoration(
                          labelText: 'Alergias (separadas por comas)'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _careController,
                      decoration: const InputDecoration(
                          labelText: 'Cuidados necesarios'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: Text(widget.patient == null
                          ? 'Agregar Paciente'
                          : 'Guardar Cambios'),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ));
  }

  void _submitForm() async {
    PatientService patientService = PatientService();
    AuthService authService = AuthService();

    if (_formKey.currentState!.validate()) {
      final userId = authService.getCurrentUserId();
      if (userId == null) {
        _showErrorSnackBar('Error de autenticación');
        return;
      }

      // Crear el objeto de paciente
      final patientData = PatientModel(
        nombre: _nameController.text,
        descripcion: _descriptionController.text,
        alergias:
            _allergiesController.text.split(',').map((e) => e.trim()).toList(),
        estado: _conditionController.text,
        cuidadosNecesarios:
            _careController.text.isNotEmpty ? _careController.text : null,
        usuarioId: userId,
      );

      try {
        // Llamar a la API para agregar el paciente
        await patientService.createNewPatient(patientData);

        // Navegar de regreso con un resultado
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _allergiesController.dispose();
    _conditionController.dispose();
    _careController.dispose();
    super.dispose();
  }
}
