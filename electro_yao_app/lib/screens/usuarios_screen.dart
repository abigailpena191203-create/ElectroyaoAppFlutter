import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/seguridad_provider.dart';
import '../models/usuario.dart';

class UsuariosScreen extends StatelessWidget {
  const UsuariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SeguridadProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.usuarios.length,
              itemBuilder: (context, index) {
                final u = provider.usuarios[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isDark ? const Color(0xFF0D142B) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      child: Text(u.nombre[0].toUpperCase(), style: const TextStyle(color: Colors.blue)),
                    ),
                    title: Text(u.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${u.email} • ${u.rol}'),
                    trailing: Switch(
                      value: u.isActive,
                      onChanged: (val) => provider.toggleEstadoUsuario(u.id),
                      activeColor: Colors.greenAccent,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
