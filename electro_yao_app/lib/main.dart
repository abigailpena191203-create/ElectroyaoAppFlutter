import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/constants.dart';
import 'services/supabase_service.dart';
import 'providers/theme_provider.dart';
import 'providers/dispositivos_provider.dart';
import 'providers/energia_provider.dart';
import 'providers/seguridad_provider.dart';
import 'screens/main_shell.dart';

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
        // DispositivosProvider vive aquí → nunca muere al navegar entre secciones
        ChangeNotifierProvider(create: (_) => DispositivosProvider()),
        // Providers de datos conectados a Supabase
        ChangeNotifierProvider(create: (_) => EnergiaProvider()),
        ChangeNotifierProvider(create: (_) => SeguridadProvider()),
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
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: const MainShell(), // Shell de navegación modular
    );
  }
}
