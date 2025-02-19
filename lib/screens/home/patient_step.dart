import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PatientStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController phoneController;
  final TextEditingController conditionController;

  static const String _currentDateTime = '2025-02-19 04:15:19';
  static const String _currentUser = 'ArellanoMadrigal';

  const PatientStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.ageController,
    required this.phoneController,
    required this.conditionController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
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
            _buildTextField(
              controller: nameController,
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
              controller: ageController,
              label: 'Edad',
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              maxLength: 3,
              counter: false,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
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
              controller: phoneController,
              label: 'Teléfono',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              counter: false,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
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
              controller: conditionController,
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
            const SizedBox(height: 24),
            _buildPrivacyNote(context),
          ],
        ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
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
      ),
    );
  }

  Widget _buildPrivacyNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_outlined,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Privacidad de Datos',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'La información proporcionada está protegida y solo será utilizada para brindar el servicio médico solicitado.',
            style: TextStyle(
              color: Theme.of(context).primaryColor.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Última actualización: $_currentDateTime\nRegistrado por: $_currentUser',
            style: TextStyle(
              color: Theme.of(context).primaryColor.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}