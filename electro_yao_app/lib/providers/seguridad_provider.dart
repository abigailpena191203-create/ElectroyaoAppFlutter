import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/log_seguridad.dart';
import '../models/usuario.dart';

class SeguridadProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  List<LogSeguridad> _logs = [];
  List<Usuario> _usuarios = [];
  RealtimeChannel? _channelLogs;
  bool _isLoading = true;

  List<LogSeguridad> get logs => _logs;
  List<Usuario> get usuarios => _usuarios;
  bool get isLoading => _isLoading;

  int get totalEventos => _logs.length;

  int get eventosHoy {
    final hoy = DateTime.now();
    return _logs
        .where((l) =>
            l.fechaHora != null &&
            l.fechaHora!.year == hoy.year &&
            l.fechaHora!.month == hoy.month &&
            l.fechaHora!.day == hoy.day)
        .length;
  }

  int get alertasCriticas => _logs
      .where((l) => l.tipoEvento == LogEventType.alert)
      .length;

  SeguridadProvider() {
    _initData();
  }

  Future<void> _initData() async {
    await Future.wait([_cargarLogs(), _cargarUsuarios()]);
    _isLoading = false;
    notifyListeners();
    _suscribirRealtime();
  }

  Future<void> _cargarLogs() async {
    try {
      final response = await _client
          .from('t_logs_seguridad')
          .select()
          .order('fecha_hora', ascending: false)
          .limit(100);
      _logs = (response as List<dynamic>)
          .map((item) => LogSeguridad.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Error silencioso
    }
  }

  Future<void> _cargarUsuarios() async {
    try {
      final response = await _client
          .from('t_usuarios')
          .select()
          .order('nombre', ascending: true);
      _usuarios = (response as List<dynamic>)
          .map((item) => Usuario.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Error silencioso
    }
  }

  void _suscribirRealtime() {
    _channelLogs = _client
        .channel('public:t_logs_seguridad')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 't_logs_seguridad',
          callback: (PostgresChangePayload payload) {
            if (payload.newRecord != null) {
              final nuevoLog = LogSeguridad.fromJson(payload.newRecord!);
              _logs.insert(0, nuevoLog);
              notifyListeners();
            }
          },
        )
        .subscribe((status, [error]) {
      // Silencioso
    });
  }

  /// Alternar el estado de un usuario entre Activo y Bloqueado
  Future<void> toggleEstadoUsuario(String usuarioId) async {
    final idx = _usuarios.indexWhere((u) => u.id == usuarioId);
    if (idx == -1) return;

    final nuevoEstado =
        _usuarios[idx].isActive ? 'Bloqueado' : 'Activo';
    try {
      await _client
          .from('t_usuarios')
          .update({'estado': nuevoEstado})
          .eq('id', usuarioId)
          .select()
          .single();

      // Actualización optimista local (no hay Realtime en usuarios)
      final u = _usuarios[idx];
      _usuarios[idx] = Usuario(
        id: u.id,
        nombre: u.nombre,
        email: u.email,
        rol: u.rol,
        estado: nuevoEstado,
        fechaRegistro: u.fechaRegistro,
      );
      notifyListeners();
    } catch (e) {
      // Error silencioso
    }
  }

  /// Cambiar el rol de un usuario
  Future<void> cambiarRolUsuario(String usuarioId, String nuevoRol) async {
    if (!Usuario.rolesValidos.contains(nuevoRol)) return;
    final idx = _usuarios.indexWhere((u) => u.id == usuarioId);
    if (idx == -1) return;

    try {
      await _client
          .from('t_usuarios')
          .update({'rol': nuevoRol})
          .eq('id', usuarioId)
          .select()
          .single();

      final u = _usuarios[idx];
      _usuarios[idx] = Usuario(
        id: u.id,
        nombre: u.nombre,
        email: u.email,
        rol: nuevoRol,
        estado: u.estado,
        fechaRegistro: u.fechaRegistro,
      );
      notifyListeners();
    } catch (e) {
      // Error silencioso
    }
  }

  @override
  void dispose() {
    _channelLogs?.unsubscribe();
    super.dispose();
  }
}
