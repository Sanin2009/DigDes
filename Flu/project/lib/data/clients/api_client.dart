import 'dart:io';

import 'package:dio/dio.dart';
import 'package:project/domain/models/comment.dart';
import 'package:project/domain/models/dynamic_post_data.dart';
import 'package:project/domain/models/post.dart';
import 'package:retrofit/retrofit.dart';

import '../../domain/models/user.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  @GET("/api/User/GetCurrentUser")
  Future<User?> getUser();

  @GET("/api/Post/GetDynamicPostData")
  Future<DynamicPostData> getDynamicPostData(@Query("postId") String postId);

  @GET("/api/Post/GetAllPosts")
  Future<List<ShowPost>> getAllPosts(
      @Query("skip") int skip, @Query("take") int take);

  @POST("/api/Post/AddComment")
  Future addComment(
      @Query("postId") String postId, @Query("msg") String message);

  @POST("/api/Post/ShowComments")
  Future<List<ShowCommentModel>> showComments(@Query("postId") String postId);

  @POST("/api/Post/CreatePost")
  Future createPost(@Body() CreatePostModel createPostModel);

  @POST("/api/Attach/AddAvatarToUser")
  Future addAvatarToUser(@Body() Metadatum model);

  @POST("/api/Attach/UploadFiles")
  Future<List<Metadatum>> uploadTemp(
      {@Part(name: "files") required List<File> files});
}
