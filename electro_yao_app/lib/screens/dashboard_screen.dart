import 'package:flutter/material.dart';
import '../components/dashboard_header.dart';
import '../components/dispositivos_list.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Se utiliza un Column en lugar de un AppBar tradicional para tener control 
      // absoluto sobre el header personalizado que migramos desde React
      body: Column(
        children: [
          // 1. Header principal (Gradientes, título, modo oscuro)
          const DashboardHeader(),
          
          // 2. Contenedor del Dashboard (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODO: KPI Panel
                  // TODO: Módulos (Iluminación, Seguridad, Plano del Local)
                  // TODO: Gráficos y Logs de Eventos
                  
                  const Text(
                    'Vista Previa (Dispositivos en Supabase)',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Temporalmente ponemos la lista de dispositivos dentro de un Container
                  // ya que al usar un ListView dentro de un SingleChildScrollView, 
                  // necesitamos definir una altura o usar shrinkWrap.
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                    ),
                    child: const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      child: DispositivosList(),
                    ),
                  ),
                  
                  const SizedBox(height: 32), // Espacio extra al final
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
