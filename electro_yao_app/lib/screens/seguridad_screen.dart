import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/dashboard_header.dart';
import '../components/security_log_list.dart';
import '../providers/seguridad_provider.dart';

class SeguridadScreen extends StatelessWidget {
  const SeguridadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SeguridadProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final kpiColor = isDark ? const Color(0xFF0D1F3C) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE2E8F0);
    final textColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
    final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Column(children: [
      const DashboardHeader(titulo: 'Centro de Seguridad'),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // ── Resumen de alertas ─────────────────────────────────
            Row(children: [
              _AlertKpi(
                icon: Icons.warning_amber_rounded,
                label: 'Alertas Hoy',
                value: '${provider.alertasCriticas}',
                color: Colors.red[400]!,
                bg: kpiColor, border: borderColor,
              ),
              const SizedBox(width: 12),
              _AlertKpi(
                icon: Icons.event_note_rounded,
                label: 'Total Eventos',
                value: '${provider.totalEventos}',
                color: Colors.blue[300]!,
                bg: kpiColor, border: borderColor,
              ),
              const SizedBox(width: 12),
              _AlertKpi(
                icon: Icons.today_rounded,
                label: 'Eventos Hoy',
                value: '${provider.eventosHoy}',
                color: Colors.green[400]!,
                bg: kpiColor, border: borderColor,
              ),
            ]),
            const SizedBox(height: 20),

            // ── Log completo con filtros ───────────────────────────
            const SecurityLogList(maxItems: 100),
            const SizedBox(height: 32),

            // ── Placeholder de Usuarios ────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kpiColor, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(children: [
                Icon(Icons.group_rounded, size: 48, color: isDark ? const Color(0xFF4A6FA5) : Colors.grey[400]),
                const SizedBox(height: 12),
                Text('Gestión de Usuarios', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text('Próximamente — Panel de administración de roles y accesos', style: TextStyle(color: subColor, fontSize: 13), textAlign: TextAlign.center),
              ]),
            ),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    ]);
  }
}

class _AlertKpi extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;
  final Color border;
  const _AlertKpi({required this.icon, required this.label, required this.value, required this.color, required this.bg, required this.border});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}
