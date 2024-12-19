import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  late final UserService _userService;
  final AuthService _authService;

  List<String> _users = [];
  bool _loading = false;

  List<String> get users => _users;
  bool get loading => _loading;

  UserProvider(this._authService) {
    _userService = UserService(_authService);
  }

  /// Load all users from the backend
  Future<void> loadUsers() async {
    _loading = true;
    notifyListeners();

    try {
      _users = await _userService.fetchUsers();
    } catch (error) {
      // Handle errors, e.g., logging or showing a UI message
      print('Error loading users: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
