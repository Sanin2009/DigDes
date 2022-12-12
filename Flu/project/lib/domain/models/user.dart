import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  final String birthDay;
  final String lastActive;
  final String avatarLink;
  String? status;
  final int totalPosts;
  final int totalComments;
  final int totalSubs;
  bool? isSub;
  bool isOpen;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.birthDay,
      required this.lastActive,
      required this.avatarLink,
      this.status,
      required this.totalPosts,
      required this.totalComments,
      required this.totalSubs,
      this.isSub,
      required this.isOpen});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
