import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper.dart';
import '../../internal/config/app_config.dart';
import '../app_navigator.dart';
import '../common/bottom_app_bar_widget.dart';
import 'profile_view_model.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<ProfileViewModel>();
    var u = viewModel.user;
    return Scaffold(
      appBar: AppBar(
        leading: (u != null && viewModel.headers != null)
            ? CircleAvatar(
                backgroundImage: NetworkImage("$baseUrl${u.avatarLink}",
                    headers: viewModel.headers),
              )
            : null,
        title: Text(u == null ? "Hello!" : "Hello, ${u.name}"),
        actions: [
          const IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: AppNavigator.toBack,
          ),
          const IconButton(
            icon: Icon(Icons.settings),
            onPressed: AppNavigator.toSettings,
          ),
          IconButton(
              icon: const Icon(Icons.exit_to_app), onPressed: viewModel.logout),
        ],
      ),
      body: (u != null)
          ? ListView(
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
                      margin: const EdgeInsets.all(20),
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage("$baseUrl${u.avatarLink}"),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blue,
                      ),
                      onPressed: viewModel.changePhoto,
                    ),
                    const Spacer()
                  ],
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
                Text("Name: ${u.name}"),
                Text(
                    "Birthday: ${DateTime.parse(u.birthDay).day} of ${Helper.GetMonth(DateTime.parse(u.birthDay).month.toString())} ${DateTime.parse(u.birthDay).year}"),
                Text(
                    "Last online: ${DateTime.now().day} of ${Helper.GetMonth(DateTime.now().month.toString())} at ${DateTime.now().hour}:${(DateTime.now().minute > 9) ? DateTime.now().minute : "0${DateTime.now().minute}"}"),
                Text("Login: ${u.email}"),
                Text("Status: ${u.status ?? "no status"}"),
                Text("Total Posts: ${u.totalPosts}"),
                Text("Total Comments: ${u.totalComments}"),
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
                const Text("Your posts:"),
              ],
            )
          : null,
      bottomNavigationBar: BottomAppBarMenu(
          fabLocation: FloatingActionButtonLocation.centerDocked),
    );
  }

  static create() {
    return ChangeNotifierProvider(
      create: (BuildContext context) => ProfileViewModel(context: context),
      child: const Profile(),
    );
  }
}
