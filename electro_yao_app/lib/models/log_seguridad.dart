class LogSeguridad {
  final String id;
  final String evento;
  final String? detalles;
  final DateTime? fechaHora;
  final String? respondidoPor;
  final int? tiempoResolucion;

  LogSeguridad({
    required this.id,
    required this.evento,
    this.detalles,
    this.fechaHora,
    this.respondidoPor,
    this.tiempoResolucion,
  });

  factory LogSeguridad.fromJson(Map<String, dynamic> json) {
    return LogSeguridad(
      id: (json['id'] ?? '').toString(),
      evento: (json['evento'] ?? 'Evento desconocido').toString(),
      detalles: json['detalles']?.toString(),
      fechaHora: json['fecha_hora'] != null
          ? DateTime.tryParse(json['fecha_hora'].toString())
          : null,
      respondidoPor: json['respondido_por']?.toString(),
      tiempoResolucion: json['tiempo_resolucion'] != null
          ? (json['tiempo_resolucion'] as num).toInt()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'evento': evento,
      if (detalles != null) 'detalles': detalles,
      if (fechaHora != null) 'fecha_hora': fechaHora!.toIso8601String(),
      if (respondidoPor != null) 'respondido_por': respondidoPor,
      if (tiempoResolucion != null) 'tiempo_resolucion': tiempoResolucion,
    };
  }

  /// Devuelve el tipo de evento para iconos/colores en la UI
  LogEventType get tipoEvento {
    final e = evento.toLowerCase();
    if (e.contains('armad') || e.contains('bloqueada')) return LogEventType.armed;
    if (e.contains('desarmad') || e.contains('desbloqueada')) return LogEventType.disarmed;
    if (e.contains('alerta') || e.contains('intruso') || e.contains('falla')) return LogEventType.alert;
    if (e.contains('acceso')) return LogEventType.access;
    return LogEventType.info;
  }
}

enum LogEventType { armed, disarmed, alert, access, info }
