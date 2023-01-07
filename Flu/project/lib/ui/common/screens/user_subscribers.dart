import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/user.dart';
import '../../../internal/config/app_config.dart';
import '../../../internal/config/shared_prefs.dart';
import '../../../internal/config/token_storage.dart';
import '../../../internal/dependencies/repository_module.dart';
import '../../navigation/tab_navigator.dart';

class _ViewModel extends ChangeNotifier {
  final BuildContext context;
  final String userid;
  final _api = RepositoryModule.apiRepository();

  _ViewModel(this.userid, {required this.context}) {
    asyncInit(userid);
  }

  User? _user;
  User? get user => _user;
  set user(User? val) {
    _user = val;
    notifyListeners();
  }

  List<User>? _subscribers;
  List<User>? get subscribers => _subscribers;
  set subscribers(List<User>? val) {
    _subscribers = val;
    notifyListeners();
  }

  List<User>? _pendingSubscribers;
  List<User>? get pendingSubscribers => _pendingSubscribers;
  set pendingSubscribers(List<User>? val) {
    _pendingSubscribers = val;
    notifyListeners();
  }

  void acceptSub(User user) async {
    var t = await _api.updateSubRequests(user.id, true);
    if (t) {
      await removeSubFromList(user);
      List<User> tempuser = <User>[user];
      subscribers = <User>[...?subscribers, ...tempuser];
    }
  }

  void toUserProfile(User user) async {
    var newuser = await _api.getUserById(user.id);
    toUserProfileNavigation(newuser);
  }

  void toUserProfileNavigation(User? user) {
    Navigator.of(context)
        .pushNamed(TabNavigatorRoutes.userProfile, arguments: user);
  }

  void declineSub(User user) async {
    var t = await _api.updateSubRequests(user.id, false);
    if (t) {
      await removeSubFromList(user);
    }
  }

  Future removeSubFromList(User user) async {
    List<User>? tempUsers;
    if (subscribers != null) {
      for (int i = 0; i < subscribers!.length; i++) {
        if (subscribers![i].id != user.id) {
          if (tempUsers == null) {
            tempUsers = <User>[subscribers![i]];
          } else {
            tempUsers.add(subscribers![i]);
          }
        }
      }
      subscribers = tempUsers;
    }

    tempUsers = null;
    if (pendingSubscribers != null) {
      for (int i = 0; i < pendingSubscribers!.length; i++) {
        if (pendingSubscribers![i].id != user.id) {
          if (tempUsers == null) {
            tempUsers = <User>[pendingSubscribers![i]];
          } else {
            tempUsers.add(pendingSubscribers![i]);
          }
        }
      }
      pendingSubscribers = tempUsers;
    }
  }

  Map<String, String>? headers;

  void asyncInit(String userId) async {
    user = await SharedPrefs.getStoredUser();
    var token = await TokenStorage.getAccessToken();
    headers = {"Authorization": "Bearer $token"};
    subscribers = await _api.getSubscribers(userId);
    pendingSubscribers = await _api.getSubRequests(userId);
  }
}

class UserSubscribers extends StatefulWidget {
  const UserSubscribers({Key? key, required this.userid}) : super(key: key);
  final String userid;

  static create(Object? arg) {
    String userid;
    if (arg != null && arg is String) {
      userid = arg;
    } else {
      throw Exception();
    }
    return ChangeNotifierProvider(
      create: (BuildContext context) => _ViewModel(userid, context: context),
      child: UserSubscribers(userid: userid),
    );
  }

  @override
  State<UserSubscribers> createState() => _UserSubscribersState();
}

class _UserSubscribersState extends State<UserSubscribers> {
  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    var itemCount = (viewModel.subscribers?.length ?? 0) +
        (viewModel.pendingSubscribers?.length ?? 0);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text("Subscribers list"),
      ),
      body: SafeArea(
          child: Expanded(
              child: ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        itemCount: (itemCount),
        itemBuilder: (listContext, listIndex) {
          var subs = viewModel.subscribers;
          var subRequests = viewModel.pendingSubscribers;
          if (itemCount == 0) return const SizedBox.shrink();
          Widget res;
          User user;
          if ((subs?.length ?? 0) > listIndex) {
            user = subs![listIndex];
          } else {
            user = subRequests![listIndex - (subs?.length ?? 0)];
          }
          res = Container(
            padding: const EdgeInsets.all(10),
            height:
                (listIndex == 0 || listIndex == (subs?.length ?? 0)) ? 100 : 80,
            color: Colors.white,
            child: Column(
              children: [
                if (listIndex == 0 && (subs?.length != 0))
                  const Text("Subscribers"),
                if (listIndex == subs?.length) const Text("Subscribe requests"),
                Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage("$baseUrl${user.avatarLink}"),
                              fit: BoxFit.cover),
                        ),
                      ),
                      onTap: () {
                        viewModel.toUserProfile(user);
                      },
                    ),
                    Expanded(
                      flex: 8,
                      child: Text(" ${user.name}    ${user.status ?? ""}"),
                    ),
                    if (viewModel.user!.id == viewModel.userid &&
                        (subs?.length ?? 0) <= listIndex)
                      Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              viewModel.acceptSub(user);
                            },
                          )),
                    if (viewModel.user!.id == viewModel.userid)
                      Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(Icons.delete_forever),
                            onPressed: () {
                              viewModel.declineSub(user);
                            },
                          )),
                  ],
                ),
              ],
            ),
          );
          return res;
        },
      ))),
    );
  }
}
