import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/energia_provider.dart';
import '../providers/theme_provider.dart';
import '../models/consumo_energia.dart';

class EnergyChartWidget extends StatelessWidget {
  const EnergyChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EnergiaProvider>();
    final isDark = context.select<ThemeProvider, bool>((tp) => tp.isDarkMode);
    final theme = Theme.of(context);
    final cardBg = isDark ? const Color(0xFF0D1F3C) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE2E8F0);
    final gridColor = isDark ? const Color(0xFF1E3A5F).withValues(alpha: 0.5) : const Color(0xFFE2E8F0);
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.trending_up_rounded, color: Colors.blue[300], size: 20),
            const SizedBox(width: 8),
            Text('Tendencia de Ahorro Energético',
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 15)),
          ]),
          const SizedBox(height: 24),
          RepaintBoundary(
            child: SizedBox(
              height: 220,
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildChart(provider.registros, gridColor, labelColor, isDark),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(labelColor),
        ],
      ),
    );
  }

  Widget _buildChart(List<ConsumoEnergia> registros, Color gridColor, Color labelColor, bool isDark) {
    // Tomamos los últimos 12 registros y los invertimos (más antiguo primero)
    final data = registros.take(12).toList().reversed.toList();
    if (data.isEmpty) return const SizedBox.shrink();

    // Spots de consumo
    final consumoSpots = data.asMap().entries.map((e) =>
        FlSpot(e.key.toDouble(), e.value.vatios ?? 0)).toList();

    // Spots de ahorro acumulado (diferencia entre promedio y consumo)
    final avg = data.fold(0.0, (s, r) => s + (r.vatios ?? 0)) / data.length;
    double ahorroAcum = 0;
    final ahorroSpots = data.asMap().entries.map((e) {
      ahorroAcum += ((e.value.vatios ?? 0) < avg ? avg - (e.value.vatios ?? 0) : 0);
      return FlSpot(e.key.toDouble(), ahorroAcum.clamp(0, 999));
    }).toList();

    final maxY = consumoSpots.fold(0.0, (m, s) => s.y > m ? s.y : m) * 1.3;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: maxY > 0 ? maxY : 400,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (_) => FlLine(color: gridColor, strokeWidth: 1),
          getDrawingVerticalLine: (_) => FlLine(color: gridColor.withValues(alpha: 0.5), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: Text('Watts', style: TextStyle(color: labelColor, fontSize: 11)),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                  style: TextStyle(color: labelColor, fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                final fecha = data[idx].fecha;
                if (fecha == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_formatHora12(fecha), style: TextStyle(color: labelColor, fontSize: 9)),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => isDark ? Colors.black87 : Colors.white,
            getTooltipItems: (spots) => spots.map((s) {
              final label = s.barIndex == 0 ? 'Consumo' : 'Ahorro';
              final color = s.barIndex == 0 ? Colors.blue[300]! : Colors.green[400]!;
              return LineTooltipItem('$label\n${s.y.toInt()} W',
                  TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12));
            }).toList(),
          ),
        ),
        lineBarsData: [
          // Línea de Consumo (Azul)
          LineChartBarData(
            spots: consumoSpots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF3B82F6),
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 3.5, color: const Color(0xFF3B82F6), strokeWidth: 0),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [const Color(0xFF3B82F6).withValues(alpha: 0.25), const Color(0xFF3B82F6).withValues(alpha: 0)],
              ),
            ),
          ),
          // Línea de Ahorro Acumulado (Verde)
          LineChartBarData(
            spots: ahorroSpots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF10B981),
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 3.5, color: const Color(0xFF10B981), strokeWidth: 0),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [const Color(0xFF10B981).withValues(alpha: 0.2), const Color(0xFF10B981).withValues(alpha: 0)],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildLegend(Color labelColor) {
    return Row(children: [
      _LegendItem(color: const Color(0xFF3B82F6), label: 'Consumo (W)'),
      const SizedBox(width: 20),
      _LegendItem(color: const Color(0xFF10B981), label: 'Ahorro Acumulado (W)'),
    ]);
  }

  String _formatHora12(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 20, height: 3,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 6),
      Icon(Icons.circle, size: 6, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    ]);
  }
}
