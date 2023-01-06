import 'package:flutter/material.dart';

import '../../../domain/enums/user_list.dart';
import '../../../domain/models/user.dart';
import '../../../internal/config/app_config.dart';
import '../../../internal/dependencies/repository_module.dart';
import '../../navigation/tab_navigator.dart';

class UserListWidget extends StatelessWidget {
  UserListWidget(this.users, this.userListType, {super.key});
  final List<User>? users;
  final UserListTypeEnum userListType;
  final _api = RepositoryModule.apiRepository();

  void toUserProfile(User user, BuildContext context) async {
    var newuser = await _api.getUserById(user.id);
    Navigator.of(context)
        .pushNamed(TabNavigatorRoutes.userProfile, arguments: newuser);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            itemCount: users?.length ?? 0,
            itemBuilder: (listContext, listIndex) {
              Widget res;
              if (users != null) {
                var user = users![listIndex];
                res = Container(
                    padding: const EdgeInsets.all(10),
                    height: 60,
                    color: Colors.white,
                    child: Column(children: [
                      Row(children: [
                        GestureDetector(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(
                                      "$baseUrl${user.avatarLink}"),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          onTap: () {
                            toUserProfile(user, context);
                          },
                        ),
                        Expanded(
                          flex: 8,
                          child: Text(" ${user.name}    ${user.status ?? ""}"),
                        ),
                      ])
                    ]));
                return res;
              } else {
                return const SizedBox.shrink();
              }
            }));
  }
}
