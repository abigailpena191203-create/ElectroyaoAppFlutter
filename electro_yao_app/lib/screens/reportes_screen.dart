import 'package:flutter/material.dart';
import '../components/dashboard_header.dart';

/// Placeholder — se llenará en Fase 4 con PDF generation
class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        DashboardHeader(titulo: 'Gestión y Reportes'),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_rounded, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text('Gestión y Reportes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Generación de PDF y usuarios — En construcción',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
