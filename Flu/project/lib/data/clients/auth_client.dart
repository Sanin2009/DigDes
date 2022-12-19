import 'package:dio/dio.dart';
import 'package:project/domain/models/create_user_model.dart';
import 'package:retrofit/retrofit.dart';

import '../../domain/models/refresh_token_request.dart';
import '../../domain/models/token_request.dart';
import '../../domain/models/token_response.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String? baseUrl}) = _AuthClient;

  @POST("/api/Auth/LoginUser")
  Future<TokenResponse?> getToken(@Body() TokenRequest body);

  @POST("/api/Auth/CreateUser")
  Future createUser(@Body() CreateUserModel createUserModel);

  @POST("/api/Auth/RefreshToken")
  Future<TokenResponse?> refreshToken(@Body() RefreshTokenRequest body);
}
