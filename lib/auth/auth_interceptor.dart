import 'package:http_interceptor/http_interceptor.dart';
import 'package:task_manager_app/services/auth_service.dart';

class AuthInterceptor extends InterceptorContract {
  final AuthService authService;

  AuthInterceptor(this.authService);

  @override
  Future<BaseRequest> interceptRequest({
    required BaseRequest request,
  }) async {
    final token = await authService.getToken();
    print(token);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return request;
  }

  @override
  BaseResponse interceptResponse({
    required BaseResponse response,
  }) =>
      response;
}
