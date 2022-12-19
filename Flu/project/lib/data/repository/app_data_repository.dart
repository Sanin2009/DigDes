import 'dart:io';

import 'package:project/domain/models/create_user_model.dart';
import 'package:project/domain/models/post.dart';

import '../../domain/models/refresh_token_request.dart';
import '../../domain/models/token_request.dart';
import '../../domain/models/token_response.dart';
import '../../domain/models/user.dart';
import '../../domain/repository/api_repository.dart';
import '../clients/api_client.dart';
import '../clients/auth_client.dart';

class ApiDataRepository extends ApiRepository {
  final AuthClient _auth;
  final ApiClient _api;
  ApiDataRepository(this._auth, this._api);

  @override
  Future<TokenResponse?> getToken({
    required String login,
    required String password,
  }) async {
    return await _auth.getToken(TokenRequest(
      login: login,
      pass: password,
    ));
  }

  @override
  Future<TokenResponse?> refreshToken(String refreshToken) async =>
      await _auth.refreshToken(RefreshTokenRequest(
        refreshToken: refreshToken,
      ));

  @override
  Future<User?> getUser() => _api.getUser();

  @override
  Future<List<ShowPost>> getAllPosts(int skip, int take) =>
      _api.getAllPosts(skip, take);

  @override
  Future<List<Metadatum>> uploadTemp({required List<File> files}) =>
      _api.uploadTemp(files: files);

  @override
  Future addAvatarToUser(Metadatum model) => _api.addAvatarToUser(model);

  @override
  Future createUser(CreateUserModel createUserModel) async {
    await _auth.createUser(createUserModel);
  }
}
