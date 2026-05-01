import 'package:flutter/material.dart';
import '../components/dashboard_header.dart';
import '../components/energy_chart.dart';
import '../components/historial_ahorro.dart';

class EnergiaScreen extends StatelessWidget {
  const EnergiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const DashboardHeader(titulo: 'Análisis de Energía'),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const EnergyChartWidget(),
            const SizedBox(height: 20),
            const HistorialAhorro(),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    ]);
  }
}
