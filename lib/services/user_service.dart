import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http/intercepted_http.dart';

import '../auth/auth_interceptor.dart';
import 'auth_service.dart';

class UserService {
  late final InterceptedHttp _http;
  final AuthService _authService;
  final String userApi = dotenv.env['USER_API'] ??
      'https://b3h6utkwz2.execute-api.eu-west-1.amazonaws.com/prod/users';

  UserService(this._authService) {
    _http =
        InterceptedHttp.build(interceptors: [AuthInterceptor(_authService)]);
  }

  Future<List<String>> fetchUsers() async {
    final response = await _http.get(Uri.parse(userApi));
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      // Decode the JSON response as a Map
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Extract the 'users' key, which is a List<dynamic>
      if (data.containsKey('users') && data['users'] is List) {
        return (data['users'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();
      } else {
        throw Exception(
            'Invalid response format: Missing or invalid "users" key');
      }
    } else {
      throw Exception('Failed to load users');
    }
  }
}
