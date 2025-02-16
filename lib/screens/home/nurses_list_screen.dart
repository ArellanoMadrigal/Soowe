// import 'package:flutter/material.dart';
// import '../../services/api_service.dart'; // Importa el archivo de conexión
// import '../../services/auth_service.dart'; // Importa el archivo de autenticación

// class LongList extends StatefulWidget {
//   const LongList({super.key});

//   @override
//   LongListState createState() => LongListState();
// }

// class LongListState extends State<LongList> {
//   final ApiService _apiService = ApiService();
//   final List<dynamic> _users = []; // Lista de usuarios
//   bool _isLoading = false; // Indicador de carga
//   bool _hasMore = true; // Flag para saber si hay más datos
//   int _page = 1; // Página actual para la paginación
//   final int _limit = 10; // Número de usuarios por página
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchUsers();

//     // Listener para detectar cuando se llega al final de la lista
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels ==
//               _scrollController.position.maxScrollExtent &&
//           !_isLoading &&
//           _hasMore) {
//         _fetchUsers();
//       }
//     });
//   }

//   Future<void> _fetchUsers() async {
//     if (_isLoading || !_hasMore) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Inicia sesión usando Dio
//       await AuthService.login('string', 'string'); // Cambia las credenciales

//       // Obtiene usuarios para la página actual usando Dio
//       final users = await _apiService.fetchAllUsers(limit: _limit, page: _page);

//       setState(() {
//         if (users.isEmpty) {
//           _hasMore = false; // No hay más datos por cargar
//         } else {
//           _users.addAll(users);
//           _page++; // Incrementa la página para futuras solicitudes
//         }
//       });
//     } catch (error) {
//       debugPrint('Error al cargar usuarios: $error');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Función para manejar la eliminación usando Dio
//   Future<void> _deleteUser(String userId) async {
//     try {
//       await _apiService.deleteUser(userId); // Llama a la API de eliminación
//       setState(() {
//         _users.removeWhere((user) => user['_id'] == userId); // Elimina de la lista local
//       });
//     } catch (error) {
//       debugPrint('Error al eliminar usuario: $error');
//     }
//   }

//   // Función para manejar la edición
//   void _editUser(String userId) {
//     // Lógica para editar el usuario
//     // Por ejemplo, puedes abrir un cuadro de diálogo o navegar a una pantalla de edición
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Edit User'),
//           content: const Text('Here you will be able to edit the User. If the api were ready...'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 // Lógica de actualización del usuario
//                 // Podrías enviar los datos actualizados a la API
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Función para agregar un nuevo usuario
//   void _addUser() {
//     // Lógica para agregar un nuevo usuario
//     // Puedes navegar a una pantalla de formulario o abrir un cuadro de diálogo
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Add User'),
//           content: const Text('Form to add a new user. If the function were working...'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 // Lógica de creación de nuevo usuario
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Users List'),
//       ),
//       body: _users.isEmpty
//           ? _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : const Center(child: Text('There is no users available.'))
//           : ListView.builder(
//               controller: _scrollController,
//               itemCount: _users.length + (_isLoading ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index == _users.length) {
//                   // Indicador de carga al final
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final user = _users[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 5,
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.all(16),
//                     leading: CircleAvatar(
//                       backgroundImage: NetworkImage(
//                           user['foto'] ?? 'https://via.placeholder.com/150'),
//                     ),
//                     title: Text(
//                       user['name'] ?? 'Sin nombre',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                             "Comida favorita: ${user['comidaFavorita'] ?? 'No especificado'}"),
//                         const SizedBox(height: 4),
//                         Text("ID: ${user['_id'] ?? 'N/A'}"),
//                       ],
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit),
//                           onPressed: () {
//                             _editUser(user['_id']);
//                           },
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete),
//                           onPressed: () {
//                             _deleteUser(user['_id']);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _addUser,
//         tooltip: 'Agregar Usuario',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
// }