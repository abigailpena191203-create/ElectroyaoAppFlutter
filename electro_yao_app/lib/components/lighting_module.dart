import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/dispositivos_provider.dart';

class LightingModule extends StatefulWidget {
  const LightingModule({super.key});

  @override
  State<LightingModule> createState() => _LightingModuleState();
}

class _LightingModuleState extends State<LightingModule> {
  Widget _buildLightControl(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isOn,
    required ValueChanged<bool> onToggle,
    bool hasAutoMode = false,
    bool isAutoMode = false,
    VoidCallback? onAutoModeToggle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.5)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.grey.shade100
                          : Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
              Opacity(
                opacity: isAutoMode ? 0.5 : 1.0,
                child: Switch(
                  value: isOn,
                  onChanged: isAutoMode ? null : onToggle,
                  activeThumbColor: Colors.yellow,
                  activeTrackColor: Colors.yellow.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          if (hasAutoMode)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isAutoMode
                          ? (isDark
                                ? Colors.blue.withValues(alpha: 0.2)
                                : Colors.blue.shade100)
                          : (isDark
                                ? Colors.orange.withValues(alpha: 0.2)
                                : Colors.orange.shade100),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAutoMode
                            ? (isDark
                                  ? Colors.blue.withValues(alpha: 0.3)
                                  : Colors.blue.shade300)
                            : (isDark
                                  ? Colors.orange.withValues(alpha: 0.3)
                                  : Colors.orange.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isAutoMode ? Icons.memory : Icons.back_hand,
                          size: 12,
                          color: isAutoMode
                              ? (isDark
                                    ? Colors.blue.shade400
                                    : Colors.blue.shade700)
                              : (isDark
                                    ? Colors.orange.shade400
                                    : Colors.orange.shade700),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAutoMode ? 'Auto' : 'Manual',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isAutoMode
                                ? (isDark
                                      ? Colors.blue.shade400
                                      : Colors.blue.shade700)
                                : (isDark
                                      ? Colors.orange.shade400
                                      : Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: onAutoModeToggle,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.green.withValues(alpha: 0.4)
                              : Colors.green.shade300,
                        ),
                      ),
                      child: Text(
                        'Cambiar',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.green.shade400
                              : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!hasAutoMode)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155).withValues(alpha: 0.5)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.back_hand,
                      size: 12,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Solo Manual',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: isOn
                    ? [
                        BoxShadow(
                          color: Colors.yellowAccent.withValues(alpha: 0.6),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                Icons.lightbulb,
                size: 48,
                color: isOn
                    ? Colors.yellowAccent
                    : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              isOn ? 'Encendida' : 'Apagada',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isOn
                    ? Colors.yellow.shade600
                    : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final dispProvider = Provider.of<DispositivosProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final ventasOn = dispProvider.isDispositivoOn('Área de Ventas');
    final ventasManual = dispProvider.isDispositivoManual('Área de Ventas');

    final almacenOn = dispProvider.isDispositivoOn('Almacén');
    final almacenManual = dispProvider.isDispositivoManual('Almacén');

    final cajaOn = dispProvider.isDispositivoOn('Caja/Oficina');
    final cajaManual = dispProvider.isDispositivoManual('Caja/Oficina');

    return Card(
      elevation: isDark ? 0 : 4,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Theme.of(context).dividerColor : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sistema de Iluminación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey.shade100 : Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 16),
            _buildLightControl(
              context,
              icon: Icons.storefront,
              label: 'Área de Ventas',
              isOn: ventasOn,
              hasAutoMode: true,
              isAutoMode: !ventasManual,
              isDark: isDark,
              onToggle: (val) {
                dispProvider.toggleDispositivo('Área de Ventas', val);
              },
              onAutoModeToggle: () async {
                await dispProvider.toggleAutoMode('Área de Ventas');
              },
            ),
            _buildLightControl(
              context,
              icon: Icons.inventory_2,
              label: 'Almacén',
              isOn: almacenOn,
              hasAutoMode: true,
              isAutoMode: !almacenManual,
              isDark: isDark,
              onToggle: (val) {
                dispProvider.toggleDispositivo('Almacén', val);
              },
              onAutoModeToggle: () async {
                await dispProvider.toggleAutoMode('Almacén');
              },
            ),
            _buildLightControl(
              context,
              icon: Icons.attach_money,
              label: 'Caja/Oficina',
              isOn: cajaOn,
              hasAutoMode: false,
              isDark: isDark,
              onToggle: (val) {
                dispProvider.toggleDispositivo('Caja/Oficina', val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
