import 'package:flutter/material.dart';
import '../components/dashboard_header.dart';
import '../components/kpi_cards.dart';
import '../components/lighting_module.dart';
import '../components/security_module.dart';
import '../components/floor_plan_widget.dart';
import '../components/energy_chart.dart';
import '../components/security_log_list.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const DashboardHeader(),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── KPI Cards ──────────────────────────────────────────
            const KpiCards(),
            const SizedBox(height: 20),

            // ── Módulos de Control (Iluminación | Seguridad | Plano) ──
            LayoutBuilder(builder: (ctx, constraints) {
              if (constraints.maxWidth > 900) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: LightingModule()),
                    SizedBox(width: 16),
                    Expanded(flex: 2, child: SecurityModule()),
                    SizedBox(width: 16),
                    Expanded(flex: 2, child: FloorPlanWidget()),
                  ],
                );
              }
              if (constraints.maxWidth > 550) {
                return const Column(children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: LightingModule()),
                    SizedBox(width: 16),
                    Expanded(child: SecurityModule()),
                  ]),
                  SizedBox(height: 16),
                  FloorPlanWidget(),
                ]);
              }
              return const Column(children: [
                LightingModule(),
                SizedBox(height: 16),
                SecurityModule(),
                SizedBox(height: 16),
                FloorPlanWidget(),
              ]);
            }),
            const SizedBox(height: 20),

            // ── Gráfica + Log de Eventos ────────────────────────────
            LayoutBuilder(builder: (ctx, constraints) {
              if (constraints.maxWidth > 800) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: EnergyChartWidget()),
                    SizedBox(width: 16),
                    Expanded(flex: 2, child: SecurityLogList(maxItems: 6)),
                  ],
                );
              }
              return const Column(children: [
                EnergyChartWidget(),
                SizedBox(height: 16),
                SecurityLogList(maxItems: 4),
              ]);
            }),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    ]);
  }
}
