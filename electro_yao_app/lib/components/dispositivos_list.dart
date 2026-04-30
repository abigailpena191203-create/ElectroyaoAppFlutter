import 'package:flutter/material.dart';
import '../models/dispositivo.dart';
import '../services/supabase_service.dart';

class DispositivosList extends StatefulWidget {
  const DispositivosList({super.key});

  @override
  State<DispositivosList> createState() => _DispositivosListState();
}

class _DispositivosListState extends State<DispositivosList> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Dispositivo>> _dispositivosFuture;

  @override
  void initState() {
    super.initState();
    _dispositivosFuture = _supabaseService.getDispositivos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Dispositivo>>(
      future: _dispositivosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay dispositivos.'));
        }

        final dispositivos = snapshot.data!;

        return ListView.builder(
          itemCount: dispositivos.length,
          itemBuilder: (context, index) {
            final disp = dispositivos[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              shadowColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.devices),
                title: Text(
                  disp.nombreArea,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(disp.ubicacion ?? 'Sin ubicación'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: disp.estado == 'Activo'
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: disp.estado == 'Activo'
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                  child: Text(
                    disp.estado ?? 'Desconocido',
                    style: TextStyle(
                      color: disp.estado == 'Activo'
                          ? Colors.green
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
