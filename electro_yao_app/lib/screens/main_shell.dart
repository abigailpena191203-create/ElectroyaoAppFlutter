import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/log_seguridad.dart';
import '../providers/seguridad_provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'energia_screen.dart';
import 'seguridad_screen.dart';
import 'reportes_screen.dart';
import 'usuarios_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Inicio'),
    _NavItem(icon: Icons.bolt_rounded, label: 'Energía'),
    _NavItem(icon: Icons.security_rounded, label: 'Seguridad'),
    _NavItem(icon: Icons.description_rounded, label: 'Reportes'),
    _NavItem(icon: Icons.people_rounded, label: 'Gestión de Usuarios'),
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
    final authP = context.watch<AuthProvider>();
    // Filtrar destinos basados en rol
    final visibleDestinations = _destinations.where((d) => authP.canAccess(d.label)).toList();
    
    // Ajustar el índice si la pantalla actual ya no es accesible
    if (_selectedIndex >= visibleDestinations.length) {
      _selectedIndex = 0;
    }

    // Escuchar nuevos logs para mostrar notificación In-App
    final seguridadProvider = Provider.of<SeguridadProvider>(context);
    _escucharAlertasSeguridad(context, seguridadProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF0D142B) : const Color(0xFF1E3A8A),
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.memory, color: Colors.blue[300], size: 48),
                    const SizedBox(height: 8),
                    const Text('ElectroYao V1.0', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    if (authP.role != UserRole.administrador)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Modo: ${authP.roleName}',
                          style: TextStyle(color: Colors.blue[200], fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            ...visibleDestinations.asMap().entries.map((e) => ListTile(
              leading: Icon(e.value.icon, color: _selectedIndex == e.key ? Colors.blue[300] : Colors.white70),
              title: Text(e.value.label, style: TextStyle(color: _selectedIndex == e.key ? Colors.blue[300] : Colors.white70, fontWeight: _selectedIndex == e.key ? FontWeight.bold : FontWeight.normal)),
              selected: _selectedIndex == e.key,
              selectedTileColor: Colors.white.withValues(alpha: 0.05),
              onTap: () {
                setState(() => _selectedIndex = e.key);
                Navigator.pop(context); // Close drawer
              },
            )),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: visibleDestinations.map((d) => _getScreen(d.label)).toList(),
      ),
    );
  }

  Widget _getScreen(String label) {
    switch (label) {
      case 'Inicio': return const DashboardScreen();
      case 'Energía': return const EnergiaScreen();
      case 'Seguridad': return const SeguridadScreen();
      case 'Reportes': return const ReportesScreen();
      case 'Gestión de Usuarios': return const UsuariosScreen();
      default: return const DashboardScreen();
    }
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
