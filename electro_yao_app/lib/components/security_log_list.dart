import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/seguridad_provider.dart';
import '../providers/theme_provider.dart';
import '../models/log_seguridad.dart';
import 'shimmer_loader.dart';

class SecurityLogList extends StatefulWidget {
  final int maxItems;
  const SecurityLogList({super.key, this.maxItems = 50});

  @override
  State<SecurityLogList> createState() => _SecurityLogListState();
}

class _SecurityLogListState extends State<SecurityLogList> {
  String _filtro = 'Todos'; // Todos, Hoy, Semana
  DateTime? _fechaSeleccionada;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SeguridadProvider>();
    final isDark = context.select<ThemeProvider, bool>((tp) => tp.isDarkMode);
    final cardBg = isDark ? const Color(0xFF0D1F3C) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE2E8F0);

    final logsFiltered = _filtrarLogs(provider.logs);

    return Container(
      decoration: BoxDecoration(
        color: cardBg, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Icon(Icons.history_rounded, color: Colors.blue[300], size: 20),
            const SizedBox(width: 8),
            Text('Registro de Eventos',
                style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold, fontSize: 15)),
          ]),
          Text('${logsFiltered.length} eventos',
              style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey, fontSize: 12)),
        ]),
        const SizedBox(height: 16),
        // Filtros
        _buildFiltros(isDark),
        const SizedBox(height: 16),
        // Lista
        RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (provider.isLoading)
                const ShimmerList(itemCount: 5)
              else if (logsFiltered.isEmpty)
                _buildEmpty(isDark)
              else
                ...logsFiltered.take(widget.maxItems).map((log) => _LogTile(log: log, isDark: isDark)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildFiltros(bool isDark) {
    final opciones = ['Todos', 'Hoy', 'Semana'];
    return Row(children: [
      ...opciones.map((op) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: _FilterChip(
          label: op,
          selected: _filtro == op,
          isDark: isDark,
          onTap: () => setState(() { _filtro = op; _fechaSeleccionada = null; }),
        ),
      )),
      // Picker de fecha
      _FilterChip(
        label: _fechaSeleccionada != null
            ? '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}'
            : '📅',
        selected: _fechaSeleccionada != null,
        isDark: isDark,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _fechaSeleccionada ?? DateTime.now(),
            firstDate: DateTime(2024),
            lastDate: DateTime.now(),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: const ColorScheme.dark(primary: Color(0xFF3B82F6)),
              ),
              child: child!,
            ),
          );
          if (picked != null) setState(() { _fechaSeleccionada = picked; _filtro = ''; });
        },
      ),
    ]);
  }

  List<LogSeguridad> _filtrarLogs(List<LogSeguridad> logs) {
    final now = DateTime.now();
    if (_fechaSeleccionada != null) {
      return logs.where((l) => l.fechaHora != null &&
          l.fechaHora!.year == _fechaSeleccionada!.year &&
          l.fechaHora!.month == _fechaSeleccionada!.month &&
          l.fechaHora!.day == _fechaSeleccionada!.day).toList();
    }
    switch (_filtro) {
      case 'Hoy':
        return logs.where((l) => l.fechaHora != null &&
            l.fechaHora!.year == now.year && l.fechaHora!.month == now.month && l.fechaHora!.day == now.day).toList();
      case 'Semana':
        final weekAgo = now.subtract(const Duration(days: 7));
        return logs.where((l) => l.fechaHora != null && l.fechaHora!.isAfter(weekAgo)).toList();
      default:
        return logs;
    }
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          Icon(Icons.inbox_rounded, size: 48, color: isDark ? const Color(0xFF4A6FA5) : Colors.grey[400]),
          const SizedBox(height: 8),
          Text('Sin eventos en este período', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey)),
        ]),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3B82F6) : (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(0xFF3B82F6) : Colors.transparent),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                fontSize: 12, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final LogSeguridad log;
  final bool isDark;
  const _LogTile({required this.log, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getIconAndColor(log.tipoEvento);
    final tileBg = isDark ? const Color(0xFF0A1628) : const Color(0xFFF8FAFC);
    final timeColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final textColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(log.evento, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500)),
              if (log.detalles != null)
                Text(log.detalles!, style: TextStyle(color: timeColor, fontSize: 11), overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 8),
          Text(
            log.fechaHora != null ? _formatHora12(log.fechaHora!) : '--',
            style: TextStyle(color: timeColor, fontSize: 11),
          ),
        ]),
      ),
    );
  }

  (IconData, Color) _getIconAndColor(LogEventType tipo) {
    switch (tipo) {
      case LogEventType.armed:    return (Icons.lock_rounded, Colors.blue[400]!);
      case LogEventType.disarmed: return (Icons.lock_open_rounded, Colors.green[400]!);
      case LogEventType.alert:    return (Icons.warning_amber_rounded, Colors.red[400]!);
      case LogEventType.access:   return (Icons.person_rounded, Colors.orange[400]!);
      case LogEventType.info:     return (Icons.info_rounded, Colors.grey[400]!);
    }
  }

  String _formatHora12(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m:$s $ampm';
  }
}
