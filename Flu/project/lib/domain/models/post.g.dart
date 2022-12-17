// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShowPost _$ShowPostFromJson(Map<String, dynamic> json) => ShowPost(
      showPostModel:
          ShowPostModel.fromJson(json['showPostModel'] as Map<String, dynamic>),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ShowPostToJson(ShowPost instance) => <String, dynamic>{
      'showPostModel': instance.showPostModel,
      'user': instance.user,
    };

ShowPostModel _$ShowPostModelFromJson(Map<String, dynamic> json) =>
    ShowPostModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      created: json['created'] as String,
      name: json['name'] as String,
      attaches: (json['attaches'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      totalLikes: json['totalLikes'] as int,
      likedByMe: json['likedByMe'] as bool,
      totalComments: json['totalComments'] as int,
    );

Map<String, dynamic> _$ShowPostModelToJson(ShowPostModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'created': instance.created,
      'name': instance.name,
      'attaches': instance.attaches,
      'totalLikes': instance.totalLikes,
      'likedByMe': instance.likedByMe,
      'totalComments': instance.totalComments,
    };

FullPost _$FullPostFromJson(Map<String, dynamic> json) => FullPost(
      showPostModel:
          ShowPostModel.fromJson(json['showPostModel'] as Map<String, dynamic>),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      showCommentModels: (json['showCommentModels'] as List<dynamic>)
          .map((e) => ShowCommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FullPostToJson(FullPost instance) => <String, dynamic>{
      'showPostModel': instance.showPostModel,
      'user': instance.user,
      'showCommentModels': instance.showCommentModels,
    };

CreatePostModel _$CreatePostModelFromJson(Map<String, dynamic> json) =>
    CreatePostModel(
      title: json['title'] as String,
      tags: json['tags'] as String,
      metadata: (json['metadata'] as List<dynamic>)
          .map((e) => Metadatum.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreatePostModelToJson(CreatePostModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'tags': instance.tags,
      'metadata': instance.metadata,
    };

Metadatum _$MetadatumFromJson(Map<String, dynamic> json) => Metadatum(
      tempId: json['tempId'] as String,
      name: json['name'] as String,
      mimeType: json['mimeType'] as String,
      size: json['size'] as int,
    );

Map<String, dynamic> _$MetadatumToJson(Metadatum instance) => <String, dynamic>{
      'tempId': instance.tempId,
      'name': instance.name,
      'mimeType': instance.mimeType,
      'size': instance.size,
    };
