import 'package:flutter/material.dart';
import 'package:project/domain/enums/user_list.dart';
import 'package:project/ui/common/widgets/user_list_widget.dart';

import '../../../domain/models/user.dart';

class SubscriptionList extends StatelessWidget {
  const SubscriptionList({super.key, this.users});
  final List<User>? users;

  static create(Object? arg) {
    List<User>? listOfUsers;
    if (arg != null && arg is List<User>) {
      listOfUsers = arg;
    } else {
      throw Exception();
    }
    return SubscriptionList(users: listOfUsers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Subscribers"),
        ),
        body: SafeArea(child: UserListWidget(users, UserListTypeEnum.look)));
  }
}
