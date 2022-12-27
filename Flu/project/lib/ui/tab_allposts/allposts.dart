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
import '../navigation/tab_navigator.dart';

class AllPostsViewModel extends ChangeNotifier {
  BuildContext context;
  final _authService = AuthService();
  final _api = RepositoryModule.apiRepository();

  int skip = 0;
  int take = 10;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;
  set isRefreshing(bool val) {
    _isRefreshing = val;
    notifyListeners();
  }

  AllPostsViewModel({required this.context}) {
    asyncInit();
  }

  void toPostDetail(ShowPost post) {
    Navigator.of(context)
        .pushNamed(TabNavigatorRoutes.postDetails, arguments: post);
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

  Map<int, int> pager = <int, int>{};

  void onPageChanged(int listIndex, int pageIndex) {
    pager[listIndex] = pageIndex;
    notifyListeners();
  }

  Map<String, String>? headers;

  void addPosts() async {
    isLoading = true;
    newPosts = await _api.getAllPosts(skip, take);
    skip += 10;
    take += 10;
    if (newPosts == null || newPosts!.isEmpty) return;
    posts = <ShowPost>[...posts!, ...newPosts!];
    isLoading = false;
  }

  void refresh() async {
    isLoading = true;
    skip = 0;
    take = 10;
    posts = await _api.getAllPosts(skip, take);
    skip += 10;
    isLoading = false;
  }

  void asyncInit() async {
    user = await SharedPrefs.getStoredUser();
    var token = await TokenStorage.getAccessToken();
    headers = {"Authorization": "Bearer $token"};

    posts = await _api.getAllPosts(skip, take);
    skip += 10;
  }

  void logout() {
    _authService.logout().then((value) => AppNavigator.toLoader());
  }
}

class AllPosts extends StatefulWidget {
  const AllPosts({Key? key, required this.title}) : super(key: key);

  final String title;

  static create() {
    return ChangeNotifierProvider(
      create: (BuildContext context) => AllPostsViewModel(context: context),
      child: const AllPosts(title: "All Posts"),
    );
  }

  @override
  State<AllPosts> createState() => _AllPostsState();
}

class _AllPostsState extends State<AllPosts> {
  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<AllPostsViewModel>();
    var itemCount = viewModel.posts?.length ?? 0;
    var size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text("All Posts"),
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
                                    Expanded(
                                      flex: 8,
                                      child: Text(
                                          "${post.userModel.name}: ${post.showPostModel.name}"),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${DateTime.parse(post.showPostModel.created).day.toString()} of ${Helper.GetMonth(DateTime.parse(post.showPostModel.created).month.toString())}"))
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
                                      onPressed: () =>
                                          viewModel.toPostDetail(post),
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
                    Row(children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: FloatingActionButton(
                          onPressed: () {
                            viewModel.refresh();
                          },
                          child: Icon(Icons.refresh),
                        ),
                      ),
                      Spacer(),
                      if (!viewModel.isLoading)
                        FloatingActionButton(
                          onPressed: () {
                            viewModel.addPosts();
                          },
                          child: Icon(Icons.h_plus_mobiledata),
                        ),
                    ]),
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
