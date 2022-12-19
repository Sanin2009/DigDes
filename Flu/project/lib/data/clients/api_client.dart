import 'dart:io';

import 'package:dio/dio.dart';
import 'package:project/domain/models/post.dart';
import 'package:retrofit/retrofit.dart';

import '../../domain/models/user.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  @GET("/api/User/GetCurrentUser")
  Future<User?> getUser();

  @GET("/api/Post/GetAllPosts")
  Future<List<ShowPost>> getAllPosts(
      @Query("skip") int skip, @Query("take") int take);

  @POST("/api/Attach/AddAvatarToUser")
  Future addAvatarToUser(@Body() Metadatum model);

  @POST("/api/Attach/UploadFiles")
  Future<List<Metadatum>> uploadTemp(
      {@Part(name: "files") required List<File> files});
}
