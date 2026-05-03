import 'package:flutter/material.dart';

enum UserRole {
  administrador,
  ventas,
  seguridad,
}

class AuthProvider with ChangeNotifier {
  UserRole _role = UserRole.administrador;

  UserRole get role => _role;

  String get roleName {
    switch (_role) {
      case UserRole.administrador: return 'Administrador';
      case UserRole.ventas: return 'Ventas';
      case UserRole.seguridad: return 'Seguridad';
    }
  }

  void setRole(UserRole newRole) {
    _role = newRole;
    notifyListeners();
  }

  bool canAccess(String route) {
    if (route == 'Gestión de Usuarios') {
      return _role == UserRole.administrador;
    }
    
    switch (_role) {
      case UserRole.administrador:
        return true;
      case UserRole.ventas:
        return route == 'Inicio' || route == 'Energía';
      case UserRole.seguridad:
        return route == 'Inicio' || route == 'Seguridad';
    }
  }
}
