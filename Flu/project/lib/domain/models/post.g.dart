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
      name: json['name'] as String?,
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

ShowCommentModel _$ShowCommentModelFromJson(Map<String, dynamic> json) =>
    ShowCommentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      message: json['message'] as String,
      created: json['created'] as String,
      avatarLink: json['avatarLink'] as String,
    );

Map<String, dynamic> _$ShowCommentModelToJson(ShowCommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'message': instance.message,
      'created': instance.created,
      'avatarLink': instance.avatarLink,
    };
