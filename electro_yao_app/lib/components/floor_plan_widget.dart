import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dispositivos_provider.dart';

/// Plano de Sucursal 2 con puntos reactivos al estado de los dispositivos
class FloorPlanWidget extends StatelessWidget {
  const FloorPlanWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DispositivosProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ventasOn = _isOn(provider, 'Área de Ventas');
    final almacenOn = _isOn(provider, 'Almacén');
    final cajaOn = _isOn(provider, 'Caja/Oficina');
    final cerraduraOn = _isOn(provider, 'Cerradura Electrónica');

    final cardBg = isDark ? const Color(0xFF0D1F3C) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE2E8F0);
    final roomBorder = isDark ? const Color(0xFF2A4A7F) : const Color(0xFFCBD5E1);
    final roomBg = isDark ? const Color(0xFF0A1628) : const Color(0xFFF1F5F9);
    final textColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.store_mall_directory_rounded, color: Colors.blue[300], size: 18),
            const SizedBox(width: 8),
            Text('Plano - Sucursal 2', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
          const SizedBox(height: 16),
          // Layout del plano
          Column(children: [
            // Área de Ventas (superior, ancho completo)
            _RoomTile(
              label: 'Área de Ventas',
              isOn: ventasOn,
              roomBg: roomBg,
              roomBorder: roomBorder,
              textColor: textColor,
              suffix: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cerraduraOn ? Colors.green.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cerraduraOn ? Colors.green : Colors.grey),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.login_rounded, size: 10, color: cerraduraOn ? Colors.green : Colors.grey),
                  const SizedBox(width: 4),
                  Text('ENTRADA', style: TextStyle(color: cerraduraOn ? Colors.green : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            // Almacén y Caja/Oficina (inferior, mitad cada uno)
            Row(children: [
              Expanded(child: _RoomTile(label: 'Almacén', isOn: almacenOn, roomBg: roomBg, roomBorder: roomBorder, textColor: textColor)),
              const SizedBox(width: 8),
              Expanded(child: _RoomTile(label: 'Caja/Oficina', isOn: cajaOn, roomBg: roomBg, roomBorder: roomBorder, textColor: textColor)),
            ]),
          ]),
          const SizedBox(height: 12),
          // Leyenda
          Row(children: [
            _Legend(color: Colors.green[400]!, label: 'Encendido'),
            const SizedBox(width: 16),
            _Legend(color: Colors.grey[600]!, label: 'Apagado'),
          ]),
        ],
      ),
    );
  }

  bool _isOn(DispositivosProvider p, String area) {
    final d = p.getDispositivoByArea(area);
    if (d == null) return false;
    final e = d.estado?.toLowerCase().trim() ?? '';
    return e == 'activo' || e == 'encendido';
  }
}

class _RoomTile extends StatelessWidget {
  final String label;
  final bool isOn;
  final Color roomBg;
  final Color roomBorder;
  final Color textColor;
  final Widget? suffix;

  const _RoomTile({
    required this.label,
    required this.isOn,
    required this.roomBg,
    required this.roomBorder,
    required this.textColor,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = isOn ? Colors.green[400]! : Colors.grey[600]!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isOn ? Colors.green.withValues(alpha: 0.06) : roomBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isOn ? Colors.green.withValues(alpha: 0.4) : roomBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
          ),
          if (suffix != null) suffix!
          else AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8, height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle,
              boxShadow: isOn ? [BoxShadow(color: Colors.green.withValues(alpha: 0.5), blurRadius: 6)] : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CircleAvatar(radius: 4, backgroundColor: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: color, fontSize: 10)),
    ]);
  }
}
