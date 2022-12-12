import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../domain/models/user.dart';
import '../../helper.dart';
import '../../internal/config/app_config.dart';
import '../../internal/config/shared_prefs.dart';
import '../../internal/config/token_storage.dart';
import '../app_navigator.dart';
import '../widgets/bottom_app_bar_widget.dart';

class _ViewModel extends ChangeNotifier {
  BuildContext context;
  final _authService = AuthService();

  _ViewModel({required this.context}) {
    asyncInit();
  }

  User? _user;

  User? get user => _user;

  set user(User? val) {
    _user = val;
    notifyListeners();
  }

  Map<String, String>? headers;

  void asyncInit() async {
    var token = await TokenStorage.getAccessToken();
    headers = {"Authorization": "Bearer $token"};
    user = await SharedPrefs.getStoredUser();
  }

  void _logout() async {
    await _authService.logout().then((value) => AppNavigator.toLoader());
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
          IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: viewModel._logout),
        ],
      ),
      body: (u != null)
          ? ListView(
              children: [
                Image(
                    image: NetworkImage("$baseUrl${u.avatarLink}",
                        headers: viewModel.headers)),
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                        onPressed: () {},
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("Subscribers: ${u.totalSubs}"),
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
                    TextButton(
                        onPressed: () {},
                        child: const Card(
                            child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Update status",
                            textAlign: TextAlign.center,
                          ),
                        ))),
                    const Spacer()
                  ],
                ),
                Row(),
                TextButton(
                    onPressed: () {},
                    child: const Card(
                        child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Create a post",
                        textAlign: TextAlign.center,
                      ),
                    )))
              ],
            )
          : null,
      bottomNavigationBar: BottomAppBarMenu(
          fabLocation: FloatingActionButtonLocation.centerDocked),
    );
  }

  static create() {
    return ChangeNotifierProvider(
      create: (BuildContext context) => _ViewModel(context: context),
      child: const App(),
    );
  }
}
