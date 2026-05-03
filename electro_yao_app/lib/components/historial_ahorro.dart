import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/energia_provider.dart';
import '../providers/theme_provider.dart';
import '../models/consumo_energia.dart';

/// Historial de Ahorro Energético — fiel a la captura de pantalla
/// Incluye: Tab Día/Semana/Mes, estadísticas, tabla y calendario interactivo
class HistorialAhorro extends StatefulWidget {
  const HistorialAhorro({super.key});

  @override
  State<HistorialAhorro> createState() => _HistorialAhorroState();
}

class _HistorialAhorroState extends State<HistorialAhorro> {
  int _tabIndex = 1; // 0=Día, 1=Semana, 2=Mes
  DateTime _selectedDate = DateTime.now();
  DateTime _calendarMonth = DateTime.now();

  static const _tabs = [
    (Icons.calendar_today_rounded, 'Día'),
    (Icons.show_chart_rounded, 'Semana'),
    (Icons.calendar_month_rounded, 'Mes'),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EnergiaProvider>();
    final isDark = context.select<ThemeProvider, bool>((tp) => tp.isDarkMode);
    final theme = Theme.of(context);
    final cardBg = isDark ? const Color(0xFF0D1F3C) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE2E8F0);

    final periodData = _getPeriodData(provider.registros);

