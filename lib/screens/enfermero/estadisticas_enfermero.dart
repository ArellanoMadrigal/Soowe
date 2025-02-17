import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EstadisticasEnfermero extends StatefulWidget {
  @override
  _EstadisticasEnfermeroState createState() => _EstadisticasEnfermeroState();
}

class _EstadisticasEnfermeroState extends State<EstadisticasEnfermero> {
  // Opciones de filtro
  final List<String> filtrosMes = [
    'Por Mes',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo', 
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];

  final List<String> filtrosPeriodo = [
    'Últimos 3 meses',
    'Este Año',
    'Año Anterior',
  ];

  // Variables para almacenar la selección actual
  String mesSeleccionado = 'Por Mes';
  String periodoSeleccionado = 'Últimos 3 meses';

  // Para rango de fechas personalizado
  DateTimeRange? rangoFechas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppBar-like container
          Container(
            color: Color(0xFF2196F3),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10, 
              left: 16, 
              bottom: 16
            ),
            child: Row(
              children: [
                Text(
                  'Estadísticas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filtros
                    Row(
                      children: [
                        _buildDropdownButton(
                          text: mesSeleccionado, 
                          opciones: filtrosMes,
                          onChanged: (valor) {
                            setState(() {
                              mesSeleccionado = valor;
                            });
                          }
                        ),
                        SizedBox(width: 16),
                        _buildDropdownButton(
                          text: periodoSeleccionado, 
                          opciones: filtrosPeriodo,
                          onChanged: (valor) async {
                            if (valor == 'Personalizado') {
                              // Mostrar selector de rango de fechas
                              final result = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                initialDateRange: rangoFechas,
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      primaryColor: Color(0xFF2196F3),
                                      colorScheme: ColorScheme.light(
                                        primary: Color(0xFF2196F3),
                                        secondary: Color(0xFF2196F3)
                                      ),
                                      buttonTheme: ButtonThemeData(
                                        textTheme: ButtonTextTheme.primary
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (result != null) {
                                setState(() {
                                  rangoFechas = result;
                                  periodoSeleccionado = 'Personalizado';
                                });
                              }
                            } else {
                              setState(() {
                                periodoSeleccionado = valor;
                                rangoFechas = null;
                              });
                            }
                          }
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Mostrar rango de fechas seleccionado si es personalizado
                    if (rangoFechas != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Rango seleccionado: ${DateFormat('dd/MM/yyyy').format(rangoFechas!.start)} - ${DateFormat('dd/MM/yyyy').format(rangoFechas!.end)}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    
                    // Tarjeta de Servicios
                    _buildServiciosCard(),
                    
                    SizedBox(height: 16),
                    
                    // Tabla de Fechas
                    _buildFechasTable(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownButton({
    required String text, 
    required List<String> opciones,
    required void Function(String) onChanged
  }) {
    return PopupMenuButton<String>(
      offset: Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      itemBuilder: (BuildContext context) {
        return opciones.map((String opcion) {
          return PopupMenuItem<String>(
            value: opcion,
            child: Text(opcion),
          );
        }).toList();
      },
      onSelected: onChanged,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: TextStyle(color: Colors.black87)),
            SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, color: Colors.black87),
          ],
        ),
      ),
    );
  }

  // Los métodos _buildServiciosCard y _buildFechasTable permanecen igual que en el ejemplo anterior
  Widget _buildServiciosCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Servicios",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            "Inicio de tu carrera",
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_busy,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 16),
                Text(
                  "Sin servicios aún",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Mantente activa y pronto tendrás\ntu primer servicio",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFechasTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          _buildEmptyStateRow(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey.shade100,
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Fechas", 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              "Servicios", 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              "Ganancias", 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateRow() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.dashboard,
              size: 50,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16),
            Text(
              "No hay datos disponibles",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Tus estadísticas aparecerán aquí\ncuando realices servicios",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}