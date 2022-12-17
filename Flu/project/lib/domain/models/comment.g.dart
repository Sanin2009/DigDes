// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
