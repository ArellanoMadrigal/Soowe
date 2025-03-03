import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/patient.dart';
import '../../services/auth_service.dart';
import '../../services/patient_service.dart';

class PatientStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController phoneController;
  final TextEditingController conditionController;

  const PatientStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.ageController,
    required this.phoneController,
    required this.conditionController,
  });

  @override
  State<PatientStep> createState() => _PatientStepState();
}

class _PatientStepState extends State<PatientStep> {
  final AuthService _authService = AuthService();
  final PatientService _patientService = PatientService();
  List<PatientModel> _patients = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserPatients();
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
          _patients = fetchedPatients;
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

  void _navigateToAddPatient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPatientScreen()),
    );

    if (result == true) {
      _loadUserPatients();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToPatientDetails(PatientModel patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailsScreen(patient: patient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información del Paciente',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 24),
                _patients.isNotEmpty
                    ? _buildPatientList()
                    : _buildPatientForm(),
                const SizedBox(height: 16),
                _buildAddPatientButton(),
                const SizedBox(height: 24),
                _buildPrivacyNote(context),
              ],
            ),
    );
  }

  Widget _buildPatientList() {
    return Column(
      children: [
        ..._patients.map((patient) => ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.black54),
              title: Text(patient.nombre),
              subtitle: Text(patient.descripcion),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _navigateToPatientDetails(patient);
              },
            )),
      ],
    );
  }

  Widget _buildPatientForm() {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: widget.nameController,
            label: 'Nombre completo',
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Por favor ingrese el nombre completo';
              }
              if (value!.length < 3) {
                return 'El nombre debe tener al menos 3 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: widget.ageController,
            label: 'Edad',
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            maxLength: 3,
            counter: false,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Por favor ingrese la edad';
              }
              final age = int.tryParse(value!);
              if (age == null || age <= 0 || age > 120) {
                return 'Ingrese una edad válida';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: widget.phoneController,
            label: 'Teléfono',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            counter: false,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Por favor ingrese el teléfono';
              }
              if (!RegExp(r'^\d{10}$').hasMatch(value!)) {
                return 'Ingrese un número válido de 10 dígitos';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: widget.conditionController,
            label: 'Condición o padecimiento',
            icon: Icons.medical_services_outlined,
            maxLines: 3,
            helperText: 'Describa brevemente el motivo de la consulta',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Por favor describa la condición';
              }
              if (value!.length < 10) {
                return 'Proporcione más detalles sobre la condición';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int? maxLength,
    int maxLines = 1,
    bool counter = true,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        counterText: counter ? null : '',
      ),
      validator: validator,
    );
  }

  Widget _buildAddPatientButton() {
    return ElevatedButton.icon(
      onPressed: _navigateToAddPatient,
      icon: const Icon(Icons.person_add_outlined),
      label: const Text('Agregar paciente'),
    );
  }

  Widget _buildPrivacyNote(BuildContext context) {
    return Text(
      'La información proporcionada está protegida y solo será utilizada para brindar el servicio médico solicitado.',
      style: TextStyle(color: Colors.grey[600]),
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
