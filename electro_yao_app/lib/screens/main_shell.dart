import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/log_seguridad.dart';
import '../providers/seguridad_provider.dart';
import 'dashboard_screen.dart';
import 'energia_screen.dart';
import 'seguridad_screen.dart';
import 'reportes_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.bolt_rounded, label: 'Energía'),
    _NavItem(icon: Icons.security_rounded, label: 'Seguridad'),
    _NavItem(icon: Icons.description_rounded, label: 'Reportes'),
  ];

  // IndexedStack mantiene todos los widgets vivos → Providers NUNCA pierden conexión
  static const _screens = [
    DashboardScreen(),
    EnergiaScreen(),
    SeguridadScreen(),
    ReportesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Escuchar nuevos logs para mostrar notificación In-App
    final seguridadProvider = Provider.of<SeguridadProvider>(context);
    _escucharAlertasSeguridad(context, seguridadProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        if (isWide) {
          return _buildWithRail();
        } else {
          return _buildWithBottomNav();
        }
      },
    );
  }

  Widget _buildWithRail() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // ---- Navigation Rail (Web / Tablet) ----
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType: NavigationRailLabelType.all,
            backgroundColor: isDark
                ? const Color(0xFF0D142B)
                : const Color(0xFF1E3A8A),
            selectedIconTheme: IconThemeData(
              color: isDark ? Colors.blue[300] : Colors.white,
              size: 26,
            ),
            unselectedIconTheme: IconThemeData(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.6),
              size: 22,
            ),
            selectedLabelTextStyle: TextStyle(
              color: isDark ? Colors.blue[300] : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
            leading: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Column(
                children: [
                  Icon(Icons.memory, color: Colors.blue[300], size: 28),
                  const Icon(Icons.bolt, color: Colors.yellowAccent, size: 14),
                ],
              ),
            ),
            destinations: _destinations
                .map((d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      label: Text(d.label),
                    ))
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // ---- Contenido principal ----
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithBottomNav() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: isDark
            ? const Color(0xFF0D142B)
            : const Color(0xFF1E3A8A),
        indicatorColor: isDark
            ? Colors.blue.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.25),
        destinations: _destinations
            .map((d) => NavigationDestination(
                  icon: Icon(d.icon,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.7)),
                  selectedIcon: Icon(d.icon,
                      color: isDark ? Colors.blue[300] : Colors.white),
                  label: d.label,
                ))
            .toList(),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
    );
  }

  int _lastLogCount = 0;
  void _escucharAlertasSeguridad(
      BuildContext context, SeguridadProvider provider) {
    final count = provider.logs.length;
    if (_lastLogCount > 0 && count > _lastLogCount && provider.logs.isNotEmpty) {
      final nuevoLog = provider.logs.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: nuevoLog.tipoEvento == LogEventType.alert
                  ? Colors.red[700]
                  : Colors.blue[800],
              content: Row(
                children: [
                  Icon(
                    nuevoLog.tipoEvento == LogEventType.alert
                        ? Icons.warning_amber_rounded
                        : Icons.security_rounded,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '🚨 ${nuevoLog.evento}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      });
    }
    _lastLogCount = count;
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
