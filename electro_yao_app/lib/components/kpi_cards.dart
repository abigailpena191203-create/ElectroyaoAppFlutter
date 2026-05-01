import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/energia_provider.dart';
import '../providers/dispositivos_provider.dart';
import '../providers/seguridad_provider.dart';
import 'shimmer_loader.dart';

class KpiCards extends StatelessWidget {
  const KpiCards({super.key});

  @override
  Widget build(BuildContext context) {
    final energiaP = context.watch<EnergiaProvider>();
    final dispositivosP = context.watch<DispositivosProvider>();
    final seguridadP = context.watch<SeguridadProvider>();

    final isLoading = energiaP.isLoading;
    final consumoActual = energiaP.consumoActual;
    final ahorroMensual = consumoActual * 0.03;
    final dispositivosActivos = dispositivosP.dispositivos.where((d) {
      final e = d.estado?.toLowerCase().trim() ?? '';
      return e == 'activo' || e == 'encendido';
    }).length;
    final totalDispositivos = dispositivosP.dispositivos.length;
    final eficiencia = consumoActual > 0 && consumoActual <= 250
        ? ((1 - consumoActual / 250) * 100).clamp(0.0, 100.0)
        : 0.0;
    final alertasHoy = seguridadP.eventosHoy;

    final cards = [
      _KpiCard(
        isLoading: isLoading,
        icon: Icons.bolt_rounded,
        iconBg: const Color(0xFF1D4ED8),
        label: 'CONSUMO ACTUAL',
        value: '${consumoActual.toStringAsFixed(0)} W',
        badge: null,
        trailing: _PulseIndicator(color: Colors.blue[300]!),
      ),
      _KpiCard(
        isLoading: isLoading,
        icon: Icons.savings_rounded,
        iconBg: const Color(0xFF059669),
        label: 'AHORRO MENSUAL',
        value: '\$${ahorroMensual.toStringAsFixed(2)}',
        badge: null,
        trailing: _PulseIndicator(color: Colors.green[300]!),
      ),
      _KpiCard(
        isLoading: isLoading,
        icon: Icons.show_chart_rounded,
        iconBg: const Color(0xFF7C3AED),
        label: 'EFICIENCIA',
        value: '${eficiencia.toStringAsFixed(0)}%',
        badge: eficiencia >= 80 ? 'ÓPTIMO' : (eficiencia >= 50 ? 'NORMAL' : 'ALTO'),
        badgeColor: eficiencia >= 80 ? const Color(0xFF059669) : (eficiencia >= 50 ? const Color(0xFFF59E0B) : Colors.red),
        trailing: null,
      ),
      _KpiCard(
        isLoading: isLoading,
        icon: Icons.power_settings_new_rounded,
        iconBg: const Color(0xFF0F172A),
        label: 'DISPOSITIVOS',
        value: alertasHoy > 0 ? '$alertasHoy alertas' : '$dispositivosActivos/$totalDispositivos activos',
        valueColor: alertasHoy > 0 ? Colors.red[300] : const Color(0xFF34D399),
        trailing: CircleAvatar(
          radius: 5,
          backgroundColor: alertasHoy > 0 ? Colors.red[400] : const Color(0xFF34D399),
        ),
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          children: cards,
        );
      }
      return Row(
        children: cards.asMap().entries.map((e) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: e.key < cards.length - 1 ? 12 : 0),
            child: e.value,
          ),
        )).toList(),
      );
    });
  }
}

class _KpiCard extends StatelessWidget {
  final bool isLoading;
  final IconData icon;
  final Color iconBg;
  final String label;
  final String value;
  final Color? valueColor;
  final String? badge;
  final Color? badgeColor;
  final Widget? trailing;

  const _KpiCard({
    required this.isLoading,
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
    this.valueColor,
    this.badge,
    this.badgeColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0D1F3C) : Colors.white;
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final textColor = valueColor ?? (isDark ? Colors.white : const Color(0xFF0F172A));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E3A5F).withValues(alpha: 0.6) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: isLoading
          ? const ShimmerBox(height: 90)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor!.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: badgeColor!.withValues(alpha: 0.4)),
                        ),
                        child: Text(badge!, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    else if (trailing != null)
                      trailing!,
                  ],
                ),
                const SizedBox(height: 14),
                Text(label, style: TextStyle(color: labelColor, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              ],
            ),
    );
  }
}

class _PulseIndicator extends StatefulWidget {
  final Color color;
  const _PulseIndicator({required this.color});

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(opacity: _anim.value, child: CircleAvatar(radius: 5, backgroundColor: widget.color)),
    );
  }
}
