import 'dart:io';

import 'package:project/domain/models/comment.dart';
import 'package:project/domain/models/create_user_model.dart';
import 'package:project/domain/models/dynamic_post_data.dart';
import 'package:project/domain/models/post.dart';

import '../../domain/models/refresh_token_request.dart';
import '../../domain/models/settings.dart';
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

  @override
  Future createPost(CreatePostModel createPostModel) async {
    await _api.createPost(createPostModel);
  }

  @override
  Future<List<ShowCommentModel>> showComments(String postId) =>
      _api.showComments(postId);

  @override
  Future addComment(String postId, String message) async {
    await _api.addComment(postId, message);
  }

  @override
  Future<DynamicPostData> getDynamicPostData(String postId) async {
    return await _api.getDynamicPostData(postId);
  }

  @override
  Future updateLike(String postId) async {
    await _api.updateLike(postId);
  }

  @override
  Future deleteComment(String commentId) async {
    await _api.deleteComment(commentId);
  }

  @override
  Future deletePost(String postId) async {
    await _api.deletePost(postId);
  }

  @override
  Future<User?> getUserById(String userId) async {
    return await _api.getUserById(userId);
  }

  @override
  Future<User?> getUserByName(String name) async {
    return await _api.getUserByName(name);
  }

  @override
  Future<List<ShowPost>> getUsersPosts(
      String userid, int skip, int take) async {
    return await _api.getUsersPosts(userid, skip, take);
  }

  @override
  Future<List<ShowPost>> getFeed(int skip, int take) async {
    return await _api.getFeed(skip, take);
  }

  @override
  Future<String> updateStatus(String status) async {
    return await _api.updateStatus(status);
  }

  @override
  Future<bool?> updateSettings(SettingsModel settings) async {
    return await _api.updateSettings(settings);
  }

  @override
  Future<List<ShowPost>> getPostsByTag(
      String inputTag, int skip, int take) async {
    return await _api.getPostsByTag(inputTag, skip, take);
  }

  @override
  Future<bool?> subscribe(String userId, bool sub) async {
    return await _api.subscribe(userId, sub);
  }
}
