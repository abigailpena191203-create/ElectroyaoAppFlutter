class Dispositivo {
  final String id;
  final String nombreArea;
  final String? tipoDispositivo;
  final String? estado;
  final String? ubicacion;
  final DateTime? ultimaActualizacion;

  Dispositivo({
    required this.id,
    required this.nombreArea,
    this.tipoDispositivo,
    this.estado,
    this.ubicacion,
    this.ultimaActualizacion,
  });

  factory Dispositivo.fromJson(Map<String, dynamic> json) {
    return Dispositivo(
      id: json['id'] as String,
      nombreArea: json['nombre_area'] as String,
      tipoDispositivo: json['tipo_dispositivo'] as String?,
      estado: json['Estado'] as String?,
      ubicacion: json['Ubicación'] as String?,
      ultimaActualizacion: json['ultima_actualizacion'] != null
          ? DateTime.parse(json['ultima_actualizacion'] as String)
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
      if (ultimaActualizacion != null)
        'ultima_actualizacion': ultimaActualizacion!.toIso8601String(),
    };
  }
}
