import 'package:flutter/material.dart';

class LocationStep extends StatelessWidget {
  final TextEditingController addressController;

  static const String _currentDateTime = '2025-02-19 04:16:44';
  static const String _currentUser = 'ArellanoMadrigal';

  const LocationStep({
    super.key,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ubicación del Servicio',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 24),
          _buildMapPreview(),
          const SizedBox(height: 16),
          _buildLocationButtons(context),
          const SizedBox(height: 16),
          _buildAddressField(),
          const SizedBox(height: 24),
          _buildLocationNote(context),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            const Center(
              child: Text('Mapa en desarrollo'),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Seleccionar en mapa',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: Icons.my_location_outlined,
            label: 'Usar mi ubicación',
            onPressed: () {
              // Implementar obtención de ubicación actual
              addressController.text = 'Ubicación actual (en desarrollo)';
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: Icons.search_outlined,
            label: 'Buscar dirección',
            onPressed: () {
              // Implementar búsqueda de dirección
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildAddressField() {
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
        controller: addressController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Dirección completa',
          alignLabelWithHint: true,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(
              Icons.location_on_outlined,
              color: Colors.grey[600],
              size: 24,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Por favor ingrese la dirección completa';
          }
          if (value!.length < 10) {
            return 'La dirección debe ser más específica';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLocationNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Información Importante',
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
            'Asegúrese de proporcionar una dirección precisa y referencias para que el personal médico pueda ubicarlo fácilmente.',
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

class LocationService {
  static const String _currentDateTime = '2025-02-19 04:22:27';
  static const String _currentUser = 'ArellanoMadrigal';

  static Future<Map<String, dynamic>> getCurrentLocation() async {
    // Implementar obtención de ubicación actual
    await Future.delayed(const Duration(seconds: 1));
    return {
      'latitude': 0.0,
      'longitude': 0.0,
      'address': 'Ubicación actual (en desarrollo)',
      'timestamp': _currentDateTime,
      'user': _currentUser,
    };
  }

  static Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    // Implementar búsqueda de direcciones
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'address': 'Dirección de ejemplo 1',
        'latitude': 0.0,
        'longitude': 0.0,
        'timestamp': _currentDateTime,
        'user': _currentUser,
      },
      {
        'address': 'Dirección de ejemplo 2',
        'latitude': 0.0,
        'longitude': 0.0,
        'timestamp': _currentDateTime,
        'user': _currentUser,
      },
    ];
  }
}