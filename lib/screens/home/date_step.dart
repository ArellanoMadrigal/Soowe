import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateStep extends StatelessWidget {
  final String selectedTimeOption;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<String> onTimeOptionChanged;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;


  const DateStep({
    super.key,
    required this.selectedTimeOption,
    required this.selectedDate,
    required this.selectedTime,
    required this.onTimeOptionChanged,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cuándo necesita el servicio?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 24),
          _buildTimeOptions(),
          if (selectedTimeOption == 'Fecha específica') ...[
            const SizedBox(height: 24),
            _buildDateTimeSelectors(context),
          ],
          const SizedBox(height: 24),
          _buildAvailabilityNote(context),
        ],
      ),
    );
  }

  Widget _buildTimeOptions() {
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
          _buildTimeOption(
            title: 'Lo antes posible',
            subtitle: 'En las próximas 2 horas',
            icon: Icons.timer_outlined,
          ),
          if (TimeOfDay.now().hour < 20) ...[
            const Divider(height: 1),
            _buildTimeOption(
              title: 'Hoy',
              subtitle: 'Más tarde el día de hoy',
              icon: Icons.today_outlined,
            ),
          ],
          const Divider(height: 1),
          _buildTimeOption(
            title: 'Fecha específica',
            subtitle: 'Seleccionar fecha y hora',
            icon: Icons.calendar_month_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOption({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedTimeOption == title;

    return InkWell(
      onTap: () => onTimeOptionChanged(title),
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
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: title,
              groupValue: selectedTimeOption,
              onChanged: (value) {
                if (value != null) onTimeOptionChanged(value);
              },
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelectors(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDateButton(context),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTimeButton(context),
        ),
      ],
    );
  }

  Widget _buildDateButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _selectDate(context),
      style: _getSelectorButtonStyle(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd/MM/yyyy').format(selectedDate),
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _selectTime(context),
      style: _getSelectorButtonStyle(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              selectedTime.format(context),
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _getSelectorButtonStyle() {
    return OutlinedButton.styleFrom(
      side: const BorderSide(color: Colors.grey),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onDateChanged(picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onTimeChanged(picked);
  }

  Widget _buildAvailabilityNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Disponibilidad del Servicio',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Los horarios mostrados están sujetos a disponibilidad del personal médico.',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para validar la fecha y hora seleccionada
  bool isValidDateTime() {
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    return selectedDateTime.isAfter(now);
  }
}