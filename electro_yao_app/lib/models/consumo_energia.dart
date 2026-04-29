class ConsumoEnergia {
  final String id;
  final String? dispositivoId;
  final double? vatios;
  final DateTime? fecha;

  ConsumoEnergia({
    required this.id,
    this.dispositivoId,
    this.vatios,
    this.fecha,
  });

  factory ConsumoEnergia.fromJson(Map<String, dynamic> json) {
    return ConsumoEnergia(
      id: json['id'] as String,
      dispositivoId: json['dispositivo_id'] as String?,
      vatios: json['Vatios'] != null ? (json['Vatios'] as num).toDouble() : null,
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (dispositivoId != null) 'dispositivo_id': dispositivoId,
      if (vatios != null) 'Vatios': vatios,
      if (fecha != null) 'fecha': fecha!.toIso8601String(),
    };
  }
}
