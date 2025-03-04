import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

class LocationStep extends StatefulWidget {
  final TextEditingController addressController;

  const LocationStep({
    super.key,
    required this.addressController,
  });

  @override
  _LocationStepState createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
  late GoogleMapController _mapController;
  LatLng _initialPosition =
      LatLng(37.7749, -122.4194); // Coordenadas por defecto (San Francisco)
  LatLng? _selectedLocation;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

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

  Future<loc.LocationData> getUserLocation() async {
    loc.Location location = loc.Location();
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Future.error('El servicio de ubicación está desactivado');
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return Future.error('Permisos de ubicación denegados');
      }
    }

    return await location.getLocation();
  }

  Future<void> updateAddressFromCoordinates(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String address = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        setState(() {
          widget.addressController.text = address;
        });
      } else {
        // Handle case where no address is found
        widget.addressController.text = 'Dirección no encontrada';
      }
    } catch (e) {
      // Handle error in geocoding
      widget.addressController.text = 'Error al obtener la dirección';
    }
  }

  Future<void> _checkLocationPermission() async {
    loc.Location location = loc.Location();
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    var locationData = await location.getLocation();
    setState(() {
      _initialPosition = LatLng(locationData.latitude!, locationData.longitude!);
    });
  }


  Widget _buildMapPreview() {
    return SizedBox(
      height: 300,
      child: _initialPosition.latitude == 37.7749 && _initialPosition.longitude == -122.4194
          ? Center(child: CircularProgressIndicator()) // Loading spinner
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.0,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: _selectedLocation == null
                  ? {}
                  : {
                      Marker(
                        markerId: MarkerId('selected_location'),
                        position: _selectedLocation!,
                      ),
                    },
              onTap: (LatLng location) {
                setState(() {
                  _selectedLocation = location;
                  widget.addressController.text =
                      'Lat: ${location.latitude}, Long: ${location.longitude}';
                  updateAddressFromCoordinates(location); // Actualiza la dirección
                });
              },
            ),
    );
  }

  // Botones de ubicación
  Widget _buildLocationButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: Icons.my_location_outlined,
            label: 'Usar mi ubicación',
            onPressed: () async {
              var locationData = await getUserLocation();
              setState(() {
                _initialPosition =
                    LatLng(locationData.latitude!, locationData.longitude!);
                _selectedLocation = _initialPosition;
                widget.addressController.text =
                    'Ubicación actual: ${_initialPosition.latitude}, ${_initialPosition.longitude}';
                updateAddressFromCoordinates(_initialPosition); // Actualiza la dirección
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: Icons.search_outlined,
            label: 'Buscar dirección',
            onPressed: () async {
              String address = widget.addressController.text;
              try {
                List<Location> locations = await locationFromAddress(address);
                if (locations.isNotEmpty) {
                  LatLng newLocation = LatLng(locations[0].latitude, locations[0].longitude);
                  setState(() {
                    _selectedLocation = newLocation;
                    _mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
                  });
                } else {
                  // Handle no results
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dirección no encontrada')));
                }
              } catch (e) {
                // Handle error in searching for an address
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al buscar la dirección')));
              }
            }
          ),
        ),
      ],
    );
  }

  // Botón personalizado
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

  // Campo de dirección
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
        controller: widget.addressController,
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
        ),
        onChanged: (value) {
            if (value.isNotEmpty) {
            _debounceSearch(value);
          }
        },
      ),
    );
  }

  // Debounce search method
  void _debounceSearch(String value) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel(); // Cancel any previous timers
    }
    // Start a new timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (value.isNotEmpty) {
        try {
          // Perform location search based on address entered
          List<Location> locations = await locationFromAddress(value);
          if (locations.isNotEmpty) {
            LatLng newLocation = LatLng(locations[0].latitude, locations[0].longitude);
            setState(() {
              _selectedLocation = newLocation;
              _mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
            });
          } else {
            // Handle no results found
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dirección no encontrada')));
          }
        } catch (e) {
          // Handle error
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al buscar la dirección')));
        }
      }
    });
  }

  // Nota de ubicación
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
        ],
      ),
    );
  }
}
