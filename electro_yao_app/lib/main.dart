import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/constants.dart';
import 'services/supabase_service.dart';
import 'providers/theme_provider.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de llamadas asíncronas
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await SupabaseService.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const ElectroYaoApp(),
    ),
  );
}

class ElectroYaoApp extends StatelessWidget {
  const ElectroYaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'ElectroYao Dashboard',
      debugShowCheckedModeBanner: false, // Ocultar etiqueta de debug
      theme: themeProvider.currentTheme,
      home: const DashboardScreen(), // Usar el nuevo DashboardScreen
    );
  }
}
