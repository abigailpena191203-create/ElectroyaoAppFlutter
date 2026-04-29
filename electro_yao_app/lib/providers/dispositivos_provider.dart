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
      _dispositivos = data.map((item) => Dispositivo.fromJson(item)).toList();
      notifyListeners();
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

  // Actualizar el estado de un dispositivo en Supabase
  Future<void> toggleDispositivo(String areaName, bool isOn) async {
    final disp = getDispositivoByArea(areaName);
    if (disp == null) return;

    final newState = isOn ? 'Activo' : 'Inactivo';
    
    // Optimizamos la UI actualizando localmente antes de que llegue el evento del stream
    final index = _dispositivos.indexWhere((d) => d.id == disp.id);
    if (index != -1) {
      // Creamos una copia actualizada localmente (Optimistic UI update)
      _dispositivos[index] = Dispositivo(
        id: disp.id,
        nombreArea: disp.nombreArea,
        tipoDispositivo: disp.tipoDispositivo,
        estado: newState,
        ubicacion: disp.ubicacion,
        ultimaActualizacion: DateTime.now(),
      );
      notifyListeners();
    }

    try {
      await _client
          .from('t_dispositivos')
          .update({'Estado': newState})
          .eq('id', disp.id);
    } catch (e) {
      print('Error actualizando el dispositivo $areaName: $e');
      // Podríamos revertir el cambio local si falla
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
