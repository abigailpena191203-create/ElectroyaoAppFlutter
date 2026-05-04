import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/dispositivos_provider.dart';
import '../providers/auth_provider.dart';

class SecurityModule extends StatelessWidget {
  const SecurityModule({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final dispProvider = Provider.of<DispositivosProvider>(context);
    final authP = Provider.of<AuthProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isAuthorized = authP.canAccess('Seguridad');

    final isArmed = dispProvider.isDispositivoOn('Cerradura Electrónica');
    final isManual = dispProvider.isDispositivoManual('Cerradura Electrónica');
    final isAutoMode = !isManual;

    return Card(
      elevation: isDark ? 0 : 4,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Theme.of(context).dividerColor : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cerradura Electrónica',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade100 : Colors.grey.shade900,
                  ),
                ),
                Opacity(
                  opacity: (isAutoMode || !isAuthorized) ? 0.5 : 1.0,
                  child: Tooltip(
                    message: !isAuthorized ? "Acceso restringido para su rol" : "",
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Switch(
                        value: isArmed,
                        onChanged: (isAutoMode || !isAuthorized)
                            ? null
                            : (val) {
                                dispProvider.toggleDispositivo(
                                  'Cerradura Electrónica',
                                  val,
                                );
                              },
                        activeThumbColor: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isArmed ? Colors.redAccent : Colors.greenAccent)
                            .withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.vpn_key,
                    size: 96,
                    color: isArmed ? Colors.redAccent : Colors.greenAccent,
                  ),
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: Icon(
                    isArmed ? Icons.shield : Icons.gpp_bad,
                    size: 40,
                    color: isArmed
                        ? Colors.red.shade400
                        : Colors.green.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isArmed
                    ? (isDark
                          ? Colors.red.withValues(alpha: 0.2)
                          : Colors.red.shade50)
                    : (isDark
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.green.shade50),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isArmed
                      ? (isDark
                            ? Colors.red.withValues(alpha: 0.5)
                            : Colors.red.shade300)
                      : (isDark
                            ? Colors.green.withValues(alpha: 0.5)
                            : Colors.green.shade300),
                  width: 2,
                ),
              ),
              child: Text(
                isArmed ? '🔒 BLOQUEADA' : '🔓 DESBLOQUEADA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isArmed
                      ? (isDark ? Colors.red.shade400 : Colors.red.shade600)
                      : (isDark
                            ? Colors.green.shade400
                            : Colors.green.shade600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isArmed ? 'Protección Máxima Activada' : 'Acceso Permitido',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
