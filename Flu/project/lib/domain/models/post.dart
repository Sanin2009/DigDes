// Generated by https://quicktype.io

import 'package:json_annotation/json_annotation.dart';

import 'comment.dart';
import 'user.dart';

part 'post.g.dart';

// Generated by https://quicktype.io

@JsonSerializable()
class ShowPost {
  final ShowPostModel showPostModel;
  final User userModel;

  ShowPost({
    required this.showPostModel,
    required this.userModel,
  });

  factory ShowPost.fromJson(Map<String, dynamic> json) =>
      _$ShowPostFromJson(json);

  Map<String, dynamic> toJson() => _$ShowPostToJson(this);
}

@JsonSerializable()
class ShowPostModel {
  final String id;
  final String userId;
  final String created;
  final String name;
  List<String>? attaches;
  late int totalLikes;
  late bool likedByMe;
  late int totalComments;

  ShowPostModel({
    required this.id,
    required this.userId,
    required this.created,
    required this.name,
    this.attaches,
    required this.totalLikes,
    required this.likedByMe,
    required this.totalComments,
  });

  factory ShowPostModel.fromJson(Map<String, dynamic> json) =>
      _$ShowPostModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShowPostModelToJson(this);
}

@JsonSerializable()
class FullPost {
  final ShowPostModel showPostModel;
  final User user;
  final List<ShowCommentModel> showCommentModels;

  FullPost({
    required this.showPostModel,
    required this.user,
    required this.showCommentModels,
  });

  factory FullPost.fromJson(Map<String, dynamic> json) =>
      _$FullPostFromJson(json);

  Map<String, dynamic> toJson() => _$FullPostToJson(this);
}

// Generated by https://quicktype.io

@JsonSerializable()
class CreatePostModel {
  final String title;
  final String tags;
  final List<Metadatum> metadata;

  CreatePostModel({
    required this.title,
    required this.tags,
    required this.metadata,
  });

  factory CreatePostModel.fromJson(Map<String, dynamic> json) =>
      _$CreatePostModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostModelToJson(this);
}

@JsonSerializable()
class Metadatum {
  final String tempId;
  final String name;
  final String mimeType;
  final int size;

  Metadatum({
    required this.tempId,
    required this.name,
    required this.mimeType,
    required this.size,
  });

  factory Metadatum.fromJson(Map<String, dynamic> json) =>
      _$MetadatumFromJson(json);

  Map<String, dynamic> toJson() => _$MetadatumToJson(this);
}
