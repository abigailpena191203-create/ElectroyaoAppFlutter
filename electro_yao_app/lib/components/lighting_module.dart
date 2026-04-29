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
  // Estado temporal local para el auto mode
  bool _ventasAutoMode = true;
  bool _almacenAutoMode = true;

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
        color: isDark ? const Color(0xFF0F172A).withOpacity(0.5) : Colors.grey.shade50,
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
                  Icon(icon, size: 20, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey.shade100 : Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
              Switch(
                value: isOn,
                onChanged: onToggle,
                activeColor: Colors.yellow,
                activeTrackColor: Colors.yellow.withOpacity(0.3),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAutoMode
                          ? (isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade100)
                          : (isDark ? Colors.orange.withOpacity(0.2) : Colors.orange.shade100),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAutoMode
                            ? (isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.shade300)
                            : (isDark ? Colors.orange.withOpacity(0.3) : Colors.orange.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isAutoMode ? Icons.memory : Icons.back_hand,
                          size: 12,
                          color: isAutoMode
                              ? (isDark ? Colors.blue.shade400 : Colors.blue.shade700)
                              : (isDark ? Colors.orange.shade400 : Colors.orange.shade700),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAutoMode ? 'Auto' : 'Manual',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isAutoMode
                                ? (isDark ? Colors.blue.shade400 : Colors.blue.shade700)
                                : (isDark ? Colors.orange.shade400 : Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: onAutoModeToggle,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.green.withOpacity(0.4) : Colors.green.shade300,
                        ),
                      ),
                      child: Text(
                        'Cambiar',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.green.shade400 : Colors.green.shade700,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155).withOpacity(0.5) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.back_hand, size: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Solo Manual',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Center(
            child: Icon(
              Icons.lightbulb,
              size: 48,
              color: isOn
                  ? Colors.yellowAccent
                  : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
              shadows: isOn
                  ? [
                      Shadow(
                        color: Colors.yellowAccent.withOpacity(0.8),
                        blurRadius: 20,
                      )
                    ]
                  : null,
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
    final almacenOn = dispProvider.isDispositivoOn('Almacén');
    final cajaOn = dispProvider.isDispositivoOn('Caja');

    return Card(
      elevation: isDark ? 0 : 4,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155).withOpacity(0.6) : Colors.grey.shade200,
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
              isAutoMode: _ventasAutoMode,
              isDark: isDark,
              onToggle: (val) {
                dispProvider.toggleDispositivo('Área de Ventas', val);
              },
              onAutoModeToggle: () {
                setState(() {
                  _ventasAutoMode = !_ventasAutoMode;
                });
              },
            ),
            _buildLightControl(
              context,
              icon: Icons.inventory_2,
              label: 'Almacén',
              isOn: almacenOn,
              hasAutoMode: true,
              isAutoMode: _almacenAutoMode,
              isDark: isDark,
              onToggle: (val) {
                dispProvider.toggleDispositivo('Almacén', val);
              },
              onAutoModeToggle: () {
                setState(() {
                  _almacenAutoMode = !_almacenAutoMode;
                });
              },
            ),
            _buildLightControl(
              context,
              icon: Icons.attach_money,
              label: 'Caja',
              isOn: cajaOn,
              hasAutoMode: false,
              isDark: isDark,
              onToggle: (val) {
                dispProvider.toggleDispositivo('Caja', val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
