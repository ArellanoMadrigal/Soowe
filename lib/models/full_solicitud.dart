class RequestCompleteModel {
  final int solicitudId;
  final int? organizacionId;
  final Organizacion? organizacion;
  final Servicio servicio;
  final String id;
  final String usuarioId;
  final String pacienteId;
  final int? enfermeroId;
  final Enfermero? enfermero;
  final String estado;
  final String metodoPago;
  final DateTime fechaSolicitud;
  final DateTime fechaServicio;
  final int pgSolicitudId;
  final String comentarios;
  final String ubicacion;

  RequestCompleteModel({
    required this.solicitudId,
    this.organizacionId,
    this.organizacion,
    required this.servicio,
    required this.id,
    required this.usuarioId,
    required this.pacienteId,
    this.enfermeroId,
    this.enfermero,
    required this.estado,
    required this.metodoPago,
    required this.fechaSolicitud,
    required this.fechaServicio,
    required this.pgSolicitudId,
    required this.comentarios,
    required this.ubicacion,
  });

  factory RequestCompleteModel.fromJson(Map<String, dynamic> json) {
    return RequestCompleteModel(
      solicitudId: json['solicitud_id'],
      organizacionId: json['organizacion_id'] ?? 0,
      organizacion: json['organizacion'] != null
        ? Organizacion.fromJson(json['organizacion'])
        : null,
      servicio: Servicio.fromJson(json['servicio']),
      id: json['_id'],
      usuarioId: json['usuario_id'],
      pacienteId: json['paciente_id'],
      enfermeroId: json['enfermero_id'] ?? 0,
      enfermero: json['enfermero'] != null
        ? Enfermero.fromJson(json['enfermero'])
        : null,
      estado: json['estado'],
      metodoPago: json['metodo_pago'],
      fechaSolicitud: DateTime.parse(json['fecha_solicitud']),
      fechaServicio: DateTime.parse(json['fecha_servicio']),
      pgSolicitudId: json['pg_solicitud_id'],
      comentarios: json['comentarios'],
      ubicacion: json['ubicacion'],
    );
  }
}

class Organizacion {
  final int? organizacionId;
  final String? nombre;
  final String? cuentaBancaria;
  final String? direccion;
  final String? telefono;
  final DateTime? fechaCreacion;
  final DateTime? fechaModificacion;

  Organizacion({
    this.organizacionId,
    this.nombre,
    this.cuentaBancaria,
    this.direccion,
    this.telefono,
    this.fechaCreacion,
    this.fechaModificacion,
  });

  factory Organizacion.fromJson(Map<String, dynamic> json) {
    return Organizacion(
      organizacionId: json['organizacion_id'] ?? 0,
      nombre: json['nombre'] ?? ' ',
      cuentaBancaria: json['cuenta_bancaria'] ?? ' ',
      direccion: json['direccion'] ?? ' ',
      telefono: json['telefono'] ?? ' ',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : null,
      fechaModificacion: json['fecha_modificacion'] != null
          ? DateTime.parse(json['fecha_modificacion'])
          : null,
    );
  }
}

class Servicio {
  final int servicioId;
  final String nombre;
  final String precioEstimado;
  final String descripcion;
  final Categoria categoria;

  Servicio({
    required this.servicioId,
    required this.nombre,
    required this.precioEstimado,
    required this.descripcion,
    required this.categoria,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      servicioId: json['servicios_id'],
      nombre: json['nombre'],
      precioEstimado: json['precio_estimado'],
      descripcion: json['descripcion'],
      categoria: Categoria.fromJson(json['categoria']),
    );
  }
}

class Categoria {
  final int categoriaId;
  final String nombreCategoria;
  final String descripcion;

  Categoria({
    required this.categoriaId,
    required this.nombreCategoria,
    required this.descripcion,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      categoriaId: json['categoria_id'],
      nombreCategoria: json['nombre_categoria'],
      descripcion: json['descripcion'],
    );
  }
}

class Enfermero {
  final int? enfermeroId;
  final String? nombre;
  final String? apellido;
  final bool? disponibilidad;
  final DateTime? fechaCreacion;
  final String? especialidad;
  final String? telefono;
  final String? correo;
  final DateTime? fechaModificacion;
  final String? fotoPerfil;

  Enfermero({
    this.enfermeroId,
    this.nombre,
    this.apellido,
    this.disponibilidad,
    this.fechaCreacion,
    this.especialidad,
    this.telefono,
    this.correo,
    this.fechaModificacion,
    this.fotoPerfil,
  });

  factory Enfermero.fromJson(Map<String, dynamic> json) {
    return Enfermero(
      enfermeroId: json['enfermero_id'] ?? 0,
      nombre: json['nombre'] ?? ' ',
      apellido: json['apellido'] ?? ' ',
      disponibilidad: json['disponibilidad'] ?? false,
      fechaCreacion: json['fecha_creacion'] != null ? DateTime.parse(json['fecha_creacion']) : null,
      especialidad: json['especialidad'] ?? ' ',
      telefono: json['telefono'] ?? ' ',
      correo: json['correo'] ?? ' ',
      fechaModificacion: json['fecha_modificacion'] != null ? DateTime.parse(json['fecha_modificacion']) : null,
      fotoPerfil: json['foto_perfil'] ?? ' ',
    );
  }
}
