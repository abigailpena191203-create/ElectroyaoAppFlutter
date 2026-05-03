import 'package:flutter/material.dart';

class MetasAhorroWidget extends StatelessWidget {
  final double ahorroMensual;
  final double metaAhorro;
  final double consumoActual;
  final double limiteConsumo;
  final int diasRestantes;
  final double promedioDiario;

  const MetasAhorroWidget({
    super.key,
    required this.ahorroMensual,
    required this.metaAhorro,
    required this.consumoActual,
    required this.limiteConsumo,
    required this.diasRestantes,
    required this.promedioDiario,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF131D34) : Colors.white; // slightly lighter than 0D1F3C to match screenshot
    final borderColor = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE2E8F0);
    final textColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
    final subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final trackColor = isDark ? const Color(0xFF2A3F6F) : const Color(0xFFE2E8F0);

    final porcentajeAhorro = (ahorroMensual / metaAhorro).clamp(0.0, 1.0);
    final porcentajeConsumo = (consumoActual / limiteConsumo).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.track_changes_rounded, color: Colors.greenAccent[400], size: 20),
            const SizedBox(width: 8),
            Text('Metas de Ahorro',
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
          const SizedBox(height: 24),
          
          // Ahorro Mensual
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ahorro Mensual', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '\$${ahorroMensual.toStringAsFixed(2)} ', style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 14)),
                    TextSpan(text: '/ \$${metaAhorro.toStringAsFixed(2)}', style: TextStyle(color: subTextColor, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: porcentajeAhorro,
              backgroundColor: trackColor,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text('${(porcentajeAhorro * 100).toStringAsFixed(1)}% de la meta alcanzada', style: TextStyle(color: subTextColor, fontSize: 11)),
          
          const SizedBox(height: 24),

          // Consumo Actual vs Límite
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Consumo Actual vs Límite', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '${consumoActual.toInt()}W ', style: const TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.bold, fontSize: 14)),
                    TextSpan(text: '/ ${limiteConsumo.toInt()}W', style: TextStyle(color: subTextColor, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: porcentajeConsumo,
              backgroundColor: trackColor,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.show_chart, color: subTextColor, size: 12),
              const SizedBox(width: 4),
              Text('${(limiteConsumo - consumoActual).toInt()}W por debajo del límite', style: TextStyle(color: subTextColor, fontSize: 11)),
            ],
          ),

          const SizedBox(height: 24),

          // Stats bottom
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D142B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Días restantes', style: TextStyle(color: subTextColor, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('$diasRestantes', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D142B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Promedio diario', style: TextStyle(color: subTextColor, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('\$${promedioDiario.toStringAsFixed(2)}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
