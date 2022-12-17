import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class ShowCommentModel {
  final String id;
  final String name;
  final String message;
  final String created;
  final String avatarLink;

  ShowCommentModel({
    required this.id,
    required this.name,
    required this.message,
    required this.created,
    required this.avatarLink,
  });

  factory ShowCommentModel.fromJson(Map<String, dynamic> json) =>
      _$ShowCommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShowCommentModelToJson(this);
}
