import 'dart:io';

import 'package:dio/dio.dart';
import 'package:project/domain/models/comment.dart';
import 'package:project/domain/models/dynamic_post_data.dart';
import 'package:project/domain/models/post.dart';
import 'package:retrofit/retrofit.dart';

import '../../domain/models/settings.dart';
import '../../domain/models/user.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  @GET("/api/User/GetCurrentUser")
  Future<User?> getUser();

  @GET("/api/User/GetUserById")
  Future<User?> getUserById(@Query("userId") String userId);

  @GET("/api/User/GetUserByName")
  Future<User?> getUserByName(@Query("name") String name);

  @GET("/api/Post/GetDynamicPostData")
  Future<DynamicPostData> getDynamicPostData(@Query("postId") String postId);

  @GET("/api/Post/GetAllPosts")
  Future<List<ShowPost>> getAllPosts(
      @Query("skip") int skip, @Query("take") int take);

  @GET("/api/Post/GetFeed")
  Future<List<ShowPost>> getFeed(
      @Query("skip") int skip, @Query("take") int take);

  @GET("/api/User/SearchUsers")
  Future<List<User>> searchUser(@Query("name") String name);

  @GET("/api/Post/GetUsersPosts")
  Future<List<ShowPost>> getUsersPosts(@Query("userId") String userid,
      @Query("skip") int skip, @Query("take") int take);

  @GET("/api/Post/GetPostsByTag")
  Future<List<ShowPost>> getPostsByTag(@Query("inputTag") String inputTag,
      @Query("skip") int skip, @Query("take") int take);

  @POST("/api/Post/AddComment")
  Future addComment(
      @Query("postId") String postId, @Query("msg") String message);

  @POST("/api/Post/ShowComments")
  Future<List<ShowCommentModel>> showComments(@Query("postId") String postId);

  @PUT("/api/Post/UpdateLike")
  Future updateLike(@Query("postId") String postId);

  @PUT("/api/User/UpdateStatus")
  Future updateStatus(@Query("status") String status);

  @PUT("/api/User/Subscribe")
  Future subscribe(@Query("userId") String userId, @Query("sub") bool sub);

  @DELETE("/api/Post/DeleteComment")
  Future deleteComment(@Query("commentId") String commentId);

  @DELETE("/api/Post/DeletePost")
  Future deletePost(@Query("postId") String postId);

  @POST("/api/Post/CreatePost")
  Future createPost(@Body() CreatePostModel createPostModel);

  @POST("/api/Attach/AddAvatarToUser")
  Future addAvatarToUser(@Body() Metadatum model);

  @POST("/api/Attach/UploadFiles")
  Future<List<Metadatum>> uploadTemp(
      {@Part(name: "files") required List<File> files});

  @PUT("/api/User/UpdateSettings")
  Future<bool?> updateSettings(@Body() SettingsModel settings);
}
