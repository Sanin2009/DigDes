import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../domain/models/user.dart';
import '../../internal/config/app_config.dart';
import '../../internal/config/shared_prefs.dart';
import '../../internal/config/token_storage.dart';
import '../app_navigator.dart';

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

  void _refresh() async {
    await _authService.tryGetUser();
  }
}

class AppBarMenu1 extends AppBar {
  AppBarMenu1({super.key});

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    return AppBar(
      leading: (viewModel.user != null && viewModel.headers != null)
          ? CircleAvatar(
              backgroundImage: NetworkImage(
                  "$baseUrl${viewModel.user!.avatarLink}",
                  headers: viewModel.headers),
            )
          : null,
      title: Text(
          viewModel.user == null ? "Hello!" : "Hello, ${viewModel.user!.name}"),
      actions: [
        IconButton(
            icon: const Icon(Icons.refresh), onPressed: viewModel._refresh),
        IconButton(
            icon: const Icon(Icons.exit_to_app), onPressed: viewModel._logout),
      ],
    );
  }
}