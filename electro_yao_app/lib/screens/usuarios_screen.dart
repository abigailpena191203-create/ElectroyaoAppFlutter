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
        title: const Text('Gestión de Usuarios', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                
                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 2 : 1,
                    childAspectRatio: isDesktop ? 3 : 2.5,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    mainAxisExtent: 140, // Altura fija para las tarjetas
                  ),
                  itemCount: provider.usuarios.length,
                  itemBuilder: (context, index) {
                    final u = provider.usuarios[index];
                    return _UsuarioCard(usuario: u, isDark: isDark);
                  },
                );
              },
            ),
    );
  }
}

class _UsuarioCard extends StatelessWidget {
  final Usuario usuario;
  final bool isDark;

  const _UsuarioCard({required this.usuario, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SeguridadProvider>();
    final isActivo = usuario.isActive;
    
    // Colores Neon
    final Color neonColor = isActivo ? const Color(0xFF00E5FF) : const Color(0xFFFF3D00); // Cian o Rojo Neón

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D142B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: neonColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: neonColor.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isActivo 
                      ? [neonColor, Colors.blue] 
                      : [neonColor, Colors.red[900]!],
                ),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: neonColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  usuario.nombre[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    usuario.nombre,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      usuario.rol,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.blue[300] : Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Actions
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: neonColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: neonColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    isActivo ? 'ACTIVO' : 'BLOQUEADO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: neonColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Switch(
                  value: isActivo,
                  onChanged: (val) => provider.toggleEstadoUsuario(usuario.id),
                  activeColor: const Color(0xFF00E5FF),
                  inactiveThumbColor: const Color(0xFFFF3D00),
                  inactiveTrackColor: const Color(0xFFFF3D00).withValues(alpha: 0.3),
                  activeTrackColor: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
