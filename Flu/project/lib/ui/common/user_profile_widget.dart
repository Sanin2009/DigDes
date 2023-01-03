import 'package:flutter/material.dart';

import '../../domain/models/user.dart';
import '../../internal/config/app_config.dart';
import '../navigation/app_navigator.dart';
import 'helper.dart';

class UserProfileWidget extends StatelessWidget {
  final User u;
  final bool isMyProfile;
  const UserProfileWidget(this.u, this.isMyProfile, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(30),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: NetworkImage("$baseUrl${u.avatarLink}"),
                    fit: BoxFit.cover),
              ),
            ),
          ],
        ),
        Align(
            alignment: Alignment.center,
            child: Text(
              u.name,
              style: const TextStyle(fontSize: 25),
            )),
        Align(
          alignment: Alignment.center,
          child: Text(u.status ?? " ", style: const TextStyle(fontSize: 20)),
        ),
        Row(
          children: [
            const Spacer(),
            TextButton(
                onPressed: () {},
                child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "My subscripitions",
                    style: TextStyle(color: Colors.blue),
                  ),
                )),
            const Spacer()
          ],
        ),
        Row(
          children: [
            const Spacer(),
            TextButton(
                onPressed: () {},
                child: Align(
                  alignment: Alignment.center,
                  child: Text("Subscribers: ${u.totalSubs}",
                      style: const TextStyle(color: Colors.blue)),
                )),
            const Spacer()
          ],
        ),
        Text("Account: ${u.isOpen ? "Open" : "Private"}"),
        Text(
            "Birthday: ${DateTime.parse(u.birthDay).day} of ${Helper.GetMonth(DateTime.parse(u.birthDay).month.toString())} ${DateTime.parse(u.birthDay).year}"),
        Text(
            "Last online: ${DateTime.parse(u.lastActive).day} of ${Helper.GetMonth(DateTime.parse(u.lastActive).month.toString())} at ${DateTime.parse(u.lastActive).hour}:${(DateTime.parse(u.lastActive).minute > 9) ? DateTime.parse(u.lastActive).minute : "0${DateTime.parse(u.lastActive).minute}"}"),
        Text("Total Posts: ${u.totalPosts}"),
        Text("Total Comments: ${u.totalComments}"),
        if (isMyProfile)
          Row(
            children: [
              const Spacer(),
              Card(
                child: TextButton(
                    onPressed: () {},
                    child: const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Update status",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blue),
                      ),
                    )),
              ),
              const Spacer()
            ],
          ),
        Row(),
        if (isMyProfile)
          Card(
            child: TextButton(
                onPressed: () {
                  AppNavigator.toCreatePost();
                },
                child: const Align(
                    alignment: Alignment.center,
                    child: Text("Create a post",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blue)))),
          ),
        Card(
          child: TextButton(
              onPressed: () {
                // TODO AppNavigator.toShowUserPosts(userId);
              },
              child: const Align(
                  alignment: Alignment.center,
                  child: Text("Show posts",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blue)))),
        )
      ],
    );
  }
}
