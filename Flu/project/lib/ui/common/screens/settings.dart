import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/settings.dart';
import '../../../domain/models/user.dart';
import '../../../internal/config/shared_prefs.dart';
import '../../../internal/config/token_storage.dart';
import '../../../internal/dependencies/repository_module.dart';

class _ViewModel extends ChangeNotifier {
  BuildContext context;

  final _api = RepositoryModule.apiRepository();

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

  void changeSettings() async {
    var isOpen =
        await _api.updateSettings(SettingsModel(isOpen: !user!.isOpen));
    var tempuser = user;
    tempuser?.isOpen = isOpen ?? true;
    user = tempuser;
  }

  void asyncInit() async {
    var token = await TokenStorage.getAccessToken();
    headers = {"Authorization": "Bearer $token"};
    user = await SharedPrefs.getStoredUser();
  }
}

class Settings extends StatefulWidget {
  const Settings({Key? key, required this.title}) : super(key: key);
  final String title;

  static create() {
    return ChangeNotifierProvider(
      create: (BuildContext context) => _ViewModel(context: context),
      child: const Settings(title: "Settings"),
    );
  }

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var items = {"Opened", "Private"};
  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    var u = viewModel.user;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Text(widget.title),
        actions: const [],
      ),
      body: ListView(
        children: [
          (u != null)
              ? SwitchListTile(
                  value: !u.isOpen,
                  onChanged: (value) {
                    viewModel.changeSettings();
                  },
                  title: const Text("Private"))
              : Row(),
        ],
      ),
    );
  }
}
