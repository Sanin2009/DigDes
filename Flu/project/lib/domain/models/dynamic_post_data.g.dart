// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_post_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamicPostData _$DynamicPostDataFromJson(Map<String, dynamic> json) =>
    DynamicPostData(
      totalLikes: json['totalLikes'] as int,
      likedByMe: json['likedByMe'] as bool,
      totalComments: json['totalComments'] as int,
    );

Map<String, dynamic> _$DynamicPostDataToJson(DynamicPostData instance) =>
    <String, dynamic>{
      'totalLikes': instance.totalLikes,
      'likedByMe': instance.likedByMe,
      'totalComments': instance.totalComments,
    };
