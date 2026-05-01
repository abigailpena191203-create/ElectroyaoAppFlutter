import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dispositivo.dart';

class SupabaseService {
  // Configuración base e inicialización de Supabase
  // Debes llamar a este método en el main() antes de runApp()
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 40,
      ),
    );
  }

  // Instancia del cliente de Supabase
  final SupabaseClient _client = Supabase.instance.client;

  // Método para obtener todos los registros de t_dispositivos
  Future<List<Dispositivo>> getDispositivos() async {
    try {
      // Realiza la consulta select a la tabla
      final response = await _client.from('t_dispositivos').select();

      // Transforma el JSON devuelto en una lista de objetos Dispositivo
      return (response as List<dynamic>)
          .map((item) => Dispositivo.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error al obtener la lista de dispositivos: $e');
      // Puedes manejar el error como desees, aquí lo relanzamos
      rethrow;
    }
  }
}
