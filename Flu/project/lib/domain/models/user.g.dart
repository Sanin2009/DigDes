// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      birthDay: json['birthDay'] as String,
      lastActive: json['lastActive'] as String,
      avatarLink: json['avatarLink'] as String,
      status: json['status'] as String?,
      totalPosts: json['totalPosts'] as int,
      totalComments: json['totalComments'] as int,
      isSub: json['isSub'] as bool?,
      isOpen: json['isOpen'] as bool,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'birthDay': instance.birthDay,
      'lastActive': instance.lastActive,
      'avatarLink': instance.avatarLink,
      'status': instance.status,
      'totalPosts': instance.totalPosts,
      'totalComments': instance.totalComments,
      'isSub': instance.isSub,
      'isOpen': instance.isOpen,
    };
