class Dispositivo {
  final String id;
  final String nombreArea;
  final String? tipoDispositivo;
  final String? estado;
  final String? ubicacion;
  final String? modo;
  final DateTime? ultimaActualizacion;

  Dispositivo({
    required this.id,
    required this.nombreArea,
    this.tipoDispositivo,
    this.estado,
    this.ubicacion,
    this.modo,
    this.ultimaActualizacion,
  });

  factory Dispositivo.fromJson(Map<String, dynamic> json) {
    return Dispositivo(
      id: (json['id'] ?? '').toString(),
      nombreArea: (json['nombre_area'] ?? json['Nombre_area'] ?? 'Área Desconocida').toString(),
      tipoDispositivo: json['tipo_dispositivo']?.toString() ?? json['Tipo_dispositivo']?.toString(),
      estado: json['Estado']?.toString() ?? json['estado']?.toString(),
      ubicacion: json['Ubicación']?.toString() ?? json['ubicacion']?.toString(),
      modo: json['modo']?.toString() ?? json['Modo']?.toString(),
      ultimaActualizacion: json['ultima_actualizacion'] != null
          ? DateTime.tryParse(json['ultima_actualizacion'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_area': nombreArea,
      if (tipoDispositivo != null) 'tipo_dispositivo': tipoDispositivo,
      if (estado != null) 'Estado': estado,
      if (ubicacion != null) 'Ubicación': ubicacion,
      if (modo != null) 'modo': modo,
      if (ultimaActualizacion != null)
        'ultima_actualizacion': ultimaActualizacion!.toIso8601String(),
    };
  }
}
