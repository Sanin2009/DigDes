import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../domain/models/user.dart';
import '../../internal/config/app_config.dart';
import '../../internal/config/shared_prefs.dart';
import '../../internal/config/token_storage.dart';
import '../../internal/dependencies/repository_module.dart';
import '../navigation/app_navigator.dart';
import '../common/cam_widget.dart';
import '../roots/main_app.dart';

class ProfileViewModel extends ChangeNotifier {
  final _api = RepositoryModule.apiRepository();
  final _authService = AuthService();
  final BuildContext context;
  ProfileViewModel({required this.context}) {
    asyncInit();
  }
  User? _user;
  User? get user => _user;
  set user(User? val) {
    _user = val;
    notifyListeners();
  }

  Map<String, String>? headers;

  Future asyncInit() async {
    user = await SharedPrefs.getStoredUser();
    var token = await TokenStorage.getAccessToken();
    headers = {"Authorization": "Bearer $token"};
    var img = await NetworkAssetBundle(Uri.parse("$baseUrl${user!.avatarLink}"))
        .load("$baseUrl${user!.avatarLink}");
    avatar = Image.memory(
      img.buffer.asUint8List(),
      fit: BoxFit.fill,
    );
  }

  String? _imagePath;
  Image? _avatar;
  Image? get avatar => _avatar;
  set avatar(Image? val) {
    _avatar = val;
    notifyListeners();
  }

  void logout() async {
    await _authService.logout().then((value) => AppNavigator.toLoader());
  }

  Future changePhoto() async {
    var appmodel = context.read<AppViewModel>();
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (newContext) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: SafeArea(
          child: CamWidget(
            onFile: (file) {
              _imagePath = file.path;
              Navigator.of(newContext).pop();
            },
          ),
        ),
      ),
    ));
    if (_imagePath != null) {
      var t = await _api.uploadTemp(files: [File(_imagePath!)]);
      if (t.isNotEmpty) {
        await _api.addAvatarToUser(t.first);
        var img =
            await NetworkAssetBundle(Uri.parse("$baseUrl${user!.avatarLink}"))
                .load("$baseUrl${user!.avatarLink}");
        var avImage = Image.memory(img.buffer.asUint8List());
        avatar = avImage;
        appmodel.avatar = avImage;
      }
    }
  }
}
