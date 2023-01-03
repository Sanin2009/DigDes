import 'package:flutter/material.dart';

import '../../../domain/models/user.dart';
import '../widgets/user_profile_widget.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User ${user.name}"),
      ),
      body: UserProfileWidget(user, false),
    );
  }

  static create(Object? arg) {
    User user;
    if (arg != null && arg is User) {
      user = arg;
    } else {
      throw Exception();
    }
    return UserProfile(user: user);
  }
}
