import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../domain/models/post.dart';
import '../../domain/models/user.dart';
import '../../internal/config/app_config.dart';
import '../../internal/config/shared_prefs.dart';
import '../../internal/config/token_storage.dart';
import '../app_navigator.dart';
import '../common/bottom_app_bar_widget.dart';

class FeedViewModel extends ChangeNotifier {
  BuildContext context;
  final _authService = AuthService();
  //final _lvc = ScrollController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool val) {
    _isLoading = val;
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

  List<ShowPost>? _posts;
  List<ShowPost>? get posts => _posts;
  set posts(List<ShowPost>? val) {
    _posts = val;
    notifyListeners();
  }

  Map<int, int> pager = <int, int>{};

  void onPageChanged(int listIndex, int pageIndex) {
    pager[listIndex] = pageIndex;
    notifyListeners();
  }

  Map<String, String>? headers;

  void asyncInit() async {
    user = await SharedPrefs.getStoredUser();
    var token = await TokenStorage.getAccessToken();
    headers = {"Authorization": "Bearer $token"};
    var img = await NetworkAssetBundle(Uri.parse("$baseUrl${user!.avatarLink}"))
        .load("$baseUrl${user!.avatarLink}");
    avatar = Image.memory(
      img.buffer.asUint8List(),
      fit: BoxFit.fill,
    );

    //await SyncService().syncPosts();
    //posts = await _dataService.getPosts();
  }

  void logout() {
    _authService.logout().then((value) => AppNavigator.toLoader());
  }
}

class Feed extends StatefulWidget {
  const Feed({Key? key, required this.title}) : super(key: key);

  final String title;

  static create() {
    return ChangeNotifierProvider(
      create: (BuildContext context) => FeedViewModel(context: context),
      child: const Feed(title: "Feed"),
    );
  }

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<FeedViewModel>();
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
            onPressed: viewModel.logout,
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
