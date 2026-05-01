import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dispositivo.dart';

class DispositivosProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  List<Dispositivo> _dispositivos = [];
  RealtimeChannel? _channel;

  List<Dispositivo> get dispositivos => _dispositivos;

  DispositivosProvider() {
    _initStream();
  }

  void _initStream() async {
    // 1. Obtener estado inicial (Carga inicial síncrona)
    try {
      final response = await _client.from('t_dispositivos').select();
      _dispositivos = (response as List<dynamic>).map((item) {
        return Dispositivo.fromJson(item as Map<String, dynamic>);
      }).toList();
      notifyListeners();
      print('📦 CARGA INICIAL: ${_dispositivos.length} dispositivos listos.');
    } catch (e) {
      print('❌ ERROR EN CARGA INICIAL: $e');
    }

    // 2. Suscripción AGRESIVA a PostgresChanges (Canal Puro)
    _channel = _client.channel('public:t_dispositivos').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 't_dispositivos',
      callback: (PostgresChangePayload payload) {
        print('🔥 EVENTO EXTERNO PURO DE SUPABASE: ${payload.eventType}');
        
        try {
          if (payload.eventType == PostgresChangeEvent.update) {
            print('📦 Registro actualizado recibido: ${payload.newRecord}');
            final newRecord = payload.newRecord;
            final index = _dispositivos.indexWhere((d) => d.id == newRecord['id']);
            if (index != -1) {
               _dispositivos[index] = Dispositivo.fromJson(newRecord);
            }
          } else if (payload.eventType == PostgresChangeEvent.insert) {
            _dispositivos.add(Dispositivo.fromJson(payload.newRecord));
          } else if (payload.eventType == PostgresChangeEvent.delete) {
            final oldRecord = payload.oldRecord;
            _dispositivos.removeWhere((d) => d.id == oldRecord['id']);
          }
          
          // ¡Disparamos el UI inmediatamente después de mutar la lista!
          notifyListeners(); 
        } catch (e) {
          print('❌ Error procesando evento de Realtime: $e');
        }
      },
    ).subscribe((status, [error]) {
      print('📡 ESTADO DE LA CONEXIÓN SOCKET: $status');
      if (error != null) {
        print('❌ ERROR DEL SOCKET: $error');
      }
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

  // Obtener el estado booleano basado en el string
  bool isDispositivoOn(String areaName) {
    final disp = getDispositivoByArea(areaName);
    if (disp == null || disp.estado == null) return false;
    final estadoStr = disp.estado!.toLowerCase().trim();
    return estadoStr == 'activo' || estadoStr == 'encendido';
  }

  // Obtener si el dispositivo está en modo manual
  bool isDispositivoManual(String areaName) {
    final disp = getDispositivoByArea(areaName);
    if (disp == null || disp.modo == null) return true;
    final modoStr = disp.modo!.toLowerCase().trim().replaceAll('á', 'a');
    return modoStr != 'automatico';
  }

  // Actualizar el estado de un dispositivo en Supabase
  Future<void> toggleDispositivo(String areaName, bool isOn) async {
    final disp = getDispositivoByArea(areaName);
    if (disp == null) return;

    // Validación estricta en el provider: no permite cambio si está en automático
    if (!isDispositivoManual(areaName)) {
      print('Intento de cambio rechazado: El dispositivo $areaName está en modo Automático.');
      return;
    }

    final newState = isOn ? 'Activo' : 'Inactivo';
    
    // Eliminamos el Optimistic Update (modificación local prematura) para evitar el efecto 'ghosting'.
    // Al solo enviar la actualización a Supabase, confiamos en que el .stream() 
    // emitirá el nuevo estado exacto en tiempo real, garantizando sincronización bidireccional perfecta.

    try {
      final response = await _client
          .from('t_dispositivos')
          .update({'estado': newState})
          .eq('id', disp.id)
          .select();
      print('✅ CONFIRMACIÓN SUPABASE (ESTADO): $response');
    } catch (e) {
      print('❌ Error actualizando el dispositivo $areaName: $e');
    }
  }

  // Alternar el modo de un dispositivo (Manual / Automático)
  Future<void> toggleAutoMode(String areaName) async {
    final disp = getDispositivoByArea(areaName);
    if (disp == null) return;

    final isManual = isDispositivoManual(areaName);
    final newMode = isManual ? 'Automático' : 'Manual';

    try {
      final response = await _client
          .from('t_dispositivos')
          .update({'modo': newMode})
          .eq('id', disp.id)
          .select();
      print('✅ CONFIRMACIÓN SUPABASE (MODO): $response');
    } catch (e) {
      print('❌ Error actualizando el modo del dispositivo $areaName: $e');
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}
