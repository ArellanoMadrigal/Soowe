import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'step_indicator.dart';
import 'date_step.dart';
import 'patient_step.dart';
import 'location_step.dart';
import 'payment_step.dart';
import 'home_screen.dart';

class SolicitMedicalScreen extends StatefulWidget {
  const SolicitMedicalScreen({super.key});

  @override
  State<SolicitMedicalScreen> createState() => _SolicitMedicalScreenState();
}

class _SolicitMedicalScreenState extends State<SolicitMedicalScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<PaymentStepState> _paymentStepKey = GlobalKey<PaymentStepState>();
  int currentStep = 0;

  // Date selection
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String _selectedTimeOption = 'Fecha específica';

  // Patient information
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _conditionController = TextEditingController();

  // Location information
  final _addressController = TextEditingController();



  void _nextPage() {
    if (currentStep == 1 && !_formKey.currentState!.validate()) {
      return;
    }

    if (currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => currentStep++);
    }
  }

  void _previousPage() {
    if (currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

void _submitRequest() {
    final paymentState = _paymentStepKey.currentState;

    if (paymentState != null &&
        paymentState.selectedPaymentMethod == PaymentMethod.card &&
        !paymentState.formKey.currentState!.validate()) {
      return;
    }

    // Crear el objeto de solicitud
    final request = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'service': {
        'id': '1',
        'title': 'Sutura de heridas',
        'price': 400.00,
      },
      'date': DateFormat('yyyy-MM-dd').format(selectedDate),
      'time': selectedTime.format(context),
      'patient': {
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
        'phone': _phoneController.text,
        'condition': _conditionController.text,
      },
      'location': {
        'address': _addressController.text,
      },
      'payment': {
        'method': paymentState?.selectedPaymentMethod.toString().split('.').last ?? 'cash',
        'card_info': paymentState?.selectedPaymentMethod == PaymentMethod.card
            ? {
                'number': paymentState?.cardNumberController.text ?? '',
                'holder': paymentState?.cardHolderController.text ?? '',
                'expiry': paymentState?.expiryController.text ?? '',
                'cvv': paymentState?.cvvController.text ?? '',
              }
            : null,
      },
      'status': 'active',
      'created_at': '2025-02-19 05:11:02',
      'created_by': 'ArellanoMadrigal',
    };

    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Solicitud Enviada'),
        content: const Text('Tu solicitud ha sido procesada exitosamente.'),
        actions: [
          TextButton(
            onPressed: () {
              // Cerrar el diálogo
              Navigator.pop(context);
              
              // Volver a la pantalla principal
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    initialIndex: 1,
                    newRequest: request,
                  ),
                ),
                (route) => false,
              );
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentStep > 0) {
          _previousPage();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: _previousPage,
          ),
          title: Text(
            'Nueva Solicitud',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        body: Column(
          children: [
            StepIndicator(currentStep: currentStep),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DateStep(
                    selectedTimeOption: _selectedTimeOption,
                    selectedDate: selectedDate,
                    selectedTime: selectedTime,
                    onTimeOptionChanged: (value) =>
                        setState(() => _selectedTimeOption = value),
                    onDateChanged: (date) =>
                        setState(() => selectedDate = date),
                    onTimeChanged: (time) =>
                        setState(() => selectedTime = time),
                  ),
                  PatientStep(
                    formKey: _formKey,
                    nameController: _nameController,
                    ageController: _ageController,
                    phoneController: _phoneController,
                    conditionController: _conditionController,
                  ),
                  LocationStep(
                    addressController: _addressController,
                  ),
                  PaymentStep(
                    key: _paymentStepKey,
                    selectedDate: selectedDate,
                    selectedTime: selectedTime,
                  ),
                ],
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: _previousPage,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
            child: Text(
              currentStep == 0 ? 'Cancelar' : 'Atrás',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: currentStep == 3 ? _submitRequest : _nextPage,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              currentStep == 3 ? 'Confirmar' : 'Continuar',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _conditionController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}