import 'dart:io';

import '../models/post.dart';
import '../models/token_response.dart';
import '../models/user.dart';

abstract class ApiRepository {
  Future<TokenResponse?> getToken(
      {required String login, required String password});
  Future<TokenResponse?> refreshToken(String refreshToken);
  Future<User?> getUser();
  Future<List<ShowPost>> getPosts(int skip, int take);
  Future<List<Metadatum>> uploadTemp({required List<File> files});
  Future addAvatarToUser(Metadatum model);
}
