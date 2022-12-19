// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateUserModel _$CreateUserModelFromJson(Map<String, dynamic> json) =>
    CreateUserModel(
      name: json['name'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      retryPassword: json['retryPassword'] as String?,
      birthDay: json['birthDay'] as String?,
    );

Map<String, dynamic> _$CreateUserModelToJson(CreateUserModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'retryPassword': instance.retryPassword,
      'birthDay': instance.birthDay,
    };
