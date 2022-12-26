import 'package:dio/dio.dart';

import '../../data/clients/api_client.dart';
import '../../data/clients/auth_client.dart';
import '../../data/services/auth_service.dart';
import '../../domain/models/refresh_token_request.dart';
import '../../ui/navigation/app_navigator.dart';
import '../config/app_config.dart';
import '../config/token_storage.dart';

class ApiModule {
  static AuthClient? _authClient;
  static ApiClient? _apiClient;

  static AuthClient auth() =>
      _authClient ??
      AuthClient(
        Dio(),
        baseUrl: baseUrl,
      );
  static ApiClient api() =>
      _apiClient ??
      ApiClient(
        _addIntercepters(Dio()),
        baseUrl: baseUrl,
      );

  static Dio _addIntercepters(Dio dio) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getAccessToken();
        options.headers.addAll({"Authorization": "Bearer $token"});
        return handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          dio.lock();
          RequestOptions options = e.response!.requestOptions;

          var rt = await TokenStorage.getRefreshToken();
          try {
            if (rt != null) {
              var token = await auth()
                  .refreshToken(RefreshTokenRequest(refreshToken: rt));
              await TokenStorage.setStoredToken(token);
              options.headers["Authorization"] = "Bearer ${token!.accessToken}";
            }
          } catch (e) {
            var service = AuthService();
            if (await service.checkAuth()) {
              await service.logout();
              AppNavigator.toLoader();
            }

            return handler
                .resolve(Response(statusCode: 400, requestOptions: options));
          } finally {
            dio.unlock();
          }
          return handler.resolve(await dio.fetch(options));
        } else {
          return handler.next(e);
        }
      },
    ));
    return dio;
  }
}
