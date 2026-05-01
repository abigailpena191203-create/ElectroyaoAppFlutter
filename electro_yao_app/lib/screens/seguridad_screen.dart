import 'package:flutter/material.dart';
import '../components/dashboard_header.dart';

/// Placeholder — se llenará en Fase 3 con security log list
class SeguridadScreen extends StatelessWidget {
  const SeguridadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        DashboardHeader(titulo: 'Centro de Seguridad'),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security_rounded, size: 64, color: Colors.blue),
                SizedBox(height: 16),
                Text('Centro de Seguridad',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Bitácora de eventos — En construcción',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
