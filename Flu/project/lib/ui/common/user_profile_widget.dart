import 'package:flutter/material.dart';

import '../../domain/models/user.dart';

class UserProfileWidget extends StatelessWidget {
  final User user;
  const UserProfileWidget(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  static create(Object? arg) {
    User user;
    if (arg != null && arg is User) {
      user = arg;
    } else {
      throw Exception();
    }
    return UserProfileWidget(user);
  }
}
