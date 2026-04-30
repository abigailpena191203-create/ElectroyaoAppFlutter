import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dispositivo.dart';

class DispositivosProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  List<Dispositivo> _dispositivos = [];
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  List<Dispositivo> get dispositivos => _dispositivos;

  DispositivosProvider() {
    _initStream();
  }

  void _initStream() {
    _subscription = _client
        .from('t_dispositivos')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
      try {
        _dispositivos = data.map((item) {
          try {
            return Dispositivo.fromJson(item);
          } catch (e) {
            print('Error parseando dispositivo: $e en item: $item');
            return null;
          }
        }).whereType<Dispositivo>().toList();
        notifyListeners();
      } catch (e) {
        print('Error general procesando datos del stream: $e');
      }
    }, onError: (error) {
      print('Error en el stream de dispositivos: $error');
    });
  }

  // Obtener un dispositivo por su nombre de área
  Dispositivo? getDispositivoByArea(String areaName) {
    try {
      return _dispositivos.firstWhere((d) => d.nombreArea == areaName);
    } catch (e) {
      return null;
    }
  }

  // Obtener el estado booleano basado en el string "Activo" o "Inactivo"
  bool isDispositivoOn(String areaName) {
    final disp = getDispositivoByArea(areaName);
    return disp?.estado == 'Activo';
  }

  // Obtener si el dispositivo está en modo manual
  bool isDispositivoManual(String areaName) {
    final disp = getDispositivoByArea(areaName);
    return disp?.modo != 'Automático';
  }

  // Actualizar el estado de un dispositivo en Supabase
  Future<void> toggleDispositivo(String areaName, bool isOn) async {
    final disp = getDispositivoByArea(areaName);
    if (disp == null) return;

    // Validación estricta en el provider: no permite cambio si está en automático
    if (disp.modo == 'Automático') {
      print('Intento de cambio rechazado: El dispositivo $areaName está en modo Automático.');
      return;
    }

    final newState = isOn ? 'Activo' : 'Inactivo';
    
    // Eliminamos el Optimistic Update (modificación local prematura) para evitar el efecto 'ghosting'.
    // Al solo enviar la actualización a Supabase, confiamos en que el .stream() 
    // emitirá el nuevo estado exacto en tiempo real, garantizando sincronización bidireccional perfecta.

    try {
      await _client
          .from('t_dispositivos')
          .update({'estado': newState})
          .eq('id', disp.id);
    } catch (e) {
      print('Error actualizando el dispositivo $areaName: $e');
      // Podríamos revertir el cambio local si falla
    }
  }

  // Alternar el modo de un dispositivo (Manual / Automático)
  Future<void> toggleAutoMode(String areaName) async {
    final disp = getDispositivoByArea(areaName);
    if (disp == null) return;

    final isManual = disp.modo != 'Automático';
    final newMode = isManual ? 'Automático' : 'Manual';

    try {
      await _client
          .from('t_dispositivos')
          .update({'modo': newMode})
          .eq('id', disp.id);
    } catch (e) {
      print('Error actualizando el modo del dispositivo $areaName: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
