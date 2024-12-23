import 'package:flutter/cupertino.dart';

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

  /// Load users from the backend with a query
  Future<void> loadUsers({String query = ''}) async {
    if (query.isEmpty || query.length < 2) {
      return; // Don't trigger search if query is empty or less than 2
    }

    _loading = true;
    notifyListeners();

    try {
      _users =
          await _userService.fetchUsers(query: query); // Fetch based on query
    } catch (error) {
      print('Error loading users: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Clear the users list
  void clearUsers() {
    _users.clear(); // Clear the users list
    notifyListeners(); // Notify listeners to trigger UI update
  }
}
