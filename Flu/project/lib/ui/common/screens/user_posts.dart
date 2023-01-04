import 'package:flutter/material.dart';
import 'package:project/ui/common/widgets/posts_view_model.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/post.dart';
import '../../../domain/models/user.dart';
import '../../../internal/config/shared_prefs.dart';
import '../../../internal/config/token_storage.dart';
import '../../../internal/dependencies/repository_module.dart';

class UserPostsViewModel extends ChangeNotifier {
  final BuildContext context;
  final String userid;
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

  UserPostsViewModel(this.userid, {required this.context}) {
    asyncInit(userid);
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
    newPosts = await _api.getUsersPosts(userid, skip, take);
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
    posts = await _api.getUsersPosts(userid, skip, take);
    skip += 10;
    isLoading = false;
  }

  void asyncInit(String userid) async {
    user = await SharedPrefs.getStoredUser();
    var token = await TokenStorage.getAccessToken();
    headers = {"Authorization": "Bearer $token"};
    posts = await _api.getUsersPosts(userid, skip, take);
    skip += 10;
  }
}

class UserPosts extends StatefulWidget {
  const UserPosts({Key? key, required this.userid}) : super(key: key);
  final String userid;

  static create(Object? arg) {
    String userid;
    if (arg != null && arg is String) {
      userid = arg;
    } else {
      throw Exception();
    }
    return ChangeNotifierProvider(
      create: (BuildContext context) =>
          UserPostsViewModel(userid, context: context),
      child: UserPosts(userid: userid),
    );
  }

  @override
  State<UserPosts> createState() => _UserPostsState();
}

class _UserPostsState extends State<UserPosts> {
  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<UserPostsViewModel>();
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text("User's Posts"),
      ),
      body: Column(
        children: [
          viewModel.posts == null
              ? const Center(child: CircularProgressIndicator())
              : PostsViewModel.create(context, viewModel.posts),
          Row(children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                onPressed: () {
                  viewModel.refresh();
                },
                child: const Icon(Icons.refresh),
              ),
            ),
            const Spacer(),
            if (!viewModel.isLoading)
              FloatingActionButton(
                onPressed: () {
                  viewModel.addPosts();
                },
                child: const Icon(Icons.h_plus_mobiledata),
              ),
          ]),
          if (viewModel.isLoading && !viewModel.isEnd)
            const LinearProgressIndicator()
        ],
      ),
    );
  }
}
