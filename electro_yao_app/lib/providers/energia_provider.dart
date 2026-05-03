import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/consumo_energia.dart';

class EnergiaProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  List<ConsumoEnergia> _registros = [];
  RealtimeChannel? _channel;
  bool _isLoading = true;

  List<ConsumoEnergia> get registros => _registros;
  bool get isLoading => _isLoading;

  double get totalKwh {
    if (_registros.isEmpty) return 0.0;
    final total = _registros.fold(0.0, (sum, r) => sum + (r.vatios ?? 0.0));
    return total / 1000.0; // Convertir vatios-hora a kWh
  }

  double get promedioVatios {
    if (_registros.isEmpty) return 0.0;
    return _registros.fold(0.0, (sum, r) => sum + (r.vatios ?? 0.0)) /
        _registros.length;
  }

  double get consumoActual {
    if (_registros.isEmpty) return 0.0;
    return _registros.first.vatios ?? 0.0;
  }

  // ---- Metas de Ahorro (Calculadas o desde DB) ----
  double get metaAhorroMensual => 200.0;
  
  double get ahorroActualMensual {
    if (_registros.isEmpty) return 0.0;
    // Simulación: Comparar consumo real vs un promedio "base" de 400W
    // En producción, esto vendría de una tabla 't_metas' o similar
    final consumoTotalMes = _registros.take(30).fold(0.0, (s, r) => s + (r.vatios ?? 0.0));
    final baseIdeal = 400.0 * 30; // 400W constantes por 30 registros
    final ahorroVatios = max(0.0, baseIdeal - consumoTotalMes);
    return (ahorroVatios / 1000.0) * 0.15; // Suponiendo $0.15 por kWh ahorrado
  }

  double get limiteConsumo => 250.0;

  int get diasRestantesMes {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    return lastDay - now.day;
  }

  double get promedioDiarioAhorro => ahorroActualMensual / (DateTime.now().day > 0 ? DateTime.now().day : 1);

  EnergiaProvider() {
    _initData();
  }

  Future<void> _initData() async {
    try {
      final response = await _client
          .from('t_consumo_energia')
          .select()
          .order('fecha', ascending: false)
          .limit(90); // Últimos 90 registros (~3 meses)

      _registros = (response as List<dynamic>)
          .map((item) => ConsumoEnergia.fromJson(item as Map<String, dynamic>))
          .toList();

      print('⚡ ENERGÍA: ${_registros.length} registros cargados desde Supabase.');

      // Si Supabase está vacío, usar Mock Data para demo
      if (_registros.isEmpty) {
        _registros = _generarMockData();
        print('📊 ENERGÍA: Datos reales vacíos, usando Mock Data para demo.');
      }
    } catch (e) {
      print('❌ ERROR cargando consumo de energía: $e');
      _registros = _generarMockData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    _suscribirRealtime();
  }

  void _suscribirRealtime() {
    _channel = _client
        .channel('public:t_consumo_energia')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 't_consumo_energia',
          callback: (PostgresChangePayload payload) {
            if (payload.newRecord != null) {
              print('📡 NUEVO REGISTRO DE ENERGÍA: ${payload.newRecord}');
              final nuevo =
                  ConsumoEnergia.fromJson(payload.newRecord!);
              _registros.insert(0, nuevo);
              notifyListeners();
            }
          },
        )
        .subscribe((status, [error]) {
      print('⚡ SOCKET ENERGÍA: $status');
    });
  }

  /// Genera 30 días de datos ficticios para demo cuando la DB está vacía
  List<ConsumoEnergia> _generarMockData() {
    final rand = Random();
    final now = DateTime.now();
    return List.generate(30, (i) {
      final fecha = now.subtract(Duration(days: i));
      return ConsumoEnergia(
        id: 'mock-$i',
        dispositivoId: null,
        vatios: 150.0 + rand.nextDouble() * 250.0, // Entre 150W y 400W
        fecha: fecha,
      );
    });
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}