    return Container(
      decoration: BoxDecoration(
        color: cardBg, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        const Row(children: [
          Icon(Icons.calendar_month_rounded, color: Colors.blueAccent, size: 20),
          SizedBox(width: 8),
          Text('Historial de Ahorro Energético',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ]),
        const SizedBox(height: 20),
        // Tab bar
        _buildTabs(isDark),
        const SizedBox(height: 20),
        // Estadísticas
        _buildStats(periodData, isDark),
        const SizedBox(height: 20),
        // Tabla + Calendario
        RepaintBoundary(
          child: LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 3, child: _buildTable(periodData, isDark)),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: _buildCalendar(isDark)),
              ]);
            }
            return Column(children: [
              _buildTable(periodData, isDark),
              const SizedBox(height: 20),
              _buildCalendar(isDark),
            ]);
          }),
        ),
      ]),
    );
  }

  Widget _buildTabs(bool isDark) {
    final tabBg = isDark ? const Color(0xFF0A1628) : const Color(0xFFF1F5F9);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: tabBg, borderRadius: BorderRadius.circular(12)),
      child: Row(children: _tabs.asMap().entries.map((e) {
        final sel = e.key == _tabIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tabIndex = e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                boxShadow: sel ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(e.value.$1, size: 14, color: sel ? const Color(0xFF1E3A8A) : (isDark ? const Color(0xFF94A3B8) : Colors.grey)),
                const SizedBox(width: 4),
                Text(e.value.$2,
                    style: TextStyle(
                        color: sel ? const Color(0xFF1E3A8A) : (isDark ? const Color(0xFF94A3B8) : Colors.grey),
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13)),
              ]),
            ),
          ),
        );
      }).toList()),
    );
  }

  Widget _buildStats(List<_PeriodRow> data, bool isDark) {
    final totalConsumo = data.fold(0.0, (s, r) => s + r.consumo);
    final totalAhorro = data.fold(0.0, (s, r) => s + r.ahorro);
    final costoEvitado = totalAhorro * 0.00038; // ~$0.38 por kWh
    final horasApagado = (totalAhorro / 60).round();

    return Row(children: [
      _StatBox(label: '∿ Total Ahorrado', value: '${totalAhorro.toInt()}W', color: const Color(0xFF10B981), isDark: isDark),
      const SizedBox(width: 12),
      _StatBox(label: '💰 Costo Evitado', value: '\$${costoEvitado.toStringAsFixed(2)}', color: const Color(0xFF3B82F6), isDark: isDark),
      const SizedBox(width: 12),
      _StatBox(label: '⏰ Horas Apagado', value: '${horasApagado}h', color: const Color(0xFF8B5CF6), isDark: isDark),
    ]);
  }

  Widget _buildTable(List<_PeriodRow> data, bool isDark) {
    final textColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
    final headerColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final divColor = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE2E8F0);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header de tabla
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(flex: 2, child: Text('Período', style: TextStyle(color: headerColor, fontSize: 12, fontWeight: FontWeight.w600))),
          Expanded(child: Text('Consumo', style: TextStyle(color: headerColor, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
          Expanded(child: Text('Ahorro', style: TextStyle(color: headerColor, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
          Expanded(child: Text('\$ Evitado', style: TextStyle(color: headerColor, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
        ]),
      ),
      Divider(color: divColor),
      SizedBox(
        height: 200,
        child: ListView.separated(
          itemCount: data.length,
          separatorBuilder: (_, __) => Divider(color: divColor.withValues(alpha: 0.5), height: 1),
          itemBuilder: (_, i) {
            final row = data[i];
            final costo = row.ahorro * 0.00038;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Expanded(flex: 2, child: Text(row.label, style: TextStyle(color: textColor, fontSize: 13))),
                Expanded(child: Text('${row.consumo.toInt()}W', style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 13), textAlign: TextAlign.right)),
                Expanded(child: Text('${row.ahorro.toInt()}W', style: const TextStyle(color: Color(0xFF34D399), fontSize: 13), textAlign: TextAlign.right)),
                Expanded(child: Text('\$${costo.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 13), textAlign: TextAlign.right)),
              ]),
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildCalendar(bool isDark) {
    final textColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
    final headerColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final dayBg = isDark ? const Color(0xFF0A1628) : const Color(0xFFF8FAFC);

    final daysInMonth = DateUtils.getDaysInMonth(_calendarMonth.year, _calendarMonth.month);
    final firstWeekday = DateTime(_calendarMonth.year, _calendarMonth.month, 1).weekday; // 1=Lun

    final mesNombre = _monthName(_calendarMonth.month);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Seleccionar fecha específica:', style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      // Navegación mes
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: textColor), iconSize: 18,
          onPressed: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1)),
        ),
        Text('$mesNombre ${_calendarMonth.year}', style: TextStyle(color: headerColor, fontWeight: FontWeight.bold, fontSize: 13)),
        IconButton(
          icon: Icon(Icons.chevron_right, color: textColor), iconSize: 18,
          onPressed: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1)),
        ),
      ]),
      const SizedBox(height: 4),
      // Días de la semana
      Row(children: ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá', 'Do'].map((d) =>
          Expanded(child: Center(child: Text(d, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600))))
      ).toList()),
      const SizedBox(height: 8),
      // Grid de días
      GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.2),
        itemCount: firstWeekday - 1 + daysInMonth,
        itemBuilder: (_, i) {
          if (i < firstWeekday - 1) return const SizedBox.shrink();
          final day = i - (firstWeekday - 1) + 1;
          final date = DateTime(_calendarMonth.year, _calendarMonth.month, day);
          final isSelected = _selectedDate.year == date.year && _selectedDate.month == date.month && _selectedDate.day == date.day;
          final isToday = DateTime.now().day == day && DateTime.now().month == _calendarMonth.month && DateTime.now().year == _calendarMonth.year;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF10B981) : (isToday ? const Color(0xFF3B82F6).withValues(alpha: 0.2) : dayBg),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isToday && !isSelected ? const Color(0xFF3B82F6) : Colors.transparent),
              ),
              child: Center(child: Text('$day',
                  style: TextStyle(
                      color: isSelected ? Colors.white : textColor,
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12))),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      // Fecha seleccionada
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Fecha seleccionada:', style: TextStyle(color: textColor, fontSize: 11)),
          const SizedBox(height: 2),
          Text(_formatFechaLarga(_selectedDate), style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
      ),
    ]);
  }

  List<_PeriodRow> _getPeriodData(List<ConsumoEnergia> registros) {
    if (registros.isEmpty) return [];
    final now = DateTime.now();
    switch (_tabIndex) {
      case 0: // Día — últimas 24h por hora
        final horasMap = <int, List<double>>{};
        for (var r in registros) {
          if (r.fecha != null && r.vatios != null) {
            final diff = now.difference(r.fecha!).inHours;
            if (diff < 24) horasMap.putIfAbsent(r.fecha!.hour, () => []).add(r.vatios!);
          }
        }
        return horasMap.entries.map((e) {
          final avg = e.value.fold(0.0, (s, v) => s + v) / e.value.length;
          final ahorro = (avg - 150).clamp(0.0, double.infinity);
          return _PeriodRow(_formatHora12simple(e.key), avg, ahorro.toDouble());
        }).toList()..sort((a, b) => a.label.compareTo(b.label));

      case 1: // Semana — últimos 7 días
        return List.generate(7, (i) {
          final day = now.subtract(Duration(days: 6 - i));
          final dayRegs = registros.where((r) => r.fecha != null &&
              r.fecha!.year == day.year && r.fecha!.month == day.month && r.fecha!.day == day.day).toList();
          final total = dayRegs.fold(0.0, (s, r) => s + (r.vatios ?? 0));
          final ahorro = (total - 150 * dayRegs.length).clamp(0.0, double.infinity);
          return _PeriodRow(_formatDayShort(day), total, ahorro.toDouble());
        });

      case 2: // Mes — últimos 30 días por semana
        return List.generate(4, (i) {
          final start = now.subtract(Duration(days: (3 - i) * 7 + 6));
          final end = now.subtract(Duration(days: (3 - i) * 7));
          final weekRegs = registros.where((r) => r.fecha != null &&
              r.fecha!.isAfter(start) && r.fecha!.isBefore(end)).toList();
          final total = weekRegs.fold(0.0, (s, r) => s + (r.vatios ?? 0));
          final ahorro = (total - 150 * weekRegs.length).clamp(0.0, double.infinity);
          return _PeriodRow('Sem ${i + 1}', total, ahorro.toDouble());
        });

      default: return [];
    }
  }

  String _formatHora12simple(int hour) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final ampm = hour < 12 ? 'AM' : 'PM';
    return '$h:00 $ampm';
  }

  String _formatDayShort(DateTime d) {
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return '${dias[d.weekday - 1]} ${d.day}';
  }

  String _monthName(int m) {
    const meses = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    return meses[m - 1];
  }

  String _formatFechaLarga(DateTime d) {
    const dias = ['lunes','martes','miércoles','jueves','viernes','sábado','domingo'];
    const meses = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];
    return '${dias[d.weekday - 1]}, ${d.day} de ${meses[d.month - 1]} de ${d.year}';
  }
}

class _PeriodRow {
  final String label;
  final double consumo;
  final double ahorro;
  _PeriodRow(this.label, this.consumo, this.ahorro);
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  const _StatBox({required this.label, required this.value, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF0A1628) : const Color(0xFFF8FAFC);
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: labelColor, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
