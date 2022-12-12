import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../domain/models/user.dart';
import '../../internal/config/app_config.dart';
import '../../internal/config/shared_prefs.dart';
import '../../internal/config/token_storage.dart';
import '../app_navigator.dart';
import '../widgets/bottom_app_bar_widget.dart';

class _ViewModel extends ChangeNotifier {
  BuildContext context;

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
}

class Feed extends StatefulWidget {
  const Feed({Key? key, required this.title}) : super(key: key);

  final String title;

  static create() {
    return ChangeNotifierProvider(
      create: (BuildContext context) => _ViewModel(context: context),
      child: const Feed(title: "Feed"),
    );
  }

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  int _counter = 0;
  final _authService = AuthService();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _logout() {
    _authService.logout().then((value) => AppNavigator.toLoader());
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    var u = viewModel.user;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        leading: (u != null && viewModel.headers != null)
            ? CircleAvatar(
                backgroundImage: NetworkImage("$baseUrl${u.avatarLink}",
                    headers: viewModel.headers),
              )
            : null,
        title: Text(u == null
            ? "Hello!"
            : "Hello, ${u.name} - ${widget.title} - $_counter "),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          )
        ],
      ),
      body: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.post_add),
      ),
      bottomNavigationBar: BottomAppBarMenu(
          fabLocation: FloatingActionButtonLocation.centerDocked),
    );
  }
}
