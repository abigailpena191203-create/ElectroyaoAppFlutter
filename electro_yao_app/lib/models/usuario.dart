class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final String estado;
  final DateTime? fechaRegistro;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.estado,
    this.fechaRegistro,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: (json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? 'Sin nombre').toString(),
      email: (json['email'] ?? '').toString(),
      rol: (json['rol'] ?? 'Empleado').toString(),
      estado: (json['estado'] ?? 'Activo').toString(),
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.tryParse(json['fecha_registro'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'estado': estado,
      if (fechaRegistro != null)
        'fecha_registro': fechaRegistro!.toIso8601String(),
    };
  }

  bool get isActive => estado.toLowerCase() == 'activo';

  /// Roles válidos según el esquema de la DB
  static const List<String> rolesValidos = [
    'Administrador',
    'Seguridad',
    'Empleado',
  ];
}
