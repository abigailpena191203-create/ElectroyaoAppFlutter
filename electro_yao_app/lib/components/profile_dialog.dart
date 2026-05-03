import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final authP = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D142B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Foto de Perfil con borde neón
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.greenAccent],
                ),
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  'https://ebayhfmrzbwtgscwvgxm.supabase.co/storage/v1/object/public/perfil_creadora/photo_2026-05-03_03-15-46.jpg',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Abigail Peña',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ingeniera en sistemas',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[600], // Azul solicitado
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // --- Selector de Roles (Simulador RBAC) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<UserRole>(
                  value: authP.role,
                  isExpanded: true,
                  icon: const Icon(Icons.shield_rounded, color: Colors.blue),
                  items: UserRole.values.map((role) {
                    String label = '';
                    switch (role) {
                      case UserRole.administrador: label = 'Administrador (Total)'; break;
                      case UserRole.ventas: label = 'Ventas (Limitado)'; break;
                      case UserRole.seguridad: label = 'Seguridad (Limitado)'; break;
                    }
                    return DropdownMenuItem(
                      value: role,
                      child: Text(label, style: TextStyle(color: textColor, fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (newRole) {
                    if (newRole != null) authP.setRole(newRole);
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Ingeniera apasionada por la domótica y el ahorro energético. "Diseñando el futuro, vatio a vatio".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            // Botones de Acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchURL('https://wa.me/tu_numero_aqui'),
                    icon: const Icon(Icons.message_rounded),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launchURL('https://portfolio-placeholder.com'),
                    icon: const Icon(Icons.link_rounded),
                    label: const Text('Portafolio'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: isDark ? Colors.blue[300]! : Colors.blue[700]!),
                      foregroundColor: isDark ? Colors.blue[300] : Colors.blue[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
