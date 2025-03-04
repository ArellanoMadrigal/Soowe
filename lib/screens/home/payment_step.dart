import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'models.dart';

class PaymentStep extends StatefulWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;

  const PaymentStep({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<PaymentStep> createState() => PaymentStepState();
}

class PaymentStepState extends State<PaymentStep> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  final formKey = GlobalKey<FormState>();

  // Controladores para el formulario de tarjeta
  final cardNumberController = TextEditingController();
  final cardHolderController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();

  // Getters públicos para acceder al estado
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;

  @override
  void dispose() {
    cardNumberController.dispose();
    cardHolderController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Método de Pago',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 24),
          _buildPaymentOptions(),
          if (_selectedPaymentMethod == PaymentMethod.card) ...[
            const SizedBox(height: 24),
            _buildCardForm(),
          ],
          const SizedBox(height: 24),
          _buildServiceSummary(),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
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
      child: Column(
        children: [
          _buildPaymentOption(
            icon: Icons.credit_card_outlined,
            title: 'Tarjeta de Crédito/Débito',
            subtitle: 'Pago seguro con tarjeta',
            method: PaymentMethod.card,
          ),
          Divider(color: Colors.grey[200]),
          _buildPaymentOption(
            icon: Icons.payments_outlined,
            title: 'Efectivo',
            subtitle: 'Pago en efectivo al personal médico',
            method: PaymentMethod.cash,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required PaymentMethod method,
  }) {
    final isSelected = _selectedPaymentMethod == method;

    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Radio<PaymentMethod>(
              value: method,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                if (value != null) setState(() => _selectedPaymentMethod = value);
              },
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _buildCardNumberField(),
          const SizedBox(height: 16),
          _buildCardHolderField(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildExpiryField()),
              const SizedBox(width: 16),
              Expanded(child: _buildCVVField()),
            ],
          ),
          const SizedBox(height: 24),
          _buildSecurityNote(),
        ],
      ),
    );
  }

  Widget _buildCardNumberField() {
    return _buildTextField(
      controller: cardNumberController,
      label: 'Número de Tarjeta',
      icon: Icons.credit_card_outlined,
      keyboardType: TextInputType.number,
      maxLength: 19,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _CardNumberFormatter(),
      ],
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Ingrese el número de tarjeta';
        }
        if (value!.replaceAll(' ', '').length != 16) {
          return 'Número de tarjeta inválido';
        }
        return null;
      },
    );
  }

  Widget _buildCardHolderField() {
    return _buildTextField(
      controller: cardHolderController,
      label: 'Nombre del Titular',
      icon: Icons.person_outline,
      textCapitalization: TextCapitalization.characters,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Ingrese el nombre del titular';
        }
        if (value!.length < 5) {
          return 'Nombre demasiado corto';
        }
        return null;
      },
    );
  }

  Widget _buildExpiryField() {
    return _buildTextField(
      controller: expiryController,
      label: 'MM/YY',
      icon: Icons.calendar_today_outlined,
      keyboardType: TextInputType.number,
      maxLength: 5,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _ExpiryDateFormatter(),
      ],
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Ingrese la fecha';
        }
        if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value!)) {
          return 'Formato inválido';
        }
        return _validateExpiryDate(value);
      },
    );
  }

  Widget _buildCVVField() {
    return _buildTextField(
      controller: cvvController,
      label: 'CVV',
      icon: Icons.lock_outline,
      keyboardType: TextInputType.number,
      maxLength: 3,
      obscureText: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Ingrese el CVV';
        }
        if (!RegExp(r'^\d{3,4}$').hasMatch(value!)) {
          return 'CVV inválido';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
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
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600], size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          counterText: '',
          contentPadding: const EdgeInsets.all(16),
        ),
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        validator: validator,
      ),
    );
  }

  String? _validateExpiryDate(String value) {
    final parts = value.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || month < 1 || month > 12) {
      return 'Mes inválido';
    }

    if (year == null) {
      return 'Año inválido';
    }

    final now = DateTime.now();
    final cardDate = DateTime(2000 + year, month);
    final minDate = DateTime(now.year, now.month);

    if (cardDate.isBefore(minDate)) {
      return 'Tarjeta vencida';
    }

    return null;
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security_outlined,
            color: Colors.grey[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pago Seguro',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tus datos de pago están protegidos y encriptados',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSummary() {
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
          const Text(
            'Resumen del Servicio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Servicio:', 'Sutura de heridas'),
          _buildSummaryRow(
            'Fecha:',
            DateFormat('dd/MM/yyyy').format(widget.selectedDate),
          ),
          _buildSummaryRow(
            'Hora:',
            widget.selectedTime.format(context),
          ),
          const Divider(),
          _buildSummaryRow(
            'Total:',
            NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(400.00),
            isBold: true,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) {
      text = text.substring(0, 16);
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i != 15) {
        buffer.write(' ');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text.replaceAll('/', '');
    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && i != text.length - 1) {
        buffer.write('/');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Validador de tarjeta de crédito
class CreditCardValidator {
  static String? validateCard(String? number) {
    if (number == null || number.isEmpty) {
      return 'Ingrese el número de tarjeta';
    }

    final cleanNumber = number.replaceAll(' ', '');
    if (cleanNumber.length != 16) {
      return 'El número debe tener 16 dígitos';
    }

    if (!_luhnAlgorithm(cleanNumber)) {
      return 'Número de tarjeta inválido';
    }

    return null;
  }

  static bool _luhnAlgorithm(String number) {
    int sum = 0;
    bool alternate = false;

    for (int i = number.length - 1; i >= 0; i--) {
      int n = int.parse(number[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  static String? validateExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese la fecha de expiración';
    }

    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
      return 'Formato inválido (MM/YY)';
    }

    final parts = value.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || month < 1 || month > 12) {
      return 'Mes inválido';
    }

    if (year == null) {
      return 'Año inválido';
    }

    final now = DateTime.now();
    final cardDate = DateTime(2000 + year, month);
    final minDate = DateTime(now.year, now.month);

    if (cardDate.isBefore(minDate)) {
      return 'Tarjeta vencida';
    }

    return null;
  }

  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese el CVV';
    }

    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'CVV inválido';
    }

    return null;
  }
}