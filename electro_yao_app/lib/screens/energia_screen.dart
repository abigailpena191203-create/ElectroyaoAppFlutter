import 'package:flutter/material.dart';
import '../components/dashboard_header.dart';

/// Placeholder — se llenará en Fase 3 con fl_chart
class EnergiaScreen extends StatelessWidget {
  const EnergiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        DashboardHeader(titulo: 'Análisis de Energía'),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt_rounded, size: 64, color: Colors.amber),
                SizedBox(height: 16),
                Text('Módulo de Energía',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Gráficas de consumo — En construcción',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
