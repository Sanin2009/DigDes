import 'package:flutter/material.dart';
import 'package:project/internal/config/shared_prefs.dart';
import 'package:provider/provider.dart';

import '../../../domain/enums/tab_item.dart';
import '../../../domain/models/user.dart';
import '../../../internal/config/app_config.dart';
import '../../../internal/dependencies/repository_module.dart';
import '../../navigation/app_navigator.dart';
import '../../navigation/tab_navigator.dart';
import '../../roots/main_app.dart';
import '../helper.dart';

class _ViewModel extends ChangeNotifier {
  final BuildContext context;
  var statusTec = TextEditingController();
  User u;

  User? _user;
  User? get user => _user;
  set user(User? val) {
    _user = val;
    notifyListeners();
  }

  var commentTec = TextEditingController();
  final _api = RepositoryModule.apiRepository();

  _ViewModel({required this.context, required this.u}) {
    var appModel = context.read<AppViewModel>();
    appModel.addListener(
      () {
        if (appModel.currentTab == TabItemEnum.profile) {
          asyncInit();
        }
      },
    );
    asyncInit();
  }

  void updateStatus(String status) async {
    await _api.updateStatus(status);
    User? tempuser = user;
    tempuser?.status = status;
    u.status = status;
    await SharedPrefs.setStoredUser(tempuser);
    await asyncInit();
  }

  Future asyncInit() async {
    user = await SharedPrefs.getStoredUser();
    if (u.id == user?.id) u = user ?? u;
    statusTec.text = u.status ?? "";
  }
}

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({super.key});

  static create(Object? arg) {
    User user;
    if (arg != null && arg is User) {
      user = arg;
    } else {
      throw Exception();
    }
    return ChangeNotifierProvider(
      create: (BuildContext context) => _ViewModel(context: context, u: user),
      child: const UserProfileWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
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
                    image: NetworkImage("$baseUrl${viewModel.u.avatarLink}"),
                    fit: BoxFit.cover),
              ),
            ),
          ],
        ),
        Align(
            alignment: Alignment.center,
            child: Text(
              viewModel.u.name,
              style: const TextStyle(fontSize: 25),
            )),
        Align(
          alignment: Alignment.center,
          child: Text(viewModel.u.status ?? " ",
              style: const TextStyle(fontSize: 20)),
        ),
        Row(
          children: [
            const Spacer(),
            TextButton(
                onPressed: () {},
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "${viewModel.u.name}'s subscripitions",
                    style: const TextStyle(color: Colors.blue),
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
                  child: Text("Subscribers: ${viewModel.u.totalSubs}",
                      style: const TextStyle(color: Colors.blue)),
                )),
            const Spacer()
          ],
        ),
        if (viewModel.u.id != viewModel.user?.id)
          Text("Account: ${viewModel.u.isOpen ? "Open" : "Private"}"),
        Text(
            "Birthday: ${DateTime.parse(viewModel.u.birthDay).day} of ${Helper.GetMonth(DateTime.parse(viewModel.u.birthDay).month.toString())} ${DateTime.parse(viewModel.u.birthDay).year}"),
        Text(
            "Last online: ${DateTime.parse(viewModel.u.lastActive).day} of ${Helper.GetMonth(DateTime.parse(viewModel.u.lastActive).month.toString())} at ${DateTime.parse(viewModel.u.lastActive).hour}:${(DateTime.parse(viewModel.u.lastActive).minute > 9) ? DateTime.parse(viewModel.u.lastActive).minute : "0${DateTime.parse(viewModel.u.lastActive).minute}"}"),
        Text("Total Posts: ${viewModel.u.totalPosts}"),
        Text("Total Comments: ${viewModel.u.totalComments}"),
        if (viewModel.u.id == viewModel.user?.id)
          Row(
            children: [
              const Spacer(),
              Card(
                child: TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                  title: const Text("Update status"),
                                  content: TextField(
                                    controller: viewModel.statusTec,
                                    decoration: const InputDecoration(
                                        hintText: "Status"),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          // TODO Update status
                                          viewModel.updateStatus(
                                              viewModel.statusTec.text);
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Update")),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel")),
                                  ]));
                    },
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
        if ((viewModel.u.id != viewModel.user?.id) &&
            (viewModel.u.isSub != null))
          Text(
            (viewModel.u.isSub ?? false)
                ? "You are subscribed!"
                : "Waiting for ${viewModel.u.name} to accept your subscription",
            textAlign: TextAlign.center,
          ),
        if (viewModel.u.id != viewModel.user?.id)
          Card(
            child: TextButton(
                onPressed: () {
                  //   TODO Subscribe thingy
                },
                child: Align(
                    alignment: Alignment.center,
                    child: Text(
                        viewModel.u.isSub == null ? "Subscribe" : "Unsubscribe",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: (viewModel.u.isSub == null ||
                                    viewModel.u.isSub == false)
                                ? Colors.blue
                                : Colors.red)))),
          ),
        if (viewModel.u.id == viewModel.user?.id)
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
        if (viewModel.u.isOpen ||
            (viewModel.u.isSub == true) ||
            viewModel.u.id == viewModel.user?.id)
          Card(
            child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(TabNavigatorRoutes.userPosts,
                      arguments: viewModel.u.id);
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
