import 'package:appdesarrollo/services/user_service.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

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
 late TextEditingController _emailController;
 late TextEditingController _phoneController;
 late TextEditingController _addressController;
 final _formKey = GlobalKey<FormState>();
 final ApiService _apiService = ApiService();

 @override
 void initState() {
   super.initState();
   _nameController = TextEditingController(text: widget.name);
   _emailController = TextEditingController(text: widget.email);
   _phoneController = TextEditingController(text: widget.phone);
   _addressController = TextEditingController(text: widget.address);
 }

 @override
 void dispose() {
   _nameController.dispose();
   _emailController.dispose();
   _phoneController.dispose();
   _addressController.dispose();
   super.dispose();
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Theme.of(context).colorScheme.surface,
     appBar: AppBar(
       title: const Text('Editar Perfil'),
       centerTitle: true,
       leading: IconButton(
         icon: const Icon(Icons.arrow_back),
         onPressed: () => Navigator.pop(context),
       ),
     ),
     body: SafeArea(
       child: SingleChildScrollView(
         child: Column(
           children: [
             const SizedBox(height: 20),
             const CircleAvatar(
               radius: 50,
               backgroundColor: Colors.grey,
               child: Icon(Icons.person_outline, size: 50, color: Colors.white),
             ),
             const SizedBox(height: 30),
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 24),
               child: Form(
                 key: _formKey,
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.stretch,
                   children: [
                     _buildTextField(
                       controller: _nameController,
                       label: 'Nombre',
                       icon: Icons.person_outline,
                     ),
                     const SizedBox(height: 16),
                     _buildTextField(
                       controller: _emailController,
                       label: 'Email',
                       icon: Icons.email_outlined,
                       keyboardType: TextInputType.emailAddress,
                     ),
                     const SizedBox(height: 16),
                     _buildTextField(
                       controller: _phoneController,
                       label: 'Teléfono',
                       icon: Icons.phone_outlined,
                       keyboardType: TextInputType.phone,
                     ),
                     const SizedBox(height: 16),
                     _buildTextField(
                       controller: _addressController,
                       label: 'Dirección',
                       icon: Icons.location_on_outlined,
                     ),
                     const SizedBox(height: 32),
                     FilledButton(
                       onPressed: _saveChanges,
                       style: FilledButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(12),
                         ),
                       ),
                       child: const Text(
                         'Guardar Cambios',
                         style: TextStyle(fontSize: 16),
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ],
         ),
       ),
     ),
   );
 }

 Widget _buildTextField({
   required TextEditingController controller,
   required String label,
   required IconData icon,
   TextInputType? keyboardType,
 }) {
   return TextFormField(
     controller: controller,
     keyboardType: keyboardType,
     decoration: InputDecoration(
       labelText: label,
       prefixIcon: Icon(icon),
       border: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: BorderSide(
           color: Theme.of(context).colorScheme.outline,
         ),
       ),
       enabledBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: BorderSide(
           color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
         ),
       ),
       focusedBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: BorderSide(
           color: Theme.of(context).colorScheme.primary,
           width: 2,
         ),
       ),
       filled: true,
       fillColor: Theme.of(context).colorScheme.surface,
     ),
     validator: (value) {
       if (value == null || value.isEmpty) {
         return 'Campo requerido';
       }
       return null;
     },
   );
 }

 Future<void> _saveChanges() async {
   if (_formKey.currentState!.validate()) {
     try {
       final success = await UserService().updateUser(
         id: 'your_id',
         nombre: _nameController.text,
         apellido: 'your_last_name', // replace with actual last name
         correo: _emailController.text,
         contrasena: 'your_password', // replace with actual password
         telefono: _phoneController.text,
         direccion: _addressController.text,
       );

       if (success && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Cambios guardados correctamente')),
         );
         Navigator.pop(context, {
           'name': _nameController.text,
           'email': _emailController.text,
           'phone': _phoneController.text,
           'address': _addressController.text,
         });
       }
     } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Error al guardar cambios')),
         );
       }
     }
   }
 }
}