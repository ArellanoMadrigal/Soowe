import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'step_indicator.dart';
import 'date_step.dart';
import 'patient_step.dart';
import 'location_step.dart';
import 'payment_step.dart';
import 'home_screen.dart';
import '../../services/api_service.dart';
import '../../models/service.dart';
import '../../models/solicitud.dart';
import '../../models/payment.dart';
import '../../services/auth_service.dart';
import '../../services/request_service.dart';
import '../../services/payment_service.dart';

class RequestMedicalScreen extends StatefulWidget {
  final ServiceModel? service;

  const RequestMedicalScreen({
    super.key,
    this.service,
  });

  @override
  State<RequestMedicalScreen> createState() => _RequestMedicalScreenState();
}

class _RequestMedicalScreenState extends State<RequestMedicalScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<PaymentStepState> _paymentStepKey =
      GlobalKey<PaymentStepState>();
  int currentStep = 0;

  // Date selection
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String _selectedTimeOption = 'Fecha específica';

  // Patient information
  String? patientId;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _conditionController = TextEditingController();

  // Location information
  final _addressController = TextEditingController();

  void _nextPage() {
    if (currentStep == 1 && _formKey.currentState != null && !_formKey.currentState!.validate()) {
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
                    onPatientSelected: (id) => setState(() => patientId = id),
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

  void _submitRequest() async {
    final paymentState = _paymentStepKey.currentState;
    final apiService = ApiService();
    final authService = AuthService();
    final requestService = RequestService();
    final paymentService = PaymentService();

      // Validar el formulario de pago si se selecciona tarjeta
    if (paymentState != null &&
        paymentState.selectedPaymentMethod == PaymentMethod.card &&
        !paymentState.formKey.currentState!.validate()) {
      return;
    }

    // Validar que la fecha y la hora sean correctas
    DateTime now = DateTime.now();
    DateTime fullSelectedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (fullSelectedDate.isBefore(now)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fecha inválida'),
          content: const Text('La fecha y hora seleccionadas deben ser futuras.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      return;
    }

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await requestService.createRequest(
        usuarioId: authService.getCurrentUserId() ?? '',
        pacienteId: patientId!,
        estado: 'en espera',
        metodoPago: paymentState?.selectedPaymentMethod.toString().split('.').last ?? 'efectivo',
        fechaSolicitud: now,
        fechaServicio: fullSelectedDate,
        comentarios: _conditionController.text,
        ubicacion: _addressController.text,
      );

      final payment = Payment(
        amount: widget.service?.precioEstimado.toString() ?? '0',
        paymentMethod: response.metodoPago,
        paymentDate: now,
        status: 'pendiente',
        details: paymentState?.selectedPaymentMethod == PaymentMethod.card
            ? 'Tarjeta: ${paymentState?.cardNumberController.text}'
            : 'Pago en efectivo',
        requestId: int.parse(response.id),
      );

      // Crear el pago
      await paymentService.createPayment(payment);

      // Cerrar el indicador de carga
      Navigator.pop(context);

      // Mostrar diálogo de éxito
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Solicitud Enviada'),
          content: const Text('Tu solicitud ha sido procesada exitosamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      initialIndex: 1,
                      newRequest: response.toJson(),
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
    } catch (e) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
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
