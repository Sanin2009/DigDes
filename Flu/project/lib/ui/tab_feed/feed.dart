import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../domain/models/post.dart';
import '../../domain/models/user.dart';
import '../common/helper.dart';
import '../../internal/config/app_config.dart';
import '../../internal/config/shared_prefs.dart';
import '../../internal/config/token_storage.dart';
import '../../internal/dependencies/repository_module.dart';
import '../navigation/app_navigator.dart';

class FeedViewModel extends ChangeNotifier {
  BuildContext context;
  final _authService = AuthService();
  final _api = RepositoryModule.apiRepository();
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

    posts = await _api.getAllPosts(0, 10);
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
  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<FeedViewModel>();
    var itemCount = viewModel.posts?.length ?? 0;
    var size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text("Feed"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: viewModel.logout,
          )
        ],
      ),
      body: Container(
          child: viewModel.posts == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                        child: ListView.separated(
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: itemCount,
                      //controller: viewModel._lvc,
                      itemBuilder: (listContext, listIndex) {
                        Widget res;
                        var posts = viewModel.posts;
                        if (posts != null) {
                          var post = posts[listIndex];
                          res = Container(
                            padding: const EdgeInsets.all(10),
                            height: (post.showPostModel.attaches!.isNotEmpty)
                                ? size.width + 150
                                : 120,
                            color: Colors.white,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                "$baseUrl${post.userModel.avatarLink}"),
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    Text(
                                        "  ${post.userModel.name}: ${post.showPostModel.name}"),
                                    const Spacer(),
                                    Text(
                                        "${DateTime.parse(post.showPostModel.created).day.toString()} of ${Helper.GetMonth(DateTime.parse(post.showPostModel.created).month.toString())}")
                                  ],
                                ),
                                Expanded(
                                  child: PageView.builder(
                                    onPageChanged: (value) => viewModel
                                        .onPageChanged(listIndex, value),
                                    itemCount:
                                        post.showPostModel.attaches!.length,
                                    itemBuilder: (pageContext, pageIndex) =>
                                        Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            color: Colors.white,
                                            child: Image(
                                                image: NetworkImage(
                                              "$baseUrl${post.showPostModel.attaches![pageIndex]}",
                                            )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                PageIndicator(
                                  count: post.showPostModel.attaches!.length,
                                  current: viewModel.pager[listIndex],
                                ),
                                Row(
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.thumb_up),
                                      label: Text(
                                          "${post.showPostModel.totalLikes}"),
                                      onPressed: () {},
                                    ),
                                    const Spacer(),
                                    TextButton.icon(
                                      icon: const Icon(Icons.chat_bubble),
                                      label: Text(
                                          "${post.showPostModel.totalComments}"),
                                      onPressed: () {},
                                    )
                                  ],
                                )
                              ],
                            ),
                          );
                        } else {
                          res = const SizedBox.shrink();
                        }
                        return res;
                      },
                    )),
                    if (viewModel.isLoading) const LinearProgressIndicator()
                  ],
                )),
    );
  }
}

class PageIndicator extends StatelessWidget {
  final int count;
  final int? current;
  final double width;
  const PageIndicator(
      {Key? key, required this.count, required this.current, this.width = 10})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[];
    for (var i = 0; i < count; i++) {
      widgets.add(
        Icon(
          Icons.circle,
          size: i == (current ?? 0) ? width * 1.4 : width,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [...widgets],
    );
  }
}
