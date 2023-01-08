import 'package:flutter/material.dart';

import '../../domain/models/post.dart';
import '../../domain/models/user.dart';
import '../../internal/config/shared_prefs.dart';
import '../../internal/config/token_storage.dart';
import '../../internal/dependencies/repository_module.dart';

class FeedViewModel extends ChangeNotifier {
  final BuildContext context;
  final _api = RepositoryModule.apiRepository();

  int skip = 0;
  int take = 10;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  bool _isEnd = false;
  bool get isEnd => _isEnd;
  set isEnd(bool val) {
    _isEnd = val;
    notifyListeners();
  }

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;
  set isRefreshing(bool val) {
    _isRefreshing = val;
    notifyListeners();
  }

  FeedViewModel({required this.context}) {
    asyncInit();
  }

  User? _user;
  User? get user => _user;
  set user(User? val) {
    _user = val;
    notifyListeners();
  }

  Image? _avatar;
  Image? get avatar => _avatar;
  set avatar(Image? val) {
    _avatar = val;
    notifyListeners();
  }

  List<ShowPost>? newPosts;

  List<ShowPost>? _posts;
  List<ShowPost>? get posts => _posts;
  set posts(List<ShowPost>? val) {
    _posts = val;
    notifyListeners();
  }

  Map<String, String>? headers;

  void addPosts() async {
    isLoading = true;
    newPosts = await _api.getFeed(skip, take);
    skip += 10;
    if (newPosts == null || newPosts!.isEmpty) {
      isEnd = true;
      return;
    }
    posts = <ShowPost>[...posts!, ...newPosts!];
    isLoading = false;
  }

  void refresh() async {
    isLoading = true;
    skip = 0;
    take = 10;
    posts = await _api.getFeed(skip, take);
    if (posts == null || posts!.isEmpty) {
      isEnd = true;
    } else {
      isEnd = false;
    }
    skip += 10;
    isLoading = false;
  }

  void asyncInit() async {
    user = await SharedPrefs.getStoredUser();
    var token = await TokenStorage.getAccessToken();
    headers = {"Authorization": "Bearer $token"};
    posts = await _api.getFeed(skip, take);
    if (posts == null || posts!.isEmpty) isEnd = true;
    skip += 10;
  }
}
