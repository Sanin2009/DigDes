import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/post.dart';
import '../../../domain/models/user.dart';
import '../../../internal/config/app_config.dart';
import '../../../internal/config/shared_prefs.dart';
import '../../../internal/config/token_storage.dart';
import '../../../internal/dependencies/repository_module.dart';
import '../helper.dart';
import '../../navigation/tab_navigator.dart';

class UpdateNotifierModel extends ChangeNotifier {
  void updateValue(List<ShowPost>? posts) {
    notifyListeners();
  }
}

class ViewPostsViewModel extends ChangeNotifier {
  BuildContext context;
  final _api = RepositoryModule.apiRepository();

  List<ShowPost>? _posts;
  List<ShowPost>? get posts => _posts;
  set posts(List<ShowPost>? val) {
    _posts = val;
    notifyListeners();
  }

  void update(List<ShowPost>? inposts) {
    posts = inposts;
  }

  ViewPostsViewModel({required this.context, List<ShowPost>? inposts}) {
    posts = inposts;
    asyncInit();
  }

  void changeValues(String postId) async {
    var postdata = await _api.getDynamicPostData(postId);
    List<ShowPost>? tempPosts;
    for (int i = 0; i < posts!.length; i++) {
      if (posts![i].showPostModel.id != postId) {
        if (tempPosts == null) {
          tempPosts = <ShowPost>[posts![i]];
        } else {
          tempPosts.add(posts![i]);
        }
      } else {
        List<ShowPost>? tempPost = <ShowPost>[posts![i]];
        tempPost[0].showPostModel.likedByMe = postdata.likedByMe;
        tempPost[0].showPostModel.totalComments = postdata.totalComments;
        tempPost[0].showPostModel.totalLikes = postdata.totalLikes;
        if (tempPosts == null) {
          tempPosts = <ShowPost>[posts![i]];
        } else {
          tempPosts.add(tempPost[0]);
        }
      }
    }
    posts = tempPosts;
  }

  void toPostDetail(ShowPost post) {
    Navigator.of(context)
        .pushNamed(TabNavigatorRoutes.postDetails, arguments: post)
        .then((value) => changeValues(post.showPostModel.id));
  }

  void toUserProfile(User user) async {
    var newuser = await _api.getUserById(user.id);
    if (newuser != null) toUserProfileNavigation(newuser);
  }

  void toUserProfileNavigation(User user) {
    Navigator.of(context)
        .pushNamed(TabNavigatorRoutes.userProfile, arguments: user);
  }

  User? _user;
  User? get user => _user;
  set user(User? val) {
    _user = val;
    notifyListeners();
  }

  Map<int, int> pager = <int, int>{};

  void onPageChanged(int listIndex, int pageIndex) {
    pager[listIndex] = pageIndex;
    notifyListeners();
  }

  Map<String, String>? headers;

  void updateLike(String postId) async {
    await _api.updateLike(postId);
    changeValues(postId);
  }

  void deletePost(String postId) async {
    await _api.deletePost(postId);
    List<ShowPost>? tempPosts;
    for (int i = 0; i < posts!.length; i++) {
      if (posts![i].showPostModel.id != postId) {
        if (tempPosts == null) {
          tempPosts = <ShowPost>[posts![i]];
        } else {
          tempPosts.add(posts![i]);
        }
      }
    }
    posts = tempPosts;
  }

  void asyncInit() async {
    user = await SharedPrefs.getStoredUser();
    var token = await TokenStorage.getAccessToken();
    headers = {"Authorization": "Bearer $token"};
  }
}

class PostsViewModel extends StatelessWidget {
  const PostsViewModel({super.key});

  static create(BuildContext context, Object? arg) {
    List<ShowPost> posts;
    if (arg != null && arg is List<ShowPost>) {
      posts = arg;
    } else {
      throw Exception();
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (BuildContext context) => UpdateNotifierModel()),
        ChangeNotifierProxyProvider<UpdateNotifierModel, ViewPostsViewModel>(
          create: (BuildContext context) =>
              ViewPostsViewModel(context: context),
          update: (BuildContext context, _, previous) =>
              previous!..update(posts),
        )
      ],
      child: const PostsViewModel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<ViewPostsViewModel>();
    var itemCount = viewModel.posts?.length ?? 0;
    var size = MediaQuery.of(context).size;
    return Expanded(
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
                    GestureDetector(
                      child: Container(
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
                      onTap: () {
                        viewModel.toUserProfile(post.userModel);
                      },
                    ),
                    Expanded(
                      flex: 8,
                      child: Text(
                          "${post.userModel.name}: ${post.showPostModel.name}"),
                    ),
                    if (post.userModel.id == viewModel.user?.id)
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                        title: const Text("Deleting Post"),
                                        content: const Text(
                                            "Are you sure you want to delete your post?"),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                viewModel.deletePost(
                                                    post.showPostModel.id);
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Yes")),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("No")),
                                        ]));
                          },
                        ),
                      ),
                    Expanded(
                        flex: 2,
                        child: Text(
                            "${DateTime.parse(post.showPostModel.created).day.toString()} of ${Helper.GetMonth(DateTime.parse(post.showPostModel.created).month.toString())}"))
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    onPageChanged: (value) =>
                        viewModel.onPageChanged(listIndex, value),
                    itemCount: post.showPostModel.attaches!.length,
                    itemBuilder: (pageContext, pageIndex) => Column(
                      children: [
                        Expanded(
                            child: GestureDetector(
                          child: Container(
                            color: Colors.white,
                            child: Image(
                                image: NetworkImage(
                              "$baseUrl${post.showPostModel.attaches![pageIndex]}",
                            )),
                          ),
                          onDoubleTap: () => viewModel.toPostDetail(post),
                        )),
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
                      icon: Icon(Icons.thumb_up,
                          color: (post.showPostModel.likedByMe
                              ? Colors.black
                              : Colors.green)),
                      label: Text("${post.showPostModel.totalLikes}"),
                      onPressed: () {
                        viewModel.updateLike(post.showPostModel.id);
                      },
                    ),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.chat_bubble),
                      label: Text("${post.showPostModel.totalComments}"),
                      onPressed: () => viewModel.toPostDetail(post),
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
    ));
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
