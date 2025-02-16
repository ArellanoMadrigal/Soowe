import 'package:flutter/material.dart';



// Constantes para los strings
class _Strings {
  static const String title = 'SOOWE';
  static const String appBarTitle = 'Recuperar Contraseña';
  static const String emailLabel = 'Correo electrónico';
  static const String codeLabel = 'Código';
  static const String newPasswordLabel = 'Nueva contraseña';
  static const String confirmPasswordLabel = 'Confirmar nueva contraseña';
  static const String sendCodeButton = 'Enviar código';
  static const String changePasswordButton = 'Cambiar contraseña';
  static const String codeSentMessage = 'Te hemos enviado un código a tu correo';
  static const String errorEmptyFields = 'Por favor complete todos los campos';
  static const String errorInvalidEmail = 'Por favor ingrese un email válido';
  static const String errorPasswordLength = 'La contraseña debe tener al menos 6 caracteres';
  static const String errorPasswordMatch = 'Las contraseñas no coinciden';
}

class FilledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final FocusNode? focusNode;

  const FilledTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.validator,
    this.suffixIcon,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onFieldSubmitted: (_) => onSubmitted?.call(),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        errorMaxLines: 2,
      ),
    );
  }
}

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _codeSent = false;
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return _Strings.errorEmptyFields;
    }
    if (!_isValidEmail(value!)) {
      return _Strings.errorInvalidEmail;
    }
    return null;
  }

  String? _validateCode(String? value) {
    if (value?.isEmpty ?? true) {
      return _Strings.errorEmptyFields;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return _Strings.errorEmptyFields;
    }
    if (value!.length < 6) {
      return _Strings.errorPasswordLength;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) {
      return _Strings.errorEmptyFields;
    }
    if (value != _newPasswordController.text) {
      return _Strings.errorPasswordMatch;
    }
    return null;
  }

  void _handleRecovery() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Aquí iría la llamada al API para enviar el código
      await Future.delayed(const Duration(seconds: 2)); // Simulación
      
      if (mounted) {
        setState(() {
          _codeSent = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
        setState(() => _isLoading = false);
      }
    }
  }

  void _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Aquí iría la llamada al API para resetear la contraseña
      await Future.delayed(const Duration(seconds: 2)); // Simulación
      
      if (mounted) {
        Navigator.pop(context); // Volver a la pantalla de login
        _showSuccessSnackBar('Contraseña actualizada correctamente');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_Strings.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _Strings.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (!_codeSent) ...[
                FilledTextField(
                  controller: _emailController,
                  label: _Strings.emailLabel,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRecovery,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                  ),
                  child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(_Strings.sendCodeButton),
                ),
              ] else ...[
                const Text(
                  _Strings.codeSentMessage,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledTextField(
                  controller: _codeController,
                  label: _Strings.codeLabel,
                  prefixIcon: Icons.key_outlined,
                  enabled: !_isLoading,
                  validator: _validateCode,
                ),
                const SizedBox(height: 16),
                FilledTextField(
                  controller: _newPasswordController,
                  label: _Strings.newPasswordLabel,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureNewPassword,
                  enabled: !_isLoading,
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                  ),
                ),
                const SizedBox(height: 16),
                FilledTextField(
                  controller: _confirmPasswordController,
                  label: _Strings.confirmPasswordLabel,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  enabled: !_isLoading,
                  validator: _validateConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handlePasswordReset,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                  ),
                  child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(_Strings.changePasswordButton),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}