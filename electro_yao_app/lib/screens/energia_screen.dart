import 'package:flutter/material.dart';
import '../components/dashboard_header.dart';
import '../components/energy_chart.dart';
import '../components/historial_ahorro.dart';
import '../components/metas_ahorro.dart';
import 'package:provider/provider.dart';
import '../providers/energia_provider.dart';

class EnergiaScreen extends StatelessWidget {
  const EnergiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final energiaP = context.watch<EnergiaProvider>();
    final consumoActual = energiaP.consumoActual;
    final ahorroMensual = consumoActual * 0.03; // Mock calc

    return Column(children: [
      const DashboardHeader(titulo: 'Análisis de Energía'),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const EnergyChartWidget(),
            const SizedBox(height: 20),
            MetasAhorroWidget(
              ahorroMensual: energiaP.ahorroActualMensual,
              metaAhorro: energiaP.metaAhorroMensual,
              consumoActual: energiaP.consumoActual,
              limiteConsumo: energiaP.limiteConsumo,
              diasRestantes: energiaP.diasRestantesMes,
              promedioDiario: energiaP.promedioDiarioAhorro,
            ),
            const SizedBox(height: 20),
            const HistorialAhorro(),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    ]);
  }
}
