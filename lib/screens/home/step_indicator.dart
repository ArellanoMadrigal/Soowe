import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;

  const StepIndicator({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: List.generate(4, (index) {
              final isActive = index <= currentStep;
              final isCompleted = index < currentStep;
              final color = isActive ? Colors.blue : Colors.grey[350];

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: isActive ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    if (index < 3)
                      Expanded(
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: isActive && !isCompleted
                                ? LinearGradient(
                                    colors: [
                                      color!,
                                      Colors.grey[350]!,
                                    ],
                                  )
                                : null,
                            color: isActive && isCompleted ? color : Colors.grey[350],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel('Fecha', 0),
              _buildLabel('Paciente', 1),
              _buildLabel('Ubicación', 2),
              _buildLabel('Pago', 3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, int step) {
    final isActive = step <= currentStep;
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey[500],
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        if (isActive)
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

class StepData {
  final String title;
  final IconData icon;
  final String createdAt;
  final String createdBy;

  StepData({
    required this.title,
    required this.icon,
    String? createdAt,
    String? createdBy,
  })  : createdAt = createdAt ?? '2025-02-19 04:11:50',
        createdBy = createdBy ?? 'ArellanoMadrigal';

  static final List<StepData> steps = [
    StepData(
      title: 'Fecha',
      icon: Icons.calendar_today,
    ),
    StepData(
      title: 'Paciente',
      icon: Icons.person,
    ),
    StepData(
      title: 'Ubicación',
      icon: Icons.location_on,
    ),
    StepData(
      title: 'Pago',
      icon: Icons.payment,
    ),
  ];
}

class StepTheme {
  static const Color activeColor = Colors.blue;
  static const Color inactiveColor = Colors.grey;
  static const double indicatorSize = 24.0;
  static const double lineHeight = 2.0;
  static const double labelSize = 13.0;
  static const double iconSize = 16.0;
  
  static BoxDecoration activeIndicatorDecoration = BoxDecoration(
    color: activeColor,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: Colors.blue.withOpacity(0.2),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration inactiveIndicatorDecoration = BoxDecoration(
    color: inactiveColor,
    shape: BoxShape.circle,
  );

  static TextStyle activeLabelStyle = const TextStyle(
    color: Colors.black,
    fontSize: labelSize,
    fontWeight: FontWeight.w500,
  );

  static TextStyle inactiveLabelStyle = TextStyle(
    color: Colors.grey[500],
    fontSize: labelSize,
    fontWeight: FontWeight.normal,
  );
}

extension StepIndicatorExtensions on int {
  bool isCompleted(int currentStep) => this < currentStep;
  bool isActive(int currentStep) => this <= currentStep;
  bool isCurrent(int currentStep) => this == currentStep;
}