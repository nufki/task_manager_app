import 'dart:convert';

import 'package:http_interceptor/http/intercepted_http.dart';

import '../auth/auth_interceptor.dart';
import 'auth_service.dart';

class UserService {
  late final InterceptedHttp _http;
  final AuthService _authService;

  UserService(this._authService) {
    _http =
        InterceptedHttp.build(interceptors: [AuthInterceptor(_authService)]);
  }

  final String apiUrl =
      'https://b3h6utkwz2.execute-api.eu-west-1.amazonaws.com/prod/users';

  // Fetch users with search query, limit, and nextToken for pagination
  Future<List<String>> fetchUsers(
      {String query = '', int limit = 10, String? nextToken}) async {
    print('fetch user called');
    final response = await _http.get(
      Uri.parse(apiUrl).replace(queryParameters: {
        'username': query,
        'limit': limit.toString(),
        if (nextToken != null) 'nextToken': nextToken,
      }),
    );

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
