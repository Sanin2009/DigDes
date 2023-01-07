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

  //Image? _avatar;
  //Image? get avatar => _avatar;
  //set avatar(Image? val) {
  //  _avatar = val;
  //  notifyListeners();
  // }

  Map<String, String>? headers;

  void asyncInit(String userId) async {
    // TODO
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
          if (itemCount == 0) return SizedBox.shrink();
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
                if (listIndex == 0 && (subs?.length != 0)) Text("Subscribers"),
                if (listIndex == subs?.length) Text("Subscribe requests"),
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
                        Navigator.of(context).pushNamed(
                            TabNavigatorRoutes.userProfile,
                            arguments: user);
                      },
                    ),
                    Expanded(
                      flex: 8,
                      child: Text(" ${user.name}    ${user.status ?? ""}"),
                    ),
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
