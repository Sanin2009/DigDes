import 'package:flutter/material.dart';

import '../../../domain/models/user.dart';
import '../widgets/user_profile_widget.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key, required this.userOfProfile});
  final User userOfProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User ${userOfProfile.name}"),
      ),
      body: UserProfileWidget.create(userOfProfile),
    );
  }

  static create(Object? arg) {
    User userOfProfile;
    if (arg != null && arg is User) {
      userOfProfile = arg;
    } else {
      throw Exception();
    }
    return UserProfile(userOfProfile: userOfProfile);
  }
}
