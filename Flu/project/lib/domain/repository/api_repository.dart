import 'dart:io';

import 'package:project/domain/models/comment.dart';
import 'package:project/domain/models/create_user_model.dart';
import 'package:project/domain/models/dynamic_post_data.dart';

import '../models/post.dart';
import '../models/token_response.dart';
import '../models/user.dart';

abstract class ApiRepository {
  Future<TokenResponse?> getToken(
      {required String login, required String password});
  Future<TokenResponse?> refreshToken(String refreshToken);
  Future<User?> getUser();
  Future<User?> getUserById(String userId);
  Future<User?> getUserByName(String name);
  Future<DynamicPostData> getDynamicPostData(String postId);
  Future addComment(String postId, String message);
  Future<List<ShowPost>> getAllPosts(int skip, int take);
  Future<List<ShowPost>> getFeed(int skip, int take);
  Future<List<ShowPost>> getUsersPosts(String userid, int skip, int take);
  Future<List<ShowCommentModel>> showComments(String postId);
  Future updateLike(String postId);
  Future<String> updateStatus(String status);
  Future<List<Metadatum>> uploadTemp({required List<File> files});
  Future addAvatarToUser(Metadatum model);
  Future createUser(CreateUserModel createUserModel);
  Future createPost(CreatePostModel createPostModel);
  Future deleteComment(String commentId);
  Future deletePost(String postId);
}
